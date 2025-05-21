import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/debate_screen.dart';
import 'providers/debate_provider.dart';
import 'secrets.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

void main() {
  Gemini.init(apiKey: Secrets.geminiApiKey); // 👈 Initialize Gemini here
  print('✅ Loaded Gemini API Key: ${Secrets.geminiApiKey}');
  runApp(const DebateGame());
}

class DebateGame extends StatelessWidget {
  const DebateGame({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DebateProvider(),
      child: MaterialApp(
        title: 'BabAIlon Debate Game',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFF9BE1A),
            primary: const Color(0xFFF9BE1A),
            secondary: const Color(0xFF8F6135),
          ),
          useMaterial3: true,
          fontFamily: 'Inter',
        ),
        home: const DebateScreen(),
      ),
    );
  }
}
