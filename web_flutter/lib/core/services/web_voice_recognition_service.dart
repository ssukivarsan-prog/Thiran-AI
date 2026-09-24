import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class WebVoiceRecognitionService with ChangeNotifier {
  static final WebVoiceRecognitionService _instance = WebVoiceRecognitionService._internal();
  factory WebVoiceRecognitionService() => _instance;
  WebVoiceRecognitionService._internal();

  final SpeechToText _speech = SpeechToText();

  bool _isInitialized = false;
  bool _isListening = false;
  bool _isAvailable = false;
  String? _errorMessage;
  double _soundLevel = 0.0;

  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;
  bool get isAvailable => _isAvailable;
  String? get errorMessage => _errorMessage;
  double get soundLevel => _soundLevel;

  Future<bool> initialize() async {
    if (_isInitialized && _isAvailable) return true;

    try {
      _errorMessage = null;
      _isAvailable = await _speech.initialize(
        onError: (SpeechRecognitionError error) {
          debugPrint('Web Speech onError: ${error.errorMsg}');
          _errorMessage = error.errorMsg;
          _isListening = false;
          _soundLevel = 0.0;
          notifyListeners();
        },
        onStatus: (String status) {
          debugPrint('Web Speech onStatus: $status');
          if (status == 'listening') {
            _isListening = true;
            _errorMessage = null;
          } else if (status == 'notListening' || status == 'done') {
            _isListening = false;
            _soundLevel = 0.0;
          }
          notifyListeners();
        },
        debugLogging: false,
      );
      _isInitialized = true;
      notifyListeners();
      return _isAvailable;
    } catch (e) {
      debugPrint('WebVoiceRecognitionService initialize exception: $e');
      _isAvailable = false;
      _errorMessage = 'Speech initialization error: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> startListening({
    String localeId = 'en_IN',
    required void Function(String text, bool isFinal) onResult,
    void Function(double level)? onSoundLevel,
    void Function(String error)? onError,
  }) async {
    final ready = await initialize();
    if (!ready) {
      final msg = _errorMessage ?? 'Speech recognition unavailable on this browser.';
      onError?.call(msg);
      return false;
    }

    _errorMessage = null;

    try {
      await _speech.listen(
        onResult: (SpeechRecognitionResult result) {
          onResult(result.recognizedWords, result.finalResult);
          notifyListeners();
        },
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.dictation,
          cancelOnError: false,
          partialResults: true,
          listenFor: const Duration(seconds: 40),
          pauseFor: const Duration(seconds: 4),
          localeId: localeId,
          onDevice: false,
        ),
        onSoundLevelChange: (double level) {
          double normalized;
          if (level < 0) {
            normalized = ((level + 45) / 45).clamp(0.0, 1.0);
          } else {
            normalized = (level / 10.0).clamp(0.0, 1.0);
          }
          _soundLevel = normalized;
          onSoundLevel?.call(normalized);
          notifyListeners();
        },
      );

      _isListening = true;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('startListening error: $e');
      _errorMessage = 'Could not access microphone: $e';
      _isListening = false;
      onError?.call(_errorMessage!);
      notifyListeners();
      return false;
    }
  }

  Future<void> stopListening() async {
    if (!_isListening) return;
    try {
      await _speech.stop();
    } catch (e) {
      debugPrint('stopListening error: $e');
    } finally {
      _isListening = false;
      _soundLevel = 0.0;
      notifyListeners();
    }
  }

  Future<void> cancelListening() async {
    try {
      await _speech.cancel();
    } catch (e) {
      debugPrint('cancelListening error: $e');
    } finally {
      _isListening = false;
      _soundLevel = 0.0;
      notifyListeners();
    }
  }
}
