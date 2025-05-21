import 'package:flutter/material.dart';

class SpeechBubble extends StatelessWidget {
  final String text;
  final bool isActive;
  final bool isUser;

  const SpeechBubble({
    super.key,
    required this.text,
    required this.isActive,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive 
            ? Colors.white 
            : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: isActive 
            ? Border.all(
                color: isUser 
                    ? const Color(0xFF8F6135) 
                    : const Color(0xFFF9BE1A),
                width: 2,
              )
            : null,
        boxShadow: isActive 
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ] 
            : null,
      ),
      child: SingleChildScrollView(
        child: Text(
          text.isEmpty ? (isUser ? 'Your argument will appear here...' : 'AI response will appear here...') : text,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontStyle: text.isEmpty ? FontStyle.italic : FontStyle.normal,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
