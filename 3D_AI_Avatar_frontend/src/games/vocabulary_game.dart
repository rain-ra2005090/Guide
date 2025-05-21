import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'image_data.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html;

const geminiApiKey = 'AIzaSyC-3BVadcuZuaWq78JBMuMYhMmdF7wSRfc';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Gemini.init(apiKey: geminiApiKey);
  runApp(const VGame());
}

class VGame extends StatelessWidget {
  const VGame({super.key});
  @override
  Widget build(BuildContext ctx) {
    return MaterialApp(
      title: 'Vocabulary Game',
      theme: ThemeData(
        // AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFD4AF37),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.black87),
        ),
        // All elevated buttons get black text
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black87, // button text
            backgroundColor: Colors.white, // button fill
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.black87,
          ),
        ),
      ),
      home: const VocabularyGame(),
    );
  }
}

class VocabularyGame extends StatefulWidget {
  const VocabularyGame({super.key});
  @override
  State<VocabularyGame> createState() => _VocabularyGameState();
}

class _VocabularyGameState extends State<VocabularyGame> {
  late Future<List<ImageData>> _imagesFut;
  final _controller = TextEditingController();
  final _tts = FlutterTts();

  List<double> _scores = [];
  int _idx = 0;
  bool _thinking = false;
  String? _suggestion;

  // late String? userEmail;
  // late String? userLang;
  // late String? origin;

  // @override
  // void initState() {
  //   super.initState();

  //   final fullUrl = html.window.location.href;
  //   final uri = Uri.parse(fullUrl);
  //   final fragment = uri.fragment;

  //   if (fragment.contains('?')) {
  //     final fragParams = fragment.split('?')[1]; // get only the query part
  //     final params = Uri.splitQueryString(fragParams);

  //     userEmail = params['email'];
  //     userLang = params['lang'];
  //     origin = params['origin'];
  //   }

  //   print('Full URL: $fullUrl');
  //   print('Email: $userEmail, Lang: $userLang');

  //   _imagesFut = ImageData.loadAll();
  // }
  late String? userEmail;
  late String? userLang;
  late String? origin;
  late String? pronounciation_score;
  late String? grammar_score;

  @override
  void initState() {
    super.initState();

    final fullUrl = html.window.location.href;
    final uri = Uri.parse(fullUrl);
    final fragment = uri.fragment;

    if (fragment.contains('?')) {
      final fragParams = fragment.split('?')[1]; // get only the query part
      final params = Uri.splitQueryString(fragParams);

      userEmail = params['email'];
      userLang = params['lang'];
      origin = params['origin'];
      pronounciation_score =
          params['pronounciation_score']; // pronounciation_score
      grammar_score = params['grammer_score']; // grammar_score
    }

    print('Full URL: $fullUrl');
    print('Email: $userEmail, Lang: $userLang');
    print(
        'Pronunciation Score: $pronounciation_score, Grammar Score: $grammar_score');

    _imagesFut = ImageData.loadAll();
  }

  double _computeScore(String user, String reference) {
    final userWords = user
        .toLowerCase()
        .split(RegExp(r'\W+'))
        .where((w) => w.isNotEmpty)
        .toSet();
    final refWords = reference
        .toLowerCase()
        .split(RegExp(r'\W+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (refWords.isEmpty) return 0;
    final matches = refWords.where((w) => userWords.contains(w)).length;
    return (matches / refWords.length * 100).roundToDouble();
  }

  Future<void> _submit(ImageData img) async {
    final userText = _controller.text.trim();
    if (userText.isEmpty) return;

    setState(() => _thinking = true);

    // score
    final score = _computeScore(userText, img.description);
    _scores.add(score);

    // AI suggestion
    final prompt = """
The user sees an image described as: "${img.description}".
The user attempted to describe it as: "${userText}".
Suggest synonyms, alternative words, or expanded phrases to help the user learn more vocabulary.
Provide concise vocabulary suggestions (e.g., synonyms or alternative phrases) to improve the description. between 15 and 20 word for the whole suggestion. 
sentence like: "Instead of X, you can say: Y, or Z,"
sentence like: "the image show x and y "

""";
    try {
      final res = await Gemini.instance.text(prompt);
      _suggestion =
          res?.output?.trim() ?? 'Sorry, I couldn’t think of anything.';
      await _tts.speak(_suggestion!);
    } catch (e) {
      _suggestion = 'Error: $e';
    } finally {
      setState(() => _thinking = false);
    }
  }

  void _next(List<ImageData> imgs) {
    if (_idx < imgs.length - 1) {
      setState(() {
        _idx++;
        _controller.clear();
        _suggestion = null;
      });
    } else {
      // finished → show final average
      final average = _scores.isEmpty
          ? 0
          : (_scores.reduce((a, b) => a + b) / _scores.length).roundToDouble();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Game Over!'),
          content: Text(
              'Your final score is: $average%\n\nGreat job!\nKeep it up, you can do even better =)'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _scores.clear();
                  _idx = 0;
                  _controller.clear();
                  _suggestion = null;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Play Again'),
            ),
            TextButton(
              onPressed: () async {
                final baseUrl = '${html.window.location.origin}';

                // Start building the base URL
                String urlString =
                    'http://localhost:5173/?email=$userEmail&lang=$userLang&origin=$baseUrl&vocabulary_score=${average.toStringAsFixed(2)}';

                // Add pronunciation_score if available
                if (pronounciation_score != null) {
                  urlString += '&pronounciation_score=$pronounciation_score';
                }

                // Add grammar_score if available
                if (grammar_score != null) {
                  urlString += '&grammer_score=$grammar_score';
                }

                // Parse the URL and redirect
                final url = Uri.parse(urlString);
                html.window.location.href =
                    url.toString(); // Redirect to the generated URL
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vocabulary Game')),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFD4AF37),
              Color(0xFFB8860B),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<ImageData>>(
          future: _imagesFut,
          builder: (ctx, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final imgs = snap.data!;
            final img = imgs[_idx];

            return Column(
              children: [
                Expanded(
                  child: Image.asset(
                    img.image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    controller: _controller,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      hintText: 'Describe what you see…',
                    ),
                  ),
                ),
                if (_thinking)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: LinearProgressIndicator(),
                  ),
                if (_suggestion != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(blurRadius: 4, color: Colors.black26)
                      ],
                    ),
                    child: Text(_suggestion!),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _thinking ? null : () => _submit(img),
                      child: const Text('Submit'),
                    ),
                    ElevatedButton(
                      onPressed: () => _next(imgs),
                      child: const Text('Next Image'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            );
          },
        ),
      ),
    );
  }
}
