import 'package:chat_app/src/widgets/appbar.dart';
import 'package:chat_app/src/widgets/drawer.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:chat_app/src/models/message_model.dart';
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:chat_app/src/services/services.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool isMicOn = false;
  String _response = '';
  String _lastWords = '';
  double _micOffset = 0.0;
  bool _isSpeaking = false;
  List<Message> messages = [];
  String? _speakingMessageText;
  final TTSService _ttsService = TTSService();
  final STTService _speechService = STTService();
  final GptService _gptChatService = GptService();
  final ValueNotifier<String> _inputNotifier = ValueNotifier('');
  final TextEditingController _controller = TextEditingController();
  final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(style: BorderStyle.none));

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
  }

  void _sendMessageVoice(String text) async {
    _controller.clear();
    _micOffset = 0.0;
    setState(() {
      isMicOn = false;
    });
    Message message = Message(text, DateTime.now(), true);
    setState(() {
      messages.add(message);
    });

    final response = await _gptChatService.getChatResponse(text);
    message = Message(response, DateTime.now(), false);
    setState(() {
      _response = response;
      messages.add(message);
    });
    _controller.clear();
    _ttsService.speak(_response);
    _speakingMessageText = _response;
  }

  void _sendMessageText() async {
    if (_controller.text.trim().isEmpty) return;
    Message message = Message(_controller.text, DateTime.now(), true);
    setState(() {
      messages.add(message);
    });
    final response = await _gptChatService.getChatResponse(_controller.text);
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
      appBar: appBar(theme, 'Asistente Virtual'),
      drawer: drawer(theme),
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
            groupHeaderBuilder: (Message message) => dateBubble(theme, message),
            itemBuilder: (context, Message message) =>
                chatContainer(message, context, theme),
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
            child: formField(theme),
          ),
        ],
      ),
    );
  }

  Column formField(ThemeData theme) {
    return Column(
      children: [
        TextField(
          minLines: 1,
          maxLines: 5,
          onChanged: (text) {
            _inputNotifier.value = text;
          },
          controller: _controller,
          onTap: () {},
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.colorScheme.secondary,
            enabledBorder: border,
            focusedBorder: border,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            hintText: 'Pregunta lo que quieras',
            hintStyle: const TextStyle(color: Colors.white54, fontSize: 18),
          ),
        ),
        ValueListenableBuilder(
            valueListenable: _inputNotifier,
            builder: (context, value, child) {
              return !isMicOn ? rowSendText(theme) : rowSendVoice(theme);
            }),
      ],
    );
  }

  Row rowSendVoice(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
            onPressed: () {
              setState(() {
                isMicOn = false;
                _micOffset = 0.0;
                _controller.clear();
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
            onPressed: () async {
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
    );
  }

  Row rowSendText(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.add,
              color: theme.textTheme.bodyLarge?.color,
              size: 32,
            )),
        _inputNotifier.value.isEmpty
            ? GestureDetector(
                onVerticalDragUpdate: (details) {
                  setState(() {
                    _micOffset += details.delta.dy;
                    if (_micOffset < -100) {
                      _speechService.startListening(_onSpeechResult);
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
              )
            : IconButton(
                onPressed: () {
                  _sendMessageText();
                },
                icon: Icon(
                  Icons.send,
                  color: theme.textTheme.bodyLarge?.color,
                  size: 26,
                )),
      ],
    );
  }

  Align chatContainer(Message message, BuildContext context, ThemeData theme) {
    return Align(
      alignment:
          message.isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
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
                        _isSpeaking && _speakingMessageText == message.text
                            ? Icons.stop
                            : Icons.volume_up_outlined,
                      ),
                    ),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.copy)),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }

  SizedBox dateBubble(ThemeData theme, Message message) {
    return SizedBox(
      height: 40,
      child: Center(
        child: Card(
          color: theme.colorScheme.secondary,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              DateFormat('E, MMMM d', 'es_ES').format(message.date),
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ),
      ),
    );
  }
}
