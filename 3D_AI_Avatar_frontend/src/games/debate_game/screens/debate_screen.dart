// lib/screens/debate_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/debate_provider.dart';
import '../widgets/debate_timer.dart';
import '../widgets/topic_selection.dart';
import '../widgets/feedback_panel.dart';
import '../widgets/debate_input_bar.dart';
import 'dart:html' as html;
class DebateScreen extends StatelessWidget {
  const DebateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DebateProvider>(context);
    final state = provider.state;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8F6135), Color(0xFFF9BE1A)],
            transform: GradientRotation(19 * 3.14159 / 180),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'BabAIlon Debate Game',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(child: _buildMainContent(context, state)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, DebateState state) {
    final provider = Provider.of<DebateProvider>(context, listen: false);

    switch (state) {
      case DebateState.initial:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.question_answer, size: 100, color: Colors.yellow[700]),
              const SizedBox(height: 24),
              provider.isLoadingTopic
                  ? const CircularProgressIndicator(color: Colors.white)
                  : ElevatedButton(
                      onPressed: provider.generateRandomTopic,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFF9BE1A),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                      ),
                      child: const Text('Start Debate Game',
                          style: TextStyle(fontSize: 18)),
                    ),
            ],
          ),
        );

      case DebateState.topicSelection:
        return provider.isLoadingTopic
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 12),
                    Text("Generating topic...",
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
              )
            : const TopicSelection();

      case DebateState.userDebating:
      case DebateState.aiDebating:
        return const DebateArena();

      case DebateState.feedback:
        return const FeedbackPanel();

      case DebateState.completed:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, size: 100, color: Colors.yellow[700]),
              const SizedBox(height: 24),
              const Text(
                'Debate Completed!',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () =>
                    Provider.of<DebateProvider>(context, listen: false)
                        .restartDebate(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFF9BE1A),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Start New Debate',
                    style: TextStyle(fontSize: 18)),
              ),
              ElevatedButton(
              onPressed: () {
                 final finalScore = provider.userTotalScore/3;
                final fullUrl = html.window.location.href;
                final uri = Uri.parse(fullUrl);
                final fragment = uri.fragment;

                // Initialize parameters as null
                String? userEmail;
                String? userLang;
                String? origin;
                String? vocabulary_score;
                String? grammer_score;

                // Check if the URL fragment contains query parameters
                if (fragment.contains('?')) {
                  final fragParams = fragment.split('?')[1];
                  final params = Uri.splitQueryString(fragParams);

                  // Extract the parameters from the URL
                  userEmail = params['email'];
                  userLang = params['lang'];
                  origin = params['origin'];
                  vocabulary_score = params['vocabulary_score'];
                  grammer_score = params['grammer_score'];
                }

                // Build the base URL
                final baseUrl = '${html.window.location.origin}';
                String urlString =
                    'http://localhost:5173/?email=$userEmail&lang=$userLang&origin=$baseUrl';

                // Add vocabulary_score and pronounciation_score if available
                if (vocabulary_score != null) {
                  urlString += '&vocabulary_score=$vocabulary_score';
                }
                if (grammer_score != null) {
                  urlString += '&pronounciation_score=$grammer_score';
                }

                // Always add grammar score
                final pronounciation_score = '$finalScore';
                urlString += '&pronounciation_score=$pronounciation_score';

                // Parse the URL and redirect
                final url = Uri.parse(urlString);
                html.window.location.href =
                    url.toString(); // Redirect to the generated URL
              
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 201, 167, 17),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              child: const Text('Cancel',
                  style: TextStyle(fontSize: 16)),
            ),
            ],
          ),
        );
    }
  }
}

class DebateArena extends StatelessWidget {
  const DebateArena({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DebateProvider>(context);
    final isUserTurn = provider.state == DebateState.userDebating;
    final currentRound = provider.currentRound;
    final totalRounds = provider.totalRounds;

    // Grab last AI speech text if available:
    final lastAiText =
        provider.aiArguments.isNotEmpty ? provider.aiArguments.last.text : null;

    return Column(
      children: [
        const SizedBox(height: 8),

        // Topic + round
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(provider.currentTopic?.topic ?? '',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('Round $currentRound of $totalRounds',
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Avatar
        // Center(
        //   child: SizedBox(
        //     height: 180,
        //     child: AvatarWidget(
        //       isUser: false,
        //       text: lastAiText,
        //       emotion: null, // hook this up if you add emotion detection
        //       avatarId: provider.avatarId,
        //     ),
        //   ),
        // ),

        const SizedBox(height: 8),

        // Chat bubbles
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: ListView.builder(
              reverse: true,
              itemCount: provider.combinedArguments.length,
              itemBuilder: (context, index) {
                final msg = provider.combinedArguments.reversed.toList()[index];
                final isUser = msg['isUser'] as bool;
                return Align(
                  alignment:
                      isUser ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.white : Colors.yellow[100],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(isUser ? 16 : 4),
                        topRight: Radius.circular(isUser ? 4 : 16),
                        bottomLeft: const Radius.circular(16),
                        bottomRight: const Radius.circular(16),
                      ),
                    ),
                    child: Text(msg['text'] as String),
                  ),
                );
              },
            ),
          ),
        ),

        // Timer + input
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Column(
            children: [
              if (isUserTurn) DebateTimer(key: ValueKey(currentRound)),
              const DebateInputBar(),
            ],
          ),
        ),
      ],
    );
  }
}
