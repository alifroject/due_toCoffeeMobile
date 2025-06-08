import 'package:flutter/material.dart';
import 'chat_detail_screen.dart'; // Import the chat detail screen

class ChatCommentSection extends StatelessWidget {
  final List<Map<String, String>> chats = [
    {"name": "eco_warrior", "lastMessage": "Great initiative! ♻️"},
    {"name": "green_life", "lastMessage": "Let's save the planet 🌍"},
    {"name": "waste_fighter", "lastMessage": "Plastic pollution is real!"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chats")),
      body: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Text(chats[index]["name"]![0].toUpperCase()),
            ),
            title: Text(chats[index]["name"]!),
            subtitle: Text(chats[index]["lastMessage"]!),
            onTap: () {
              // Navigate to chat detail page when clicked
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatDetailScreen(
                    userName: chats[index]["name"]!,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
