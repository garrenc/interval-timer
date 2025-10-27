import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:interval_timer/services/app_state.dart';
import 'package:interval_timer/components/top_bar.dart';
import 'package:interval_timer/services/notification_service.dart';
import 'package:interval_timer/services/api_service.dart';

import '../services/logger.dart';

enum TimerStatus { idle, countdown, running, paused }

enum TimerPhase { work, shortBreak, longBreak }

enum TimerSound {
  workStart,
  workEnd;

  String get path => 'assets/sounds/${this == TimerSound.workStart ? 'work_start' : 'work_done'}.mp3';
}

class _EyeBreakDialog extends StatefulWidget {
  final int breakDuration;
  final VoidCallback onComplete;

  const _EyeBreakDialog({required this.breakDuration, required this.onComplete});

  @override
  State<_EyeBreakDialog> createState() => _EyeBreakDialogState();
}

class _EyeBreakDialogState extends State<_EyeBreakDialog> {
  late int _remaining;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.breakDuration;
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining <= 1) {
        timer.cancel();
        widget.onComplete();
      } else {
        setState(() => _remaining--);
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Fullscreen blocking overlay
    return Material(
      color: Colors.black,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2C),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.remove_red_eye, color: Colors.white, size: 60),
                  SizedBox(width: 16),
                  Text(
                    'Eye Break',
                    style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const Text(
                'Look 6 meters away',
                style: TextStyle(color: Colors.white70, fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Text(
                '$_remaining',
                style: const TextStyle(color: Colors.white, fontSize: 120, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              const Text(
                'Relax your eyes and focus on distant objects',
                style: TextStyle(color: Colors.white60, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  TimerStatus status = TimerStatus.idle;
  TimerPhase currentPhase = TimerPhase.work;
  Timer? _ticker;
  Timer? _eyeProtectorTimer;
  Duration remaining = Duration.zero;
  int countdownValue = 3;

  final AudioPlayer _player = AudioPlayer();
  final ApiService _apiService = ApiService();

  // Cycle tracking
  int currentCycle = 1;
  int currentInterval = 1;
  bool isCompleted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final app = AppStateScope.of(context);
      _startTimerAutomatically(app);
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _eyeProtectorTimer?.cancel();
    _player.dispose();
    // End work session prematurely - so backend resets timer value
    _apiService.endWork();
    super.dispose();
  }

  Future<void> _startPauseNotification(AppState app, PauseType type) async {
    int minutes = type == PauseType.shortBreak ? app.shortBreakMinutes : app.longBreakMinutes;
    int pauseNumber = type == PauseType.shortBreak ? currentInterval - 1 : currentCycle;

    final result = await _apiService.startPause(
      type: type,
      minutes: minutes,
      cycle: currentCycle,
      pauseNumber: pauseNumber,
    );

    if (result != null && result['success'] == true) {
      Logger.log('Pause notification started: $type for $minutes minutes');
    }
  }

  Future<void> _endPause() async {
    final result = await _apiService.endPause(pauseType: currentPhase == TimerPhase.shortBreak ? PauseType.shortBreak : PauseType.longBreak);
    if (result != null && result['success'] == true) {
      Logger.log('Pause notification cancelled');
    }
  }

  void _startTimerAutomatically(AppState app) {
    _ticker?.cancel();
    _resetToWork(app);

    // Send work started notification
    _apiService.startWork();

    if (app.enableCountdown) {
      status = TimerStatus.countdown;
      countdownValue = 3;
      _startCountdown(app);
    } else {
      status = TimerStatus.running;
      _startTimer(app);
    }
    setState(() {});
  }

  void _startCountdown(AppState app) {
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (countdownValue <= 1) {
        t.cancel();
        status = TimerStatus.running;
        _startTimer(app);
      } else {
        setState(() => countdownValue--);
      }
    });
  }

  Future<void> _playSound({required TimerSound sound}) async {
    // I dont get why play needs to call source everytime i want to play it...
    await _player.play(UrlSource(sound.path));
  }

  void _resetToWork(AppState app) {
    currentPhase = TimerPhase.work;
    remaining = Duration(minutes: app.workMinutes);
    currentCycle = 1;
    currentInterval = 1;
    isCompleted = false;
  }

  void _startTimer(AppState app) {
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (remaining.inSeconds <= 1) {
        t.cancel();
        _eyeProtectorTimer?.cancel();
        _onPhaseComplete(app);
      } else {
        setState(() => remaining -= const Duration(seconds: 1));
      }
    });

    // Start eye protector timer if enabled, in work phase, and work time >= eye focus duration
    if (app.enableEyeProtector && currentPhase == TimerPhase.work && app.workMinutes >= app.eyeProtectorWorkMinutes) {
      _startEyeProtectorTimer(app);
    }
  }

  void _startEyeProtectorTimer(AppState app) {
    _eyeProtectorTimer?.cancel();
    final remainingSeconds = app.workMinutes * 60 - remaining.inSeconds;
    final eyeProtectorInterval = app.eyeProtectorWorkMinutes * 60;

    // Calculate when to show the next eye protector reminder
    final nextReminderIn = eyeProtectorInterval - (remainingSeconds % eyeProtectorInterval);

    _eyeProtectorTimer = Timer(Duration(seconds: nextReminderIn), () {
      if (!mounted) return;
      if (status == TimerStatus.running && currentPhase == TimerPhase.work) {
        _showEyeProtectorDialog(app);
      }
    });
  }

  void _showEyeProtectorDialog(AppState app) async {
    // Play sound
    _playSound(sound: TimerSound.workEnd);

    // Bring window to front
    appWindow.show();

    // Show blocking dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black,
      builder: (_) => WillPopScope(
        onWillPop: () async => false, // Prevent any dismissal attempts
        child: _EyeBreakDialog(
          breakDuration: app.eyeProtectorBreakDurationSeconds,
          onComplete: () async {
            Navigator.of(context).pop();

            // Play completion sound
            _playSound(sound: TimerSound.workStart);

            // Restart the eye protector timer
            _startEyeProtectorTimer(app);
          },
        ),
      ),
    );
  }

  void _onPhaseComplete(AppState app) {
    if (isCompleted) return;

    // Cancel eye protector timer
    _eyeProtectorTimer?.cancel();

    if (currentPhase == TimerPhase.work) {
      // Check if this was the last interval of the last cycle
      if (currentInterval >= app.intervalsUntilLongBreak && currentCycle >= app.totalCycles) {
        setState(() {
          remaining = Duration.zero;
          status = TimerStatus.idle;
          isCompleted = true;
        });
        if (app.enableNotifications) {
          NotificationService().showSessionCompletedNotification();
        }
        // Play the work end sound
        _playSound(sound: TimerSound.workEnd);
        return;
      }

      // Check if this was the last interval of current cycle
      if (currentInterval >= app.intervalsUntilLongBreak) {
        // Move to long break
        currentPhase = TimerPhase.longBreak;
        remaining = Duration(minutes: app.longBreakMinutes);
        currentCycle++;
        currentInterval = 1;
        if (app.enableNotifications) {
          NotificationService().showLongBreakStartedNotification();
        }
        // Start pause notification
        _startPauseNotification(app, PauseType.longBreak);
        // Play the long break start sound
        _playSound(sound: TimerSound.workEnd);
      } else {
        // Move to short break
        currentPhase = TimerPhase.shortBreak;
        remaining = Duration(minutes: app.shortBreakMinutes);
        currentInterval++;
        if (app.enableNotifications) {
          NotificationService().showShortBreakStartedNotification();
        }
        // Start pause notification
        _startPauseNotification(app, PauseType.shortBreak);
        _playSound(sound: TimerSound.workEnd);
      }
    } else {
      // Cancel pause notification
      _endPause();
      // Break finished, move to work
      currentPhase = TimerPhase.work;
      remaining = Duration(minutes: app.workMinutes);
      if (app.enableNotifications) {
        NotificationService().showWorkStartedNotification();
      }

      _playSound(sound: TimerSound.workStart);
    }

    if (status == TimerStatus.running) {
      _startTimer(app);
    }
    setState(() {});
  }

  void _togglePause(AppState app) {
    if (status == TimerStatus.running) {
      _ticker?.cancel();
      _eyeProtectorTimer?.cancel();
      setState(() => status = TimerStatus.paused);
    } else if (status == TimerStatus.paused) {
      status = TimerStatus.running;
      _startTimer(app);
      setState(() {});
    }
  }

  void _stop() {
    _ticker?.cancel();
    _eyeProtectorTimer?.cancel();
    Navigator.of(context).pop(); // Navigate back to home screen
  }

  String _format(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hh = d.inHours;
    return hh > 0 ? '$hh:$mm:$ss' : '$mm:$ss';
  }

  String _getPhaseText() {
    if (isCompleted) return 'Completed!';
    if (status == TimerStatus.countdown) return 'Get Ready...';
    switch (currentPhase) {
      case TimerPhase.work:
        return 'Work - Cycle $currentCycle, Interval $currentInterval';
      case TimerPhase.shortBreak:
        return 'Short Break - Cycle $currentCycle';
      case TimerPhase.longBreak:
        return 'Long Break - Cycle ${currentCycle - 1} Complete';
    }
  }

  Color _getPhaseColor(AppState app) {
    if (isCompleted) return Colors.blueGrey;
    if (status == TimerStatus.countdown) return Colors.orange;
    switch (currentPhase) {
      case TimerPhase.work:
        return app.workColor;
      case TimerPhase.shortBreak:
        return app.shortBreakColor;
      case TimerPhase.longBreak:
        return app.longBreakColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    final bg = _getPhaseColor(app);

    String displayText;
    if (status == TimerStatus.countdown) {
      displayText = countdownValue.toString();
    } else {
      final display = remaining == Duration.zero ? Duration(minutes: app.workMinutes) : remaining;
      displayText = _format(display);
    }

    return Scaffold(
      appBar: PreferredSize(preferredSize: Size.fromHeight(30), child: TopBarWidget(showSettings: false)),
      backgroundColor: bg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getPhaseText(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              displayText,
              style: TextStyle(
                color: Colors.white,
                fontSize: status == TimerStatus.countdown ? 120 : 72,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: (status == TimerStatus.running || status == TimerStatus.paused) ? () => _togglePause(app) : null,
                  icon: Icon(status == TimerStatus.paused ? Icons.play_arrow : Icons.pause),
                  label: Text(status == TimerStatus.paused ? 'Resume' : 'Pause'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _stop,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
