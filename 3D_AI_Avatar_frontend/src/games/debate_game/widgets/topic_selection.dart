import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/debate_provider.dart';

class TopicSelection extends StatelessWidget {
  const TopicSelection({super.key});

  @override
  Widget build(BuildContext context) {
    final debateProvider = Provider.of<DebateProvider>(context);
    final currentTopic = debateProvider.currentTopic;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Debate Topic',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8F6135),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  currentTopic?.topic ?? 'Loading topic...',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  currentTopic?.description ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Provider.of<DebateProvider>(context, listen: false)
                            .suggestAlternativeTopic();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: const Text('New Topic'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Provider.of<DebateProvider>(context, listen: false)
                            .acceptTopic();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF9BE1A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Accept Topic'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
