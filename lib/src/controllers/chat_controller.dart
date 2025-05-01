import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/services.dart';

class ChatController {
  bool isMicOn = false;
  String response = '';
  String lastWords = '';
  double micOffset = 0.0;
  bool isSpeaking = false;
  List<Message> messages = [];
  String? speakingMessageText;
  final TTSService _ttsService = TTSService();
  final STTService _speechService = STTService();
  final GptService _gptChatService = GptService();
  final ValueNotifier<String> inputNotifier = ValueNotifier('');
  final TextEditingController controller = TextEditingController();
  final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(style: BorderStyle.none));
  
  void _sendMessageVoice(String text) async {
    controller.clear();
    micOffset = 0.0;
      isMicOn = false;
    Message message = Message(text, DateTime.now(), true);
      messages.add(message);

    final res = await _gptChatService.getChatResponse(text);
    message = Message(res, DateTime.now(), false);
      response = res;
      messages.add(message);
    controller.clear();
    _ttsService.speak(res);
    speakingMessageText = res;
  }

}
