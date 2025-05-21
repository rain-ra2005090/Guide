import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:provider/provider.dart';
import '../providers/debate_provider.dart';

class SpeechRecognitionManager {
  static final SpeechRecognitionManager _instance = SpeechRecognitionManager._internal();
  factory SpeechRecognitionManager() => _instance;
  SpeechRecognitionManager._internal();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;

  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    _isInitialized = await _speech.initialize(
      onError: (error) => print('Speech recognition error: $error'),
      onStatus: (status) => print('Speech recognition status: $status'),
    );
    
    return _isInitialized;
  }

  Future<void> startListening({
    required Function(String text) onResult,
    required Function() onListeningComplete,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        print('Could not initialize speech recognition');
        return;
      }
    }

    if (_speech.isAvailable && !_speech.isListening) {
      await _speech.listen(
        onResult: (SpeechRecognitionResult result) {
          onResult(result.recognizedWords);
        },
        listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: 'en_US',
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      );
    }
  }

  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }

  bool get isListening => _speech.isListening;
  bool get isAvailable => _speech.isAvailable;
}

class SpeechRecognitionButton extends StatefulWidget {
  const SpeechRecognitionButton({super.key});

  @override
  State<SpeechRecognitionButton> createState() => _SpeechRecognitionButtonState();
}

class _SpeechRecognitionButtonState extends State<SpeechRecognitionButton> {
  final SpeechRecognitionManager _speechManager = SpeechRecognitionManager();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    final initialized = await _speechManager.initialize();
    setState(() {
      _isInitialized = initialized;
    });
  }

  void _toggleListening() async {
    final debateProvider = Provider.of<DebateProvider>(context, listen: false);
    
    if (_speechManager.isListening) {
      await _speechManager.stopListening();
      debateProvider.setListening(false);
    } else {
      debateProvider.setListening(true);
      await _speechManager.startListening(
        onResult: (String text) {
          debateProvider.updateTranscribedText(text);
        },
        onListeningComplete: () {
          debateProvider.setListening(false);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final debateProvider = Provider.of<DebateProvider>(context);
    final isListening = debateProvider.isListening;

    return FloatingActionButton(
      onPressed: _isInitialized ? _toggleListening : null,
      backgroundColor: isListening ? Colors.red : const Color(0xFFF9BE1A),
      child: Icon(
        isListening ? Icons.mic : Icons.mic_none,
        color: Colors.white,
      ),
    );
  }
}
