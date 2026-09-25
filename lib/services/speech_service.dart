import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

enum SpeechStatus { idle, initializing, listening, error, permissionDenied, unavailable }

class SpeechService with ChangeNotifier {
  final SpeechToText _speechToText = SpeechToText();
  bool _isSpeechEnabled = false;
  bool _isListening = false;
  String _lastWords = 'Konuşmaya başlamak için butona basın...';
  SpeechStatus _status = SpeechStatus.idle;

  bool get isSpeechEnabled => _isSpeechEnabled;
  bool get isListening => _isListening;
  String get lastWords => _lastWords;
  SpeechStatus get status => _status;

  /// Requests microphone permission
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    
    if (status.isGranted) {
      _status = SpeechStatus.idle;
      notifyListeners();
      return true;
    } else if (status.isPermanentlyDenied) {
      _status = SpeechStatus.permissionDenied;
      notifyListeners();
      return false;
    } else {
      _status = SpeechStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Opens app settings
  Future<void> openSystemSettings() async {
    await openAppSettings();
  }

  /// Initializes the speech engine
  Future<void> initSpeech() async {
    _status = SpeechStatus.initializing;
    notifyListeners();

    final hasPermission = await requestMicrophonePermission();
    if (!hasPermission) {
      return;
    }

    _isSpeechEnabled = await _speechToText.initialize(
      onStatus: (status) {
        debugPrint('Speech status: $status');
        if (status == 'listening') {
          _isListening = true;
          _status = SpeechStatus.listening;
        } else if (status == 'notListening') {
          _isListening = false;
          _status = SpeechStatus.idle;
        } else if (status == 'error') {
          _status = SpeechStatus.error;
          _isListening = false;
        }
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Speech error: $error');
        _status = SpeechStatus.error;
        _isListening = false;
        notifyListeners();
      },
    );

    if (!_isSpeechEnabled) {
      _status = SpeechStatus.unavailable;
    } else {
      _status = SpeechStatus.idle;
    }
    notifyListeners();
  }

  /// Starts listening to the user
  Future<void> startListening() async {
    if (!_isSpeechEnabled) return;
    
    _status = SpeechStatus.listening;
    _isListening = true;
    notifyListeners();

    await _speechToText.listen(
      onResult: _onSpeechResult,
      listenOptions: SpeechListenOptions(localeId: 'tr_TR'),
    );
  }

  /// Stops listening to the user
  Future<void> stopListening() async {
    await _speechToText.stop();
    _isListening = false;
    _status = SpeechStatus.idle;
    notifyListeners();
  }

  /// Callback for speech recognition results
  void _onSpeechResult(SpeechRecognitionResult result) {
    _lastWords = result.recognizedWords;
    notifyListeners();
  }
}
