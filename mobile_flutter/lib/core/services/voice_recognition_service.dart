import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Singleton service managing real microphone speech recognition,
/// multi-language locales (Tamil, English, Hindi, Telugu, Kannada, Malayalam),
/// sound level metering, and real-time word transcription.
class VoiceRecognitionService with ChangeNotifier {
  static final VoiceRecognitionService _instance = VoiceRecognitionService._internal();
  factory VoiceRecognitionService() => _instance;
  VoiceRecognitionService._internal();

  final SpeechToText _speech = SpeechToText();

  bool _isInitialized = false;
  bool _isListening = false;
  bool _hasPermission = false;
  bool _isAvailable = false;
  String _currentLocaleId = 'en_IN';
  String _lastRecognizedWords = '';
  String? _errorMessage;
  double _soundLevel = 0.0;
  List<LocaleName> _availableLocales = [];

  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;
  bool get hasPermission => _hasPermission;
  bool get isAvailable => _isAvailable;
  String get currentLocaleId => _currentLocaleId;
  String get lastRecognizedWords => _lastRecognizedWords;
  String? get errorMessage => _errorMessage;
  double get soundLevel => _soundLevel;
  List<LocaleName> get availableLocales => _availableLocales;

  /// Initialize SpeechToText engine and query available platform locales.
  Future<bool> initialize() async {
    if (_isInitialized && _isAvailable) return true;

    try {
      _errorMessage = null;
      _isAvailable = await _speech.initialize(
        onError: _handleError,
        onStatus: _handleStatus,
        debugLogging: false,
      );

      _hasPermission = await _speech.hasPermission;
      _isInitialized = true;

      if (_isAvailable) {
        try {
          _availableLocales = await _speech.locales();
        } catch (e) {
          debugPrint('Error querying speech locales: $e');
        }
      }

      notifyListeners();
      return _isAvailable;
    } catch (e) {
      debugPrint('VoiceRecognitionService initialize exception: $e');
      _isAvailable = false;
      _errorMessage = 'Speech service initialization error: $e';
      notifyListeners();
      return false;
    }
  }

  void _handleError(SpeechRecognitionError error) {
    debugPrint('SpeechRecognition onError: ${error.errorMsg} (permanent: ${error.permanent})');
    _errorMessage = _parseErrorMessage(error.errorMsg);
    _isListening = false;
    _soundLevel = 0.0;
    notifyListeners();
  }

  void _handleStatus(String status) {
    debugPrint('SpeechRecognition onStatus: $status');
    if (status == 'listening') {
      _isListening = true;
      _errorMessage = null;
    } else if (status == 'notListening' || status == 'done') {
      _isListening = false;
      _soundLevel = 0.0;
    }
    notifyListeners();
  }

  /// Map 2-letter language code to best matching locale ID
  String resolveLocaleId(String langCode) {
    final search = langCode.toLowerCase().trim();
    List<String> candidates;
    switch (search) {
      case 'ta':
        candidates = ['ta_IN', 'ta-IN', 'ta'];
        break;
      case 'hi':
        candidates = ['hi_IN', 'hi-IN', 'hi'];
        break;
      case 'te':
        candidates = ['te_IN', 'te-IN', 'te'];
        break;
      case 'kn':
        candidates = ['kn_IN', 'kn-IN', 'kn'];
        break;
      case 'ml':
        candidates = ['ml_IN', 'ml-IN', 'ml'];
        break;
      case 'en':
      default:
        candidates = ['en_IN', 'en-IN', 'en_US', 'en-US', 'en_GB', 'en'];
        break;
    }

    if (_availableLocales.isNotEmpty) {
      for (final candidate in candidates) {
        for (final loc in _availableLocales) {
          if (loc.localeId.toLowerCase().replaceAll('-', '_') ==
              candidate.toLowerCase().replaceAll('-', '_')) {
            return loc.localeId;
          }
        }
      }
    }

    return candidates.first;
  }

  /// Start listening with real-time transcription callbacks.
  Future<bool> startListening({
    required String languageCode,
    required void Function(String recognizedText, bool isFinal) onResult,
    void Function(double level)? onSoundLevel,
    void Function(String error)? onError,
  }) async {
    final ready = await initialize();
    if (!ready) {
      final msg = _errorMessage ?? 'Microphone speech recognition is not available.';
      onError?.call(msg);
      return false;
    }

    _errorMessage = null;
    _currentLocaleId = resolveLocaleId(languageCode);
    _lastRecognizedWords = '';

    try {
      await _speech.listen(
        onResult: (SpeechRecognitionResult result) {
          _lastRecognizedWords = result.recognizedWords;
          onResult(result.recognizedWords, result.finalResult);
          notifyListeners();
        },
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.dictation,
          cancelOnError: false,
          partialResults: true,
          listenFor: const Duration(seconds: 40),
          pauseFor: const Duration(seconds: 4),
          localeId: _currentLocaleId,
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
      debugPrint('startListening exception: $e');
      _errorMessage = 'Could not start microphone: $e';
      _isListening = false;
      onError?.call(_errorMessage!);
      notifyListeners();
      return false;
    }
  }

  /// Stop listening (finalizes recognized text)
  Future<void> stopListening() async {
    if (!_isListening) return;
    try {
      await _speech.stop();
    } catch (e) {
      debugPrint('stopListening exception: $e');
    } finally {
      _isListening = false;
      _soundLevel = 0.0;
      notifyListeners();
    }
  }

  /// Cancel listening (discards session)
  Future<void> cancelListening() async {
    try {
      await _speech.cancel();
    } catch (e) {
      debugPrint('cancelListening exception: $e');
    } finally {
      _isListening = false;
      _soundLevel = 0.0;
      notifyListeners();
    }
  }

  String _parseErrorMessage(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('not-allowed') || lower.contains('denied') || lower.contains('permission')) {
      return 'Microphone permission denied. Please allow microphone access.';
    } else if (lower.contains('no-speech') || lower.contains('no speech')) {
      return 'No speech detected. Please speak into your microphone.';
    } else if (lower.contains('network') || lower.contains('connection')) {
      return 'Network connection issue during speech recognition.';
    } else if (lower.contains('not supported') || lower.contains('speech_not_supported')) {
      return 'Speech recognition is not supported on this browser or platform.';
    }
    return raw;
  }
}
