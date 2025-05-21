import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/debate_provider.dart';
import 'speech_recognition.dart';

class DebateInputBar extends StatelessWidget {
  const DebateInputBar({super.key});

  @override
  Widget build(BuildContext context) {
    final debateProvider = Provider.of<DebateProvider>(context);
    final isUserTurn = debateProvider.state == DebateState.userDebating;

    final controller = TextEditingController.fromValue(
      TextEditingValue(
        text: debateProvider.transcribedText,
        selection: TextSelection.collapsed(
          offset: debateProvider.transcribedText.length,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 📝 Text input
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: debateProvider.updateTranscribedText,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  debateProvider.submitUserArgument();
                  debateProvider.setListening(false);
                }
              },
              decoration: InputDecoration(
                hintText: 'Type your argument...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              minLines: 1,
              maxLines: 3,
              textInputAction: TextInputAction.send,
            ),
          ),

          const SizedBox(width: 8),

          // 🎙️ Mic button
          const SpeechRecognitionButton(),

          const SizedBox(width: 8),

          // 📨 Send button
          GestureDetector(
            onTap: () {
              final text = debateProvider.transcribedText.trim();
              if (text.isNotEmpty && isUserTurn) {
                debateProvider.submitUserArgument();
                debateProvider.setListening(false);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Color(0xFFF9BE1A)),
            ),
          ),
        ],
      ),
    );
  }
}
