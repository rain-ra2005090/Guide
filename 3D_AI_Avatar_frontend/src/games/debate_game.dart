import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DebateGameScreen extends StatelessWidget {
  const DebateGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouterState state = GoRouter.of(context).state;
    final Uri uri = state.uri;  
    final String origin = uri.queryParameters['origin'] ?? '';
    final String lang = uri.queryParameters['lang'] ?? '';
    final String email = uri.queryParameters['email'] ?? '';
    final String grammarScore = uri.queryParameters['vocbaulary_score'] ?? '0'; 
    
    final int pronunciationScore = 60; 
    final int fluencyScore = 20;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Debate Game"),
        backgroundColor: Colors.brown,
        actions: [
          TextButton(
            onPressed: () {
              context.go('/sentence_scramble?origin=$origin&lang=$lang&email=$email&grammar_score=$grammarScore&pronunciation_score=$pronunciationScore&fluency_score=$fluencyScore');
            },
            child: const Text(
              "Next Game",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 40), 
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.black, 
                    ),
                    Container(
                      width: 40,
                      height: 2,
                      color: Colors.grey,
                    ),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.black, 
                    ),
                    Container(
                      width: 40,
                      height: 2,
                      color: Colors.grey, 
                    ),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey, 
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Vocabulary Game', style: TextStyle(fontSize: 14, color: Colors.brown)),
                    SizedBox(width: 20),
                    Text('Debate Game', style: TextStyle(fontSize: 14, color: Colors.brown)),
                    SizedBox(width: 20),
                    Text('Sentence Scramble', style: TextStyle(fontSize: 14, color: Colors.brown)),
                  ],
                ),
              ],
            ),
          ),

          Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            child: ElevatedButton(
              onPressed: () {
                context.go('/sentence_scramble?origin=$origin&lang=$lang&email=$email&vocbaulary_score=$grammarScore&pronunciation_score=$pronunciationScore&fluency_score=$fluencyScore');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown, 
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Next Game",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Debate Game Coming Soon!",
                    style: TextStyle(fontSize: 20, color: Colors.brown), 
                  ),
                  SizedBox(height: 20),
                
                  Text(
                    "Pronunciation Score: $pronunciationScore",
                    style: TextStyle(fontSize: 18, color: Colors.brown), 
                  ),
                  Text(
                    "Fluency Score: $fluencyScore",
                    style: TextStyle(fontSize: 18, color: Colors.brown),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.brown[50], 
    );
  }
}
