import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceSearchService {
  final SpeechToText _speech = SpeechToText();
  bool _initialized = false;

  Future<bool> ensureReady() async {
    if (_initialized) return _speech.isAvailable;
    _initialized = await _speech.initialize(
      onError: (_) {},
      onStatus: (_) {},
    );
    return _initialized && _speech.isAvailable;
  }

  Future<bool> ensureMicPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> startListening({
    required void Function(String text, bool isFinal) onResult,
    void Function(String message)? onError,
  }) async {
    if (!await ensureReady()) {
      onError?.call('Speech recognition is not available on this device.');
      return;
    }
    if (!await ensureMicPermission()) {
      onError?.call('Microphone permission is required for voice search.');
      return;
    }

    await _speech.listen(
      onResult: (result) => onResult(result.recognizedWords, result.finalResult),
      listenOptions: SpeechListenOptions(
        listenFor: const Duration(seconds: 12),
        pauseFor: const Duration(seconds: 3),
        localeId: 'en_IN',
        cancelOnError: true,
        partialResults: true,
      ),
    );
  }

  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }

  bool get isListening => _speech.isListening;

  void dispose() {
    _speech.cancel();
  }
}
