// lib/services/api_service.dart
import 'package:flutter_gemini/flutter_gemini.dart';
import '../models/debate_argument.dart';
import '../models/debate_topic.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final Gemini _gemini = Gemini.instance;

  // Utility function to call Gemini API
  Future<Map<String, dynamic>> sendToChat(String prompt) async {
    try {
      final result = await _gemini.text(prompt);
      final text = result?.output
              ?.replaceAll(RegExp(r'[*\u2022\-]+\s*'), '')
              .replaceAll(RegExp(r'\s+'), ' ')
              .trim() ??
          'Sorry, something went wrong.';
      print("✅ Gemini API success: $text");
      return {
        'text': text,
        'audio': null,
        'lipsync': null,
        'facialExpression': null,
      };
    } catch (e) {
      print('❌ Error calling Gemini API: $e');
      return {
        'text': 'Sorry, something went wrong.',
        'audio': null,
        'lipsync': null,
        'facialExpression': null,
      };
    }
  }

  // Generate a random debate topic
  Future<DebateTopic> generateRandomTopic() async {
    return await _generateTopicWithPrompt(
      "Suggest a debate topic suitable for regular users (not experts).\n"
      "Avoid advanced legal, scientific, or philosophical terms.\n"
      "Topic should be short (under 10 words), and description brief (1-2 lines).\n"
      "Format:\n"
      "Topic: <short topic>\n"
      "Description: <short description>",
      fallback: DebateTopic(
        topic: "Should phones be banned in class?",
        description: "Are phones too distracting for students during lessons?",
      ),
    );
  }

  // Generate an alternative debate topic
  Future<DebateTopic> generateAlternativeTopic() async {
    return await _generateTopicWithPrompt(
      "Give another simple, relatable debate topic.\n"
      "Avoid complex or technical subjects.\n"
      "Keep it short and casual.\n"
      "Format:\n"
      "Topic: <short>\n"
      "Description: <1-2 line explanation>",
      fallback: DebateTopic(
        topic: "Should uniforms be required?",
        description: "Do school uniforms help or hurt student freedom?",
      ),
    );
  }

  // Helper to parse topic/description or fallback
  Future<DebateTopic> _generateTopicWithPrompt(String prompt,
      {required DebateTopic fallback}) async {
    try {
      final result = await sendToChat(prompt);
      final responseText = (result['text'] ?? '').replaceAll('\n', ' ');
      print("🧪 Gemini topic response: $responseText");

      final match = RegExp(r'Topic:\s*(.+?)\s*Description:\s*(.+)',
              caseSensitive: false, dotAll: true)
          .firstMatch(responseText);

      if (match != null) {
        final topic = match.group(1)?.trim() ?? '';
        final description = match.group(2)?.trim() ?? '';
        if (topic.isNotEmpty && description.isNotEmpty) {
          return DebateTopic(topic: topic, description: description);
        }
      }
      throw Exception("Failed to parse topic or description");
    } catch (_) {
      print('❌ Fallback to default topic');
      return fallback;
    }
  }

  // Analyze the user's argument and provide feedback
  Future<DebateArgument> analyzeUserArgument(String text, String topic) async {
    try {
      final result = await sendToChat(
          "You're a friendly debate coach for beginners.\n"
          "Given the topic '$topic' and the user's argument: \"$text\",\n"
          "Give a score (0–100), a short improvement tip, and a clearer version.\n"
          "Avoid complex advice.\n"
          "Format:\n"
          "Score: <number>\n"
          "Improvement: <2 short sentences>\n"
          "HowToSayBetter: <simplified version>");

      // Pull the raw text
      final raw = result['text'] ?? '';
      print("🧪 Raw analysis response: $raw");

// Single regex to capture score, improvement, and rephrasing
      final match = RegExp(
        r'Score:\s*(\d+)\s*Improvement:\s*(.+?)\s*HowToSayBetter:\s*(.+)',
        caseSensitive: false,
        dotAll: true,
      ).firstMatch(raw);

      if (match != null) {
        final score = double.parse(match.group(1)!);
        final improve = match.group(2)!.trim();
        final better = match.group(3)!.trim();
        return DebateArgument(
          text: text,
          score: score,
          strongWords: [],
          feedback: "$improve\n\n$better",
        );
      }

// Fallback if regex doesn’t match
      return DebateArgument(
        text: text,
        score: 50.0,
        strongWords: [],
        feedback: 'Could not analyze. Try writing a clearer opinion.',
      );
    } catch (e) {
      print('❌ Error analyzing argument: $e');
      return DebateArgument(
        text: text,
        score: 50.0,
        strongWords: [],
        feedback: 'Could not analyze. Try writing a clearer opinion.',
      );
    }
  }

  // Generate the AI counterargument
  Future<DebateArgument> generateAIResponse(
      String topic, String userArgument) async {
    try {
      final result = await sendToChat(
          "You're an AI debater in a friendly debate.\n"
          "Topic: $topic\n"
          "User's argument: \"$userArgument\"\n"
          "Reply with a short, clear counterargument using simple language.\n"
          "Then rate your counter from 0 to 100.\n"
          "Format:\n"
          "Counterargument: <reply>\n"
          "Score: <number>");

      // Pull the raw text
      final text = result['text'] ?? '';
      print("🧪 Raw counter response: $text");

// Try one regex to get both pieces in one go:
      final match = RegExp(
        r'Counterargument:\s*(.+?)\s*Score:\s*(\d+)',
        caseSensitive: false,
        dotAll: true,
      ).firstMatch(text);

      if (match != null) {
        final counter = match.group(1)!.trim();
        final score = double.parse(match.group(2)!);
        return DebateArgument(
          text: counter,
          score: score,
          strongWords: [],
          feedback: '',
        );
      }

// If regex fails, at least return the raw text as the counterargument:
      return DebateArgument(
        text: text,
        score: 70.0,
        strongWords: [],
        feedback: '',
      );
    } catch (e) {
      print('❌ Error generating AI counter: $e');
      return DebateArgument(
        text: "Interesting point! But let's also consider the other side.",
        score: 70.0,
        strongWords: [],
        feedback: '',
      );
    }
  }

  // Generate final feedback after the debate
  Future<String> generateFinalFeedback(
      List<DebateArgument> userArguments, double totalScore, int rounds) async {
    try {
      final average = (totalScore / rounds).clamp(0, 100).toStringAsFixed(1);
      final allArgs = userArguments.map((a) => "- ${a.text}").join("\n");

      final result = await sendToChat("You are a helpful debate coach.\n"
          "User's average score: $average out of 100.\n"
          "Here are their arguments:\n$allArgs\n"
          "Give 3 short tips (max 2 lines each) for improvement. Avoid academic or expert advice.");

      return result['text'] ?? "You scored $average/100. Good job!";
    } catch (e) {
      print('❌ Error in final feedback: $e');
      return "Final score: ${(totalScore / rounds).toStringAsFixed(1)}/100.";
    }
  }
}
