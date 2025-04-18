import 'package:chat_app/src/services/deepseek.dart';
import 'package:chat_app/src/services/speech_to_text.dart';
import 'package:chat_app/src/services/text_to_speech.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:chat_app/src/models/message_model.dart';
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Message> messages = [];

  final TextEditingController _controller = TextEditingController();
  bool isMicOn = false;
  final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(style: BorderStyle.none));

  final STTService _speechService = STTService();
  final TTSService _ttsService = TTSService();
  final DeepSeekService _deepSeekService = DeepSeekService();
  String _lastWords = '';
  String _response = '';

  @override
  void initState() {
    super.initState();
    _speechService.initSpeech();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      _controller.text = _lastWords;
    });
    if (!_speechService.isListening) {
      _sendMessageVoice(_lastWords);
    }
  }

  void _sendMessageVoice(String text) async {
    final message = Message(text, DateTime.now(), true);
    setState(() {
      messages.add(message);
    });

    final response = await _deepSeekService.getChatResponse(text);
    final _message = Message(response, DateTime.now(), false);
    setState(() {
      _response = response;
      messages.add(_message);
    });
    print(_response);
    _ttsService.speak(_response);
    _controller.clear();
  }

  void _sendMessageText() async {
    if (_controller.text.trim().isEmpty) return; // Evita enviar mensajes vacíos

    Message message = Message(_controller.text, DateTime.now(), true);
    setState(() {
      messages.add(message);
    });
    final response = await _deepSeekService.getChatResponse(_controller.text);
    message = Message(response, DateTime.now(), false);
    setState(() {
      messages.add(message);
    });
    _ttsService.speak(message.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat App'),
        backgroundColor: Colors.blue,
      ),
      floatingActionButton: isMicOn ? _floatingActionButton() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Column(
        children: [
          Expanded(
              child: GroupedListView<Message, DateTime>(
            padding: const EdgeInsets.all(8),
            reverse: true,
            order: GroupedListOrder.DESC,
            useStickyGroupSeparators: true,
            floatingHeader: true,
            elements: messages,
            groupBy: (message) => DateTime(
              message.date.year,
              message.date.month,
              message.date.day,
            ),
            groupHeaderBuilder: (Message message) => SizedBox(
              height: 40,
              child: Center(
                child: Card(
                  color: Theme.of(context).primaryColor,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      DateFormat.yMd().format(message.date),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            itemBuilder: (context, Message message) => Align(
              alignment: message.isSendByMe
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Card(
                elevation: 8,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.5,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(message.text),
                  ),
                ),
              ),
            ),
          )),
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(0.2), // Color de la sombra
                          blurRadius: 10, // Desenfoque (blur)
                          spreadRadius: 2, // Expansión de la sombra
                          offset: const Offset(0, 4), // Dirección de la sombra
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _controller,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: border,
                          contentPadding: const EdgeInsets.all(12),
                          hintText: 'Escribe un mensaje',
                          hintStyle: TextStyle(color: Colors.grey.shade500)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CircleAvatar(
                    backgroundColor: Colors.blue,
                    radius: 22,
                    child: IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 26,
                      ),
                      onPressed: _sendMessageText, // Enviar con el botón
                    ),
                  ),
                ),
                GestureDetector(
                    onLongPressStart: (details) {
                      _speechService.startListening(_onSpeechResult);
                      setState(() {
                        isMicOn = true;
                      });
                    },
                    onLongPressEnd: (details) {
                      _speechService.stopListening;
                      setState(() {
                        isMicOn = false;
                      });
                    },
                    child: CircleAvatar(
                      child: Icon(
                        Icons.mic,
                        color: Colors.white,
                        size: 28,
                      ),
                      backgroundColor: Colors.blue,
                      radius: 22,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  FloatingActionButton _floatingActionButton() {
    return FloatingActionButton(
      onPressed: () {},
      backgroundColor: Colors.white,
      child: LottieBuilder.asset('assets/mic.json'),
    );
  }
}
