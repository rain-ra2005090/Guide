import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/debate_provider.dart';

class DebateTimer extends StatefulWidget {
  const DebateTimer({super.key});

  @override
  State<DebateTimer> createState() => _DebateTimerState();
}

class _DebateTimerState extends State<DebateTimer> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Delay the start by 10 seconds so user can read the AI response
    Future.delayed(const Duration(seconds: 10), _startTimer);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    final debateProvider = Provider.of<DebateProvider>(context, listen: false);

    // Ensure the round starts with 2 minutes (120 seconds)
    // (Make sure DebateProvider.initialize or acceptTopic sets remainingTime to 120)
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (debateProvider.remainingTime > 0) {
        debateProvider.updateRemainingTime(debateProvider.remainingTime - 1);
      } else {
        _timer?.cancel();
        debateProvider.submitUserArgument();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final remainingTime = Provider.of<DebateProvider>(context).remainingTime;
    final minutes = remainingTime ~/ 60;
    final seconds = remainingTime % 60;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.timer,
            color: Color(0xFFF9BE1A),
          ),
          const SizedBox(width: 8),
          Text(
            '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8F6135),
            ),
          ),
        ],
      ),
    );
  }
}
