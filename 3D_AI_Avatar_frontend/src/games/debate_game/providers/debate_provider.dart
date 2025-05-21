import 'package:flutter/material.dart';
import '../models/debate_topic.dart';
import '../models/debate_argument.dart';
import '../services/api_service.dart';

enum DebateState {
  initial,
  topicSelection,
  userDebating,
  aiDebating,
  feedback,
  completed,
}

class DebateProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  DebateState _state = DebateState.initial;
  DebateState get state => _state;

  DebateTopic? _currentTopic;
  DebateTopic? get currentTopic => _currentTopic;

  final List<DebateArgument> _userArguments = [];
  List<DebateArgument> get userArguments => _userArguments;

  final List<DebateArgument> _aiArguments = [];
  List<DebateArgument> get aiArguments => _aiArguments;

  int _currentRound = 0;
  int get currentRound => _currentRound;
  final int totalRounds = 3;

  String _transcribedText = '';
  String get transcribedText => _transcribedText;

  bool _isListening = false;
  bool get isListening => _isListening;

  int _remainingTime = 120;
  int get remainingTime => _remainingTime;

  double _userTotalScore = 0;
  double get userTotalScore => _userTotalScore;

  String _finalFeedback = '';
  String get finalFeedback => _finalFeedback;

  bool _isLoadingTopic = false;
  bool get isLoadingTopic => _isLoadingTopic;

  bool _isSubmitting = false;

  // ** NEW ** avatar selector
  int _avatarId = 1;
  int get avatarId => _avatarId;
  void setAvatarId(int id) {
    _avatarId = id;
    notifyListeners();
  }

  void _setLoadingTopic(bool v) {
    _isLoadingTopic = v;
    notifyListeners();
  }

  List<Map<String, dynamic>> get combinedArguments {
    final all = <Map<String, dynamic>>[];
    final maxLen = _userArguments.length > _aiArguments.length
        ? _userArguments.length
        : _aiArguments.length;
    for (var i = 0; i < maxLen; i++) {
      if (i < _userArguments.length) {
        all.add({'text': _userArguments[i].text, 'isUser': true});
      }
      if (i < _aiArguments.length) {
        all.add({'text': _aiArguments[i].text, 'isUser': false});
      }
    }
    return all;
  }

  Future<void> generateRandomTopic() async {
    _setLoadingTopic(true);
    try {
      _currentTopic = await _apiService.generateRandomTopic();
      _state = DebateState.topicSelection;
    } catch (_) {
      _currentTopic = DebateTopic(
        topic: "Fallback topic",
        description: "Fallback description",
      );
    }
    _setLoadingTopic(false);
    notifyListeners();
  }

  Future<void> suggestAlternativeTopic() async {
    _setLoadingTopic(true);
    try {
      _currentTopic = await _apiService.generateAlternativeTopic();
    } catch (_) {
      _currentTopic = DebateTopic(
        topic: "Fallback alt topic",
        description: "Fallback description",
      );
    }
    _setLoadingTopic(false);
    notifyListeners();
  }

  void acceptTopic() {
    _state = DebateState.userDebating;
    _currentRound = 1;
    _remainingTime = 120;
    notifyListeners();
  }

  void updateTranscribedText(String text) {
    _transcribedText = text;
    notifyListeners();
  }

  void setListening(bool v) {
    _isListening = v;
    notifyListeners();
  }

  void updateRemainingTime(int s) {
    _remainingTime = s;
    notifyListeners();
  }

  Future<void> submitUserArgument() async {
    if (_isSubmitting) return;
    final trimmed = _transcribedText.trim();
    if (trimmed.isEmpty) return;

    _isSubmitting = true;
    try {
      final analysis = await _apiService.analyzeUserArgument(
        trimmed,
        _currentTopic?.topic ?? '',
      );
      _userArguments.add(analysis);
      _userTotalScore += analysis.score;
      _transcribedText = '';
      _isListening = false;

      _state = DebateState.aiDebating;
      notifyListeners();
      await generateAIResponse();
    } catch (e) {
      print("❌ Error during user submission: $e");
    } finally {
      _isSubmitting = false;
    }
  }

  Future<void> generateAIResponse() async {
    try {
      final latest = _userArguments.isNotEmpty ? _userArguments.last.text : '';
      _aiArguments.add(DebateArgument(
        text: 'Thinking...',
        score: 0,
        feedback: '',
        strongWords: [],
      ));
      notifyListeners();

      final aiResp =
          await _apiService.generateAIResponse(_currentTopic!.topic, latest);
      _aiArguments
        ..removeWhere((a) => a.text == 'Thinking...')
        ..add(aiResp);

      if (_currentRound < totalRounds) {
        _currentRound++;
        _state = DebateState.userDebating;
        _remainingTime = 120;
      } else {
        // allow 10s to read final AI reply
        await Future.delayed(const Duration(seconds: 10));
        _state = DebateState.feedback;
        await _generateFinalFeedback();
      }
    } catch (e) {
      print("❌ Error in AI response: $e");
      _aiArguments
        ..removeWhere((a) => a.text == 'Thinking...')
        ..add(DebateArgument(
          text: "There are many perspectives to consider.",
          score: 70.0,
          feedback: '',
          strongWords: [],
        ));
      if (_currentRound < totalRounds) {
        _currentRound++;
        _state = DebateState.userDebating;
        _remainingTime = 120;
      } else {
        await Future.delayed(const Duration(seconds: 10));
        _state = DebateState.feedback;
        await _generateFinalFeedback();
      }
    }

    notifyListeners();
  }

  Future<void> _generateFinalFeedback() async {
    try {
      _finalFeedback = await _apiService.generateFinalFeedback(
        _userArguments,
        _userTotalScore,
        totalRounds,
      );
    } catch (e) {
      _finalFeedback =
          "Your final score is ${(userTotalScore / totalRounds).toStringAsFixed(1)}/100.";
    }
    notifyListeners();
  }

  void completeDebate() {
    _state = DebateState.completed;
    notifyListeners();
  }

  void restartDebate() {
    _state = DebateState.initial;
    _currentTopic = null;
    _userArguments.clear();
    _aiArguments.clear();
    _currentRound = 0;
    _transcribedText = '';
    _isListening = false;
    _remainingTime = 120;
    _userTotalScore = 0;
    _finalFeedback = '';
    // also reset avatar
    _avatarId = 1;
    notifyListeners();
  }
}
