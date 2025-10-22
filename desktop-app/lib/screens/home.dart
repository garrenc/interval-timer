import 'package:flutter/material.dart';
import 'package:interval_timer/components/top_bar.dart';
import 'package:interval_timer/components/interval_picker.dart';
import 'package:interval_timer/screens/timer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: PreferredSize(preferredSize: Size.fromHeight(30), child: TopBarWidget()),
      body: SizedBox(
        width: width,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 30),
              Text(
                'Interval Timer',

                style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              const IntervalPickerGroup(),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start'),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TimerScreen())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
