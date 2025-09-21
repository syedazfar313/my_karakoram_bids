import 'package:flutter/material.dart';
import 'chat_screen.dart';

class MessagesListScreen extends StatelessWidget {
  final String userType; // "Client" or "Contractor"
  const MessagesListScreen({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> clientChats = [
      {
        "name": "Contractor 1",
        "message": "Salam! Main aapke makan project mai interested hun.",
        "time": "9:30 AM",
        "avatar": "assets/images/avatar.png",
      },
      {
        "name": "Contractor 2",
        "message": "Main aapko material aur labor best rate pe de sakta hun.",
        "time": "Yesterday",
        "avatar": "assets/images/avatar.png",
      },
      {
        "name": "Contractor 3",
        "message":
            "Kya hum meeting rakh sakte hain detail discuss karne ke liye?",
        "time": "2 days ago",
        "avatar": "assets/images/avatar.png",
      },
    ];

    final List<Map<String, String>> contractorChats = [
      {
        "name": "Client 1",
        "message": "Mujhe 2 manzil ka makan banwana hai, aap guide karenge?",
        "time": "10:15 AM",
        "avatar": "assets/images/avatar.png",
      },
      {
        "name": "Client 2",
        "message": "Grey structure ka estimate bhej dein please.",
        "time": "Yesterday",
        "avatar": "assets/images/avatar.png",
      },
      {
        "name": "Client 3",
        "message":
            "Mujhe purane ghar ki renovation karwani hai, aap available hain?",
        "time": "3 days ago",
        "avatar": "assets/images/avatar.png",
      },
    ];

    final chats = userType.toLowerCase() == "client"
        ? clientChats
        : contractorChats;

    return Scaffold(
      body: ListView.separated(
        padding: const EdgeInsets.only(top: 12),
        itemCount: chats.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final chat = chats[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(chat["avatar"]!),
              radius: 24,
            ),
            title: Text(
              chat["name"]!,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            subtitle: Text(
              chat["message"]!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            trailing: Text(
              chat["time"]!,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    userName: chat["name"]!,
                    userImage: chat["avatar"]!,
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
