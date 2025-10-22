import 'package:flutter/material.dart';
import 'package:interval_timer/services/app_state.dart';

class IntervalPicker extends StatefulWidget {
  final String title;
  final int minutes;
  final Function(int) onChanged;

  const IntervalPicker({
    super.key,
    required this.title,
    required this.minutes,
    required this.onChanged,
  });

  @override
  State<IntervalPicker> createState() => _IntervalPickerState();
}

class _IntervalPickerState extends State<IntervalPicker> {
  bool _editing = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.minutes.toString());
  }

  @override
  void didUpdateWidget(IntervalPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.minutes != oldWidget.minutes && _editing) {
      _controller.text = widget.minutes.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          widget.title,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () {
            setState(() {
              _editing = true;
              _controller.text = widget.minutes.toString();
            });
          },
          child: _editing
              ? SizedBox(
                  width: 60,
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 2),
                      border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                    ),
                    onSubmitted: (value) {
                      final parsed = int.tryParse(value.trim());
                      if (parsed != null && parsed > 0) {
                        widget.onChanged(parsed);
                      }
                      setState(() {
                        _editing = false;
                      });
                    },
                    onEditingComplete: () {
                      setState(() {
                        _editing = false;
                      });
                    },
                  ),
                )
              : Text(
                  '${widget.minutes}',
                  style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                ),
        ),
        const SizedBox(height: 2),
        const Text(
          'min',
          style: TextStyle(color: Colors.white60, fontSize: 10),
        ),
        const SizedBox(height: 6),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white24,
            thumbColor: Colors.white,
            overlayColor: Colors.white.withValues(alpha: 0.2),
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: widget.minutes.toDouble().clamp(1.0, 120.0),
            min: 1,
            max: 120,
            label: '${widget.minutes}',
            onChanged: (v) => widget.onChanged(v.round()),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class IntervalPickerGroup extends StatelessWidget {
  const IntervalPickerGroup({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IntervalPicker(
          title: 'Work Time',
          minutes: appState.workMinutes,
          onChanged: appState.updateWorkMinutes,
        ),
        IntervalPicker(
          title: 'Short Break',
          minutes: appState.shortBreakMinutes,
          onChanged: appState.updateShortBreakMinutes,
        ),
        IntervalPicker(
          title: 'Long Break',
          minutes: appState.longBreakMinutes,
          onChanged: appState.updateLongBreakMinutes,
        ),
        const SizedBox(height: 16),
        _buildNumberPicker(
          title: 'Intervals until long break',
          value: appState.intervalsUntilLongBreak,
          onChanged: appState.updateIntervalsUntilLongBreak,
          min: 1,
          max: 10,
        ),
        _buildNumberPicker(
          title: 'Total cycles',
          value: appState.totalCycles,
          onChanged: appState.updateTotalCycles,
          min: 1,
          max: 4,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
          child: const Text(
            'Tap numbers to edit',
            style: TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberPicker({
    required String title,
    required int value,
    required Function(int) onChanged,
    required int min,
    required int max,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          '$value',
          style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        SliderTheme(
          data: const SliderThemeData(
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white24,
            thumbColor: Colors.white,
            overlayColor: Colors.white24,
            trackHeight: 3,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            label: '$value',
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
