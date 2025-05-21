import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'dart:html' as html;

const apiKey = 'AIzaSyD8l5nDB8hUD83Ot8wVvxZTLQeazFHLmEE';

// void main() {
//   Gemini.init(apiKey: apiKey);
//   WidgetsFlutterBinding.ensureInitialized();
//   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//   runApp(const MyApp());
// }

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sentence Scramble',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF9BE1A).withOpacity(0.2),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF9BE1A),
          primary: const Color(0xFFF9BE1A),
          secondary: const Color(0xFF8F6135),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF5D4037)),
          bodyMedium: TextStyle(color: Color(0xFF5D4037)),
        ),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final Color primaryColor = const Color(0xFF8F6135);
  final Color secondaryColor = const Color(0xFFF9BE1A);
  final Color goldColor = const Color(0xFFF9BE1A);

  late AnimationController _welcomeAnimationController;
  static const int sentencesPerLevel1 = 3;
  static const int sentencesPerLevel2 = 3;
  static const int sentencesPerLevel3 = 4;

  late String? userEmail;
  late String? userLang;
  late String? origin;
  late String? vocabulary_score;
  late String? pronounciation_score;

  @override
  void initState() {
    super.initState();
    final fullUrl = html.window.location.href;
    final uri = Uri.parse(fullUrl);
    final fragment = uri.fragment;

    if (fragment.contains('?')) {
      final fragParams = fragment.split('?')[1];
      final params = Uri.splitQueryString(fragParams);

      userEmail = params['email'];
      userLang = params['lang'];
      origin = params['origin'];
      vocabulary_score = params['vocabulary_score'];
      pronounciation_score = params['pronounciation_score'];
    }

    print('Full URL: $fullUrl');
    print('Email: $userEmail, Lang: $userLang');

    print('Full URL: $fullUrl');
    print(
        'Email: $userEmail, Lang: $userLang, Vocabulary Score: $vocabulary_score, Grammar Score: $pronounciation_score');
    _welcomeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _welcomeAnimationController.forward();
  }

  @override
  void dispose() {
    _welcomeAnimationController.dispose();
    super.dispose();
  }

  void _startGame() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SentenceScrambleGame()),
    );
  }

  Widget _buildInstructionStep({
    required IconData icon,
    required String text,
    required int index,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                index.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Icon(
                  icon,
                  color: primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelIndicator(String label, Color color, int sentenceCount) {
    return Column(
      children: [
        Container(
          width: 70,
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$sentenceCount sentences',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  // New welcome screen widget
  Widget _buildWelcomeScreen() {
    return AnimatedBuilder(
      animation: _welcomeAnimationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor,
                secondaryColor,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: SingleChildScrollView(
                child: Opacity(
                  opacity: _welcomeAnimationController.value,
                  child: Transform.scale(
                    scale: 0.8 + (0.2 * _welcomeAnimationController.value),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: goldColor, width: 2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Game logo/icon
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: goldColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(color: goldColor, width: 2),
                              ),
                              child: Icon(
                                Icons.psychology,
                                color: goldColor,
                                size: 60,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Game title
                            const Text(
                              'Sentence Scramble',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF9BE1A),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Game tagline
                            Text(
                              'Challenge Your Brain with Word Order!',
                              style: TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey.shade700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 30),
                            // Instructions title
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: goldColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'How To Play',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF5D4037),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // // Instructions
                            // _buildInstructionStep(
                            //   icon: Icons.headset,
                            //   text: 'Listen to the sentence carefully',
                            //   index: 1,
                            // ),
                            _buildInstructionStep(
                              icon: Icons.drag_indicator,
                              text:
                                  'Drag words from the bottom to the empty slots',
                              index: 1,
                            ),
                            _buildInstructionStep(
                              icon: Icons.text_format,
                              text: 'Arrange them to form a correct sentence',
                              index: 2,
                            ),
                            _buildInstructionStep(
                              icon: Icons.touch_app,
                              text: 'Tap placed words to return them if needed',
                              index: 3,
                            ),
                            _buildInstructionStep(
                              icon: Icons.check_circle,
                              text:
                                  'Answers are checked automatically when all slots are filled',
                              index: 4,
                            ),
                            const SizedBox(height: 24),
                            // Game levels info
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: goldColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: goldColor.withOpacity(0.3)),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'Game Levels',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF5D4037),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildLevelIndicator('Level 1',
                                          primaryColor, sentencesPerLevel1),
                                      _buildLevelIndicator(
                                          'Level 2',
                                          primaryColor.withOpacity(0.8),
                                          sentencesPerLevel2),
                                      _buildLevelIndicator('Level 3',
                                          secondaryColor, sentencesPerLevel3),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                            // Start button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: goldColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                icon: const Icon(Icons.play_arrow_rounded,
                                    size: 28),
                                label: const Text(
                                  'Start Game',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: _startGame,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildWelcomeScreen(),
    );
  }
}

class SentenceScrambleGame extends StatefulWidget {
  const SentenceScrambleGame({Key? key}) : super(key: key);

  @override
  State<SentenceScrambleGame> createState() => _SentenceScrambleGameState();
}

class IncorrectAnswer {
  final String sentence;
  final int level;
  bool reviewed;

  IncorrectAnswer({
    required this.sentence,
    required this.level,
    this.reviewed = false,
  });
}

class _SentenceScrambleGameState extends State<SentenceScrambleGame>
    with TickerProviderStateMixin {
  int score = 0;
  int currentSentenceIndex = 0;
  int currentLevel = 1;
  static const int sentencesPerLevel1 = 3;
  static const int sentencesPerLevel2 = 3;
  static const int sentencesPerLevel3 = 4;
  static const int totalLevels = 3;
  static const int pointsPerCorrectAnswer = 10;
  static const int totalSentences = 10;
  static const int maxScore = totalSentences * pointsPerCorrectAnswer;

  bool isGameOver = false;
  bool isLevelComplete = false;
  bool isChecking = false;
  String feedbackMessage = '';
  bool showFeedback = false;
  Color feedbackColor = const Color(0xFFF9BE1A);
  bool isLoading = true;
  bool allSlotsFilled = false;
  Timer? _autoCheckTimer;
  bool isReviewMode = false;
  bool showReviewModeTransition = false;
  List<IncorrectAnswer> incorrectAnswers = [];
  int currentReviewIndex = 0;

  List<List<bool>> levelResults = [
    List.filled(sentencesPerLevel1, false),
    List.filled(sentencesPerLevel2, false),
    List.filled(sentencesPerLevel3, false),
  ];
  List<int> levelScores = List.filled(totalLevels, 0);

  late AnimationController _feedbackAnimationController;
  late AnimationController _tileAnimationController;
  late AnimationController _celebrationAnimationController;
  late AnimationController _levelCompleteAnimationController;
  late AnimationController _reviewTransitionAnimationController;

  List<List<String>> levelSentences = [];
  List<String> currentScrambledWords = [];
  late List<String?> currentDroppedWords;
  late List<String> originalWords = [];
  final gemini = Gemini.instance;

  @override
  void initState() {
    super.initState();
    _feedbackAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _tileAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _celebrationAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _levelCompleteAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _reviewTransitionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fetchSentencesFromGemini();
  }

  @override
  void dispose() {
    _feedbackAnimationController.dispose();
    _tileAnimationController.dispose();
    _celebrationAnimationController.dispose();
    _levelCompleteAnimationController.dispose();
    _reviewTransitionAnimationController.dispose();
    _autoCheckTimer?.cancel();
    super.dispose();
  }

  int getSentencesForLevel(int level) {
    switch (level) {
      case 1:
        return sentencesPerLevel1;
      case 2:
        return sentencesPerLevel2;
      case 3:
        return sentencesPerLevel3;
      default:
        return 0;
    }
  }

  int getMaxScoreForLevel(int level) {
    return getSentencesForLevel(level) * pointsPerCorrectAnswer;
  }

  Future<void> _fetchSentencesFromGemini() async {
    setState(() => isLoading = true);
    try {
      final prompt = """
  Generate 10 simple, grammatically correct English sentences that would be good for a sentence scramble game. 
  Each sentence should be between 4-7 words to fit well on mobile screens.
  Make them interesting but not too complex.
  Make the sentences progressively more difficult:
  - First 3 sentences should be very simple (Level 1)
  - Next 3 sentences should be moderate difficulty (Level 2)
  - Last 4 sentences should be more challenging (Level 3)
  Return them as a numbered list with only the sentences.
  Do not include quotation marks or any other formatting.
  """;
      final result = await gemini.text(prompt);
      if (result != null && result.output != null) {
        List<String> allSentences = _processSentences(result.output!);
        if (allSentences.length >= 10) {
          setState(() {
            levelSentences = [
              allSentences.sublist(0, sentencesPerLevel1),
              allSentences.sublist(
                  sentencesPerLevel1, sentencesPerLevel1 + sentencesPerLevel2),
              allSentences.sublist(
                  sentencesPerLevel1 + sentencesPerLevel2, totalSentences)
            ];
            isLoading = false;
          });
          _startNewRound();
        } else {
          _useBackupSentences();
        }
      } else {
        _useBackupSentences();
      }
    } catch (e) {
      print('Error fetching from Gemini: $e');
      _useBackupSentences();
    }
  }

  List<String> _processSentences(String response) {
    List<String> sentences = [];
    List<String> lines = response.split('\n');
    for (String line in lines) {
      String processed = line.trim();
      RegExp numberPattern = RegExp(r'^\d+[\.\)]\s*');
      Match? match = numberPattern.firstMatch(processed);
      if (match != null) processed = processed.substring(match.end);
      processed = processed.replaceAll('"', '').replaceAll("'", "");
      if (processed.isNotEmpty) sentences.add(processed);
    }
    return sentences;
  }

  void _useBackupSentences() {
    setState(() {
      levelSentences = [
        [
          "The cat sleeps soundly",
          "Children play outside",
          "She reads books daily"
        ],
        [
          "Early birds catch worms",
          "All that glitters isn't gold",
          "Actions speak louder than words"
        ],
        [
          "Time flies like an arrow",
          "Begin with a single step",
          "Knowledge is true power",
          "The pen defeats the sword"
        ]
      ];
      isLoading = false;
      _startNewRound();
    });
  }

  String _getCurrentSentence() {
    return isReviewMode
        ? incorrectAnswers[currentReviewIndex].sentence
        : levelSentences[currentLevel - 1][currentSentenceIndex];
  }

  void _startNewRound() {
    if (isLevelComplete) {
      setState(() => isLevelComplete = false);
      _levelCompleteAnimationController.reset();
    }

    if (isReviewMode) {
      _startReviewRound();
      return;
    }

    if (currentLevel > totalLevels) {
      if (incorrectAnswers.isNotEmpty) {
        setState(() => showReviewModeTransition = true);
        _reviewTransitionAnimationController.forward();
        Timer(const Duration(seconds: 4), () {
          setState(() {
            showReviewModeTransition = false;
            isReviewMode = true;
            currentReviewIndex = 0;
            for (var answer in incorrectAnswers) answer.reviewed = false;
          });
          _startReviewRound();
        });
      } else {
        _celebrationAnimationController.forward();
        setState(() => isGameOver = true);
      }
      return;
    }

    String currentSentence = _getCurrentSentence();
    List<String> words = currentSentence.split(' ');
    List<String> scrambledWords = List.from(words);
    while (listEquals(scrambledWords, words)) scrambledWords.shuffle();

    setState(() {
      originalWords = words;
      currentScrambledWords = scrambledWords;
      currentDroppedWords = List<String?>.filled(words.length, null);
      showFeedback = false;
      allSlotsFilled = false;
      _tileAnimationController.reset();
    });
    _tileAnimationController.forward();
  }

  void _startReviewRound() {
    if (incorrectAnswers.isEmpty) {
      setState(() {
        isReviewMode = false;
        isGameOver = true;
      });
      return;
    }

    if (currentReviewIndex >= incorrectAnswers.length) {
      setState(() {
        isReviewMode = false;
        isGameOver = true;
      });
      _celebrationAnimationController.forward();
      return;
    }

    String currentSentence = incorrectAnswers[currentReviewIndex].sentence;
    List<String> words = currentSentence.split(' ');
    List<String> scrambledWords = List.from(words);
    while (listEquals(scrambledWords, words)) scrambledWords.shuffle();

    setState(() {
      originalWords = words;
      currentScrambledWords = scrambledWords;
      currentDroppedWords = List<String?>.filled(words.length, null);
      showFeedback = false;
      allSlotsFilled = false;
      _tileAnimationController.reset();
    });
    _tileAnimationController.forward();
  }

  void _checkAllSlotsFilled() {
    bool filled = !currentDroppedWords.contains(null);
    if (filled && !allSlotsFilled) {
      setState(() => allSlotsFilled = true);
      _autoCheckTimer?.cancel();
      _autoCheckTimer = Timer(const Duration(milliseconds: 500), _checkAnswer);
    } else if (!filled) {
      setState(() => allSlotsFilled = false);
      _autoCheckTimer?.cancel();
    }
  }

  void _checkAnswer() {
    if (currentDroppedWords.contains(null)) return;
    String originalSentence = _getCurrentSentence();
    String userSentence = currentDroppedWords.join(' ');
    bool isCorrect = originalSentence == userSentence;

    if (isReviewMode) {
      _handleReviewModeCheck(isCorrect);
      return;
    }

    int currentLevelSentenceCount = getSentencesForLevel(currentLevel);
    setState(() {
      isChecking = true;
      showFeedback = true;
      levelResults[currentLevel - 1][currentSentenceIndex] = isCorrect;

      if (isCorrect) {
        score += pointsPerCorrectAnswer;
        levelScores[currentLevel - 1] += pointsPerCorrectAnswer;
        feedbackMessage = '+$pointsPerCorrectAnswer Points!';
        feedbackColor = const Color(0xFFF9BE1A);
      } else {
        incorrectAnswers.add(IncorrectAnswer(
          sentence: originalSentence,
          level: currentLevel,
        ));
        feedbackMessage = 'Wrong!';
        feedbackColor = const Color.fromARGB(255, 255, 255, 53);
      }
    });

    _feedbackAnimationController.forward().then((_) {
      _feedbackAnimationController.reverse().then((_) {
        Timer(const Duration(milliseconds: 500), () {
          setState(() {
            isChecking = false;
            currentSentenceIndex++;

            if (currentSentenceIndex >= currentLevelSentenceCount) {
              currentSentenceIndex = 0;
              isLevelComplete = true;
              _levelCompleteAnimationController.forward();
              Timer(const Duration(seconds: 2), () {
                setState(() {
                  currentLevel++;
                  if (currentLevel <= totalLevels) {
                    _startNewRound();
                  } else {
                    _startNewRound();
                  }
                });
              });
            } else {
              _startNewRound();
            }
          });
        });
      });
    });
  }

  void _handleReviewModeCheck(bool isCorrect) {
    setState(() {
      isChecking = true;
      showFeedback = true;
      if (isCorrect) {
        incorrectAnswers[currentReviewIndex].reviewed = true;
        feedbackMessage = 'Correct! Good job!';
        feedbackColor = const Color(0xFFF9BE1A);
      } else {
        feedbackMessage = 'Try again!';
        feedbackColor = const Color.fromARGB(255, 255, 255, 53);
      }
    });

    _feedbackAnimationController.forward().then((_) {
      _feedbackAnimationController.reverse().then((_) {
        Timer(const Duration(milliseconds: 500), () {
          setState(() {
            isChecking = false;
            if (isCorrect) {
              currentReviewIndex++;
              _startReviewRound();
            } else {
              List<String> scrambledWords = List.from(originalWords);
              scrambledWords.shuffle();
              currentScrambledWords = scrambledWords;
              currentDroppedWords =
                  List<String?>.filled(originalWords.length, null);
              showFeedback = false;
              allSlotsFilled = false;
              _tileAnimationController.reset();
              _tileAnimationController.forward();
            }
          });
        });
      });
    });
  }

  void _restartGame() {
    setState(() {
      score = 0;
      currentSentenceIndex = 0;
      currentLevel = 1;
      isGameOver = false;
      isLevelComplete = false;
      isLoading = true;
      isReviewMode = false;
      showReviewModeTransition = false;
      incorrectAnswers = [];
      currentReviewIndex = 0;
      levelScores = List.filled(totalLevels, 0);
      levelResults = [
        List.filled(sentencesPerLevel1, false),
        List.filled(sentencesPerLevel2, false),
        List.filled(sentencesPerLevel3, false),
      ];
    });
    _celebrationAnimationController.reset();
    _levelCompleteAnimationController.reset();
    _reviewTransitionAnimationController.reset();
    _fetchSentencesFromGemini();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isReviewMode ? 'Review Mistakes' : 'Baballon Sentence Scramble',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ), //
        centerTitle: true,
        backgroundColor: const Color(0xFF8F6135),
      ),
      body: isGameOver
          ? _buildResultsScreen()
          : isLevelComplete
              ? _buildLevelCompleteScreen()
              : showReviewModeTransition
                  ? _buildReviewTransitionScreen()
                  : _buildGameScreen(),
    );
  }

  Widget _buildReviewTransitionScreen() {
    return AnimatedBuilder(
      animation: _reviewTransitionAnimationController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF8F6135), Color(0xFFF9BE1A)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.scale(
                scale: _reviewTransitionAnimationController.value,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8F6135),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.psychology,
                    color: Color.fromARGB(255, 176, 87, 39),
                    size: 60,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Opacity(
                opacity: _reviewTransitionAnimationController.value,
                child: const Text(
                  'Time to Review!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Opacity(
                opacity: _reviewTransitionAnimationController.value,
                child: Text(
                  'Let\'s practice the ${incorrectAnswers.length} sentences you missed',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Opacity(
                opacity: _reviewTransitionAnimationController.value,
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGameScreen() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF9BE1A)),
            ),
            SizedBox(height: 20),
            Text(
              'Fetching sentences from Gemini AI...',
              style: TextStyle(fontSize: 16, color: Color(0xFF5D4037)),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF8F6135), Color(0xFFF9BE1A)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildLevelAndScore(),
            const SizedBox(height: 16),
            if (showFeedback) _buildFeedbackMessage(),
            const SizedBox(height: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isReviewMode ? Colors.amber : _getLevelColor(),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      isReviewMode ? 'Review Mode' : 'Level $currentLevel',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  // Upper box (drop targets) with fixed height
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isReviewMode ? Colors.amber : _getLevelColor(),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF9BE1A).withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    height: 150, // Fixed height for upper box
                    width: double.infinity,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: List.generate(
                        currentDroppedWords.length,
                        (index) => _buildDropTarget(index),
                      ),
                    ),
                  ),
                  // Lower box (draggable words) with same fixed height
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isReviewMode
                            ? Colors.purple.withOpacity(0.5)
                            : _getLevelColor().withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    height: 150, // Same fixed height as upper box
                    width: double.infinity,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: currentScrambledWords.map((word) {
                        return _buildDraggableWord(word);
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggableWord(String word) {
    if (isChecking) return _buildWordChip(word, isDraggable: false);

    return Draggable<String>(
      data: word,
      feedback: Material(
        elevation: 4.0,
        borderRadius: BorderRadius.circular(25),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isReviewMode
                ? Colors.amber.withOpacity(0.9)
                : _getLevelColor().withOpacity(0.9),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            word,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildWordChip(word, isDraggable: true),
      ),
      onDragCompleted: () {
        setState(() => currentScrambledWords.remove(word));
        _checkAllSlotsFilled();
      },
      child: _buildWordChip(word, isDraggable: true),
    );
  }

  Widget _buildDropTarget(int index) {
    return DragTarget<String>(
      builder: (context, candidateData, rejectedData) {
        if (currentDroppedWords[index] != null) {
          return GestureDetector(
            onTap: isChecking
                ? null
                : () {
                    setState(() {
                      String word = currentDroppedWords[index]!;
                      currentScrambledWords.add(word);
                      currentDroppedWords[index] = null;
                      allSlotsFilled = false;
                    });
                    _autoCheckTimer?.cancel();
                  },
            child: Container(
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isReviewMode ? Colors.amber : _getLevelColor(),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF9BE1A).withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 2,
                  ),
                ],
              ),
              child: Text(
                currentDroppedWords[index]!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.all(4),
          width: 50,
          height: 36,
          decoration: BoxDecoration(
            color: candidateData.isEmpty
                ? Colors.grey.shade300
                : Colors.grey.shade400,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: candidateData.isEmpty
                  ? Colors.grey.shade400
                  : isReviewMode
                      ? Colors.purple
                      : _getLevelColor(),
              width: 2,
            ),
          ),
        );
      },
      onWillAccept: (data) => currentDroppedWords[index] == null && !isChecking,
      onAccept: (word) => setState(() => currentDroppedWords[index] = word),
    );
  }

  Widget _buildWordChip(String word, {required bool isDraggable}) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDraggable ? Colors.grey.shade200 : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDraggable
              ? isReviewMode
                  ? Colors.amber.withOpacity(0.7)
                  : _getLevelColor().withOpacity(0.7)
              : Colors.transparent,
          width: 1,
        ),
        boxShadow: isDraggable
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 2,
                )
              ]
            : null,
      ),
      child: Text(
        word,
        style: TextStyle(
          color: Colors.black87,
          fontWeight: isDraggable ? FontWeight.normal : FontWeight.w300,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildLevelAndScore() {
    int currentProgress =
        isReviewMode ? currentReviewIndex + 1 : currentSentenceIndex + 1;
    int totalItems = isReviewMode
        ? incorrectAnswers.length
        : getSentencesForLevel(currentLevel);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress: $currentProgress/$totalItems',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (!isReviewMode)
              Text(
                'Score: $score/$maxScore',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: currentProgress / totalItems,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(
            isReviewMode ? Colors.amber.withOpacity(0.7) : _getLevelColor(),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackMessage() {
    return FadeTransition(
      opacity: _feedbackAnimationController,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: feedbackColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: feedbackColor),
        ),
        child: Text(
          feedbackMessage,
          style: TextStyle(
            color: feedbackColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Color _getLevelColor() {
    switch (currentLevel) {
      case 1:
        return const Color(0xFFF9BE1A);
      case 2:
        return const Color(0xFF8F6135);
      case 3:
        return const Color(0xFF5D4037);
      default:
        return const Color(0xFFF9BE1A);
    }
  }

  Widget _buildLevelCompleteScreen() {
    int currentLevelSentenceCount = getSentencesForLevel(currentLevel);
    int maxLevelScore = currentLevelSentenceCount * pointsPerCorrectAnswer;

    return AnimatedBuilder(
      animation: _levelCompleteAnimationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFD4AF37).withOpacity(0.3),
                _getLevelColor().withOpacity(0.3),
              ],
            ),
          ),
          child: Center(
            child: Transform.scale(
              scale: 0.5 + (_levelCompleteAnimationController.value * 0.5),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: Color(0xFFD4AF37), // Use gold for the star
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Level ${currentLevel} Complete!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _getLevelColor(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Score: ${levelScores[currentLevel - 1]} / $maxLevelScore',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        currentLevel < totalLevels
                            ? 'Get ready for Level ${currentLevel + 1}!'
                            : 'Preparing for review mode...',
                        style: const TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultsScreen() {
    int totalCorrect = 0;
    for (int i = 0; i < levelResults.length; i++) {
      totalCorrect += levelResults[i].where((result) => result).length;
    }

    double percentage = (score / maxScore) * 100;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFF9BE1A).withOpacity(0.7),
            const Color(0xFFF9BE1A).withOpacity(0.3),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _celebrationAnimationController,
              child: const Icon(
                Icons.emoji_events,
                color: Color(0xFFFFD700),
                size: 100,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              percentage >= 80
                  ? 'Excellent Job!'
                  : percentage >= 60
                      ? 'Good Job!'
                      : 'Nice Try!',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Final Score: $score/$maxScore',
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Correct Sentences: $totalCorrect/$totalSentences',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'Level Results',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._buildLevelResults(),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _restartGame,
              icon: const Icon(Icons.replay),
              label: const Text(
                'Play Again',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8F6135),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final fullUrl = html.window.location.href;
                final uri = Uri.parse(fullUrl);
                final fragment = uri.fragment;

                // Initialize parameters as null
                String? userEmail;
                String? userLang;
                String? origin;
                String? vocabulary_score;
                String? pronounciation_score;

                // Check if the URL fragment contains query parameters
                if (fragment.contains('?')) {
                  final fragParams = fragment.split('?')[1];
                  final params = Uri.splitQueryString(fragParams);

                  // Extract the parameters from the URL
                  userEmail = params['email'];
                  userLang = params['lang'];
                  origin = params['origin'];
                  vocabulary_score = params['vocabulary_score'];
                  pronounciation_score = params['pronounciation_score'];
                }

                // Build the base URL
                final baseUrl = '${html.window.location.origin}';
                String urlString =
                    'http://localhost:5173/?email=$userEmail&lang=$userLang&origin=$baseUrl';

                // Add vocabulary_score and pronounciation_score if available
                if (vocabulary_score != null) {
                  urlString += '&vocabulary_score=$vocabulary_score';
                }
                if (pronounciation_score != null) {
                  urlString += '&pronounciation_score=$pronounciation_score';
                }

                // Always add grammar score
                final grammarScore = '$score';
                urlString += '&grammer_score=$grammarScore';

                // Parse the URL and redirect
                final url = Uri.parse(urlString);
                html.window.location.href =
                    url.toString(); // Redirect to the generated URL
              },
              icon: const Icon(Icons.replay),
              label: const Text(
                'Cancel',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8F6135),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLevelResults() {
    List<Widget> results = [];
    for (int i = 0; i < levelResults.length; i++) {
      int correct = levelResults[i].where((result) => result).length;
      int total = levelResults[i].length;
      int levelScore = levelScores[i];
      int levelMaxScore = getMaxScoreForLevel(i + 1);

      results.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level ${i + 1}:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '$correct/$total correct',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                '$levelScore/$levelMaxScore pts',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }
    return results;
  }
}
