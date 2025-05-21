import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/debate_provider.dart';
import '../widgets/speech_recognition.dart';

class SpeechRecognitionService {
  static final SpeechRecognitionService _instance = SpeechRecognitionService._internal();
  factory SpeechRecognitionService() => _instance;
  SpeechRecognitionService._internal();

  final SpeechRecognitionManager _speechManager = SpeechRecognitionManager();
  
  Future<void> initialize() async {
    await _speechManager.initialize();
  }
  
  Future<void> startListening(BuildContext context) async {
    final debateProvider = Provider.of<DebateProvider>(context, listen: false);
    
    if (!_speechManager.isListening) {
      // Vibrate to indicate start of listening
      HapticFeedback.mediumImpact();
      
      debateProvider.setListening(true);
      await _speechManager.startListening(
        onResult: (String text) {
          debateProvider.updateTranscribedText(text);
        },
        onListeningComplete: () {
          debateProvider.setListening(false);
          // Vibrate to indicate end of listening
          HapticFeedback.mediumImpact();
        },
      );
    }
  }
  
  Future<void> stopListening(BuildContext context) async {
    final debateProvider = Provider.of<DebateProvider>(context, listen: false);
    
    if (_speechManager.isListening) {
      await _speechManager.stopListening();
      debateProvider.setListening(false);
      // Vibrate to indicate end of listening
      HapticFeedback.mediumImpact();
    }
  }
  
  bool get isListening => _speechManager.isListening;
  bool get isAvailable => _speechManager.isAvailable;
}
