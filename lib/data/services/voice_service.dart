import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

/// 语音服务 - 封装语音识别和语音合成
class VoiceService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isListening = false;
  bool _isSpeaking = false;
  bool _speechAvailable = false;
  String _lastWords = '';
  String _localeId = 'zh_CN';

  // 回调
  VoidCallback? onListeningStart;
  VoidCallback? onListeningEnd;
  ValueChanged<String>? onResult;
  ValueChanged<bool>? onSpeakingChanged;

  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  bool get isAvailable => _speechAvailable;
  String get lastWords => _lastWords;

  /// 初始化语音服务
  Future<bool> init() async {
    // 初始化语音识别
    _speechAvailable = await _speech.initialize(
      onError: (error) => debugPrint('语音识别错误: ${error.errorMsg}'),
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          _isListening = false;
          onListeningEnd?.call();
        }
      },
    );

    // 初始化语音合成
    await _tts.setLanguage(_localeId);
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _tts.setStartHandler(() {
      _isSpeaking = true;
      onSpeakingChanged?.call(true);
    });

    _tts.setCompletionHandler(() {
      _isSpeaking = false;
      onSpeakingChanged?.call(false);
    });

    _tts.setErrorHandler((msg) {
      _isSpeaking = false;
      onSpeakingChanged?.call(false);
    });

    return _speechAvailable;
  }

  /// 开始语音识别
  Future<void> startListening() async {
    if (!_speechAvailable) {
      await init();
      if (!_speechAvailable) return;
    }

    _isListening = true;
    onListeningStart?.call();

    await _speech.listen(
      onResult: (result) {
        _lastWords = result.recognizedWords;
        onResult?.call(_lastWords);
      },
      localeId: _localeId,
      listenMode: stt.ListenMode.dictation,
      partialResults: true,
      cancelOnError: true,
    );
  }

  /// 停止语音识别
  Future<void> stopListening() async {
    await _speech.stop();
    _isListening = false;
    onListeningEnd?.call();
  }

  /// 切换语音识别状态
  Future<void> toggleListening() async {
    if (_isListening) {
      await stopListening();
    } else {
      await startListening();
    }
  }

  /// 语音合成 - 朗读文字
  Future<void> speak(String text) async {
    if (_isSpeaking) {
      await _tts.stop();
    }
    await _tts.speak(text);
  }

  /// 停止朗读
  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  /// 设置语速
  Future<void> setSpeechRate(double rate) async {
    await _tts.setSpeechRate(rate);
  }

  /// 设置音调
  Future<void> setPitch(double pitch) async {
    await _tts.setPitch(pitch);
  }

  /// 设置语言
  Future<void> setLanguage(String language) async {
    _localeId = language;
    await _tts.setLanguage(language);
  }

  /// 释放资源
  void dispose() {
    _speech.stop();
    _tts.stop();
  }
}
