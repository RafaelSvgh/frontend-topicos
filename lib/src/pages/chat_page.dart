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
  List<Message> messages = [
    Message(
      'Hola, soy tu asistente legal. ¿En qué puedo ayudarte hoy?',
      DateTime.now(),
      false,
    ),
    Message(
      '¿Tienes alguna pregunta legal específica?',
      DateTime.now(),
      true,
    ),
    Message(
      'Recuerda que no soy un abogado, pero puedo ofrecerte información general asdas asdasdasd asdasdasd asdqweqwdqkm asdpoewmflmvcjnqou.',
      DateTime.now(),
      false,
    ),
    Message(
      'Si tienes una consulta legal, por favor, házmelo saber.',
      DateTime.now(),
      true,
    ),
  ];

  final TextEditingController _controller = TextEditingController();
  double _micOffset = 0.0;
  bool isMicOn = false;
  bool _isSpeaking = false;
  String? _speakingMessageText;
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
    _ttsService.onSpeakingStateChanged = (isSpeaking) {
      setState(() {
        _isSpeaking = isSpeaking;
        if (!isSpeaking) _speakingMessageText = null;
      });
    };
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      _controller.text = _lastWords;
    });
    // if (!_speechService.isListening) {
    //   _sendMessageVoice(_lastWords);
    // }
  }

  void _sendMessageVoice(String text) async {
    _controller.clear();
    _micOffset = 0.0;
    setState(() {
      isMicOn = false;
    });
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: _appBar(theme),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: theme.primaryColor,
              ),
              child: const Text(
                'DeepSeek',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuración'),
              onTap: () {
                // Acción al seleccionar la opción de configuración
              },
            ),
          ],
        ),
      ),
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
                  color: theme.colorScheme.secondary,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      DateFormat.yMd().format(message.date),
                      style: theme.textTheme.bodyMedium,
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
                    maxWidth: !message.isSendByMe
                        ? MediaQuery.of(context).size.width * 0.9
                        : MediaQuery.of(context).size.width * 0.7,
                  ),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: message.isSendByMe
                              ? theme.colorScheme.secondary
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(20),
                            topRight: const Radius.circular(20),
                            bottomLeft: message.isSendByMe
                                ? const Radius.circular(20)
                                : const Radius.circular(0),
                            bottomRight: message.isSendByMe
                                ? const Radius.circular(0)
                                : const Radius.circular(20),
                          ),
                        ),
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(top: 15),
                        child: Text(
                          message.text,
                          style: theme.textTheme.bodyLarge,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      if (!message.isSendByMe)
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (_isSpeaking) {
                                  _ttsService.stop();
                                  setState(() {
                                    _speakingMessageText = null;
                                  });
                                } else {
                                  setState(() {
                                    _speakingMessageText = message.text;
                                  });
                                  _ttsService.speak(message.text);
                                }
                              },
                              icon: Icon(
                                _isSpeaking &&
                                        _speakingMessageText == message.text
                                    ? Icons.stop
                                    : Icons.volume_up_outlined,
                              ),
                            ),
                            IconButton(
                                onPressed: () {}, icon: const Icon(Icons.copy)),
                          ],
                        )
                    ],
                  ),
                ),
              ),
            ),
          )),
          Container(
            margin: const EdgeInsets.only(left: 4, right: 4, bottom: 4),
            height: 110,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20)),
                color: theme.colorScheme.secondary),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: theme.colorScheme.secondary,
                    enabledBorder: border,
                    focusedBorder: border,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    hintText: 'Pregunta lo que quieras',
                    hintStyle:
                        const TextStyle(color: Colors.white54, fontSize: 18),
                  ),
                ),
                !isMicOn
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.add,
                                color: theme.textTheme.bodyLarge?.color,
                                size: 32,
                              )),
                          GestureDetector(
                            onVerticalDragUpdate: (details) {
                              setState(() {
                                _micOffset += details.delta.dy;
                                if (_micOffset < -100) {
                                  // Aquí puedes activar la grabación o mostrar un mensaje de "Desliza para cancelar"
                                  _speechService
                                      .startListening(_onSpeechResult);
                                  setState(() {
                                    isMicOn = true;
                                  });
                                }
                              });
                            },
                            child: Transform.translate(
                              offset: Offset(0, _micOffset),
                              child: Icon(
                                Icons.mic,
                                color: theme.textTheme.bodyLarge?.color,
                                size: 32,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  isMicOn = false;
                                  _micOffset = 0.0;
                                });
                              },
                              icon: Icon(
                                Icons.close,
                                color: theme.textTheme.bodyLarge?.color,
                                size: 32,
                              )),
                          Lottie.asset(
                            'assets/voice.json',
                            width: 50,
                            height: 50,
                            repeat: true,
                          ),
                          IconButton(
                              onPressed: () {
                                _speechService.stopListening;
                                _sendMessageVoice(_lastWords);
                                setState(() {
                                  isMicOn = false;
                                });
                              },
                              icon: Icon(
                                Icons.check,
                                color: theme.textTheme.bodyLarge?.color,
                                size: 32,
                              )),
                        ],
                      )
              ],
            ),
          ),
        ],
      ),
    );
  }

  AppBar _appBar(ThemeData theme) {
    return AppBar(
      title: const Text(
        'Asesor Legal',
        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
      ),
      backgroundColor: theme.colorScheme.surface,
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(
          color: Colors.grey.withAlpha(100),
          height: 1,
        ),
      ),
      elevation: 1,
      actions: [
        IconButton(
          icon: const Icon(
            Icons.chat_bubble_outline,
            size: 24,
          ),
          onPressed: () {},
        ),
      ],
    );
  }
}
