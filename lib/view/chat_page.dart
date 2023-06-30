
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:timezone/data/latest.dart' as tz;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final messageController = TextEditingController();
  List<String> messages = [];

  late IO.Socket socket;

  @override
  void initState() {
    tz.initializeTimeZones();
    super.initState();

    // Connect to the server
    if(Platform.isIOS){
      socket =  IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket']
    });
    }else if(Platform.isAndroid){
      socket =  IO.io('http://10.0.2.2:3000', <String, dynamic>{
      'transports': ['websocket']
    });
    }

    // Listen for incoming messages
    socket.on('message', (data) {
      messages = (data as List).map((e) => e.toString()).toList();
      setState(() {});
    });
  }

  @override
  void dispose() {
    // Disconnect from the server when the widget is disposed
    socket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat App'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: 'Enter a message',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    socket.emit("message", messageController.text);
                    messageController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
