import 'package:flutter_tts/flutter_tts.dart';

class SpeechService {
  SpeechService() {
    _tts.setLanguage('tr-TR');
  }

  final FlutterTts _tts = FlutterTts();

  Future<void> speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}
