import 'package:flutter/material.dart';
import '/utils/strings.dart' as strings;
import '/data/message_dao.dart';
import '/models/message.dart';
import 'widgets/message_list_widget.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';

class MessageList extends StatefulWidget {
  MessageList({Key? key}) : super(key: key);
  final messageDao = MessageDao();
  // necessary to have createState() for a stateful widget

  @override
  MessageListState createState() => MessageListState();
}

class MessageListState extends State<MessageList> {
  TextEditingController _messageController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  // need to have a build(), so will add the AppBar now...
  bool _canSendMessage() {
    bool _validMessage = true;
    // RegExp regex = RegExp(' '+'[a-zA-Z0-9?.]');
    if (_messageController.text.isEmpty) _validMessage = false;
    if (_messageController.text.startsWith(' ')) _validMessage = false;
    return _validMessage;
  }

  void _sendMessage() {
    if (_canSendMessage()) {
      final message = Message(_messageController.text, DateTime.now());
      widget.messageDao.saveMessage(message);
      setState(() {});
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  Widget _getMessageList() {
    return Expanded(
      child: FirebaseAnimatedList(
        controller: _scrollController,
        query: widget.messageDao.getMessageQuery(),
        itemBuilder: (context, snapshot, animation, index) {
          final json = snapshot.value as Map<dynamic, dynamic>;
          final message = Message.fromJson(json);
          return MessageWidget(message.text, message.date);
        },
      ),
    );
  }

  Widget build(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((_) => _scrollToBottom());
    return Scaffold(
      appBar: AppBar(
        title: const Text(strings.appTitle),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _getMessageList(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: TextField(
                      keyboardType: TextInputType.text,
                      controller: _messageController,
                      onChanged: (text) => setState(() {}),
                      onSubmitted: (input) {
                        IconButton(
                            icon: Icon(_canSendMessage()
                                ? CupertinoIcons.arrow_right_circle_fill
                                : CupertinoIcons.arrow_right_circle),
                            onPressed: () {
                              _sendMessage();
                            });
                      },
                      decoration:
                          const InputDecoration(hintText: 'Enter new message'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
