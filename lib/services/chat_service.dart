// TODO Implement this library.

import 'dart:async';
import 'dart:math';
import '../models/message_model.dart';

// Remove the Message class from here since it's now in a separate file

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final Map<String, List<Message>> _chatMessages = {};
  final StreamController<Message> _messageController =
      StreamController.broadcast();
  final StreamController<String> _typingController =
      StreamController.broadcast();

  Stream<Message> get messageStream => _messageController.stream;
  Stream<String> get typingStream => _typingController.stream;

  // Mock users for demonstration

  List<Message> getMessages(String chatId) {
    if (!_chatMessages.containsKey(chatId)) {
      _initializeMockMessages(chatId);
    }
    return _chatMessages[chatId] ?? [];
  }

  void _initializeMockMessages(String chatId) {
    final mockMessages = [
      Message(
        id: '1',
        senderId: 'contractor1',
        senderName: 'Ahmed Builders',
        content: 'Assalam o Alaikum! Main aapke project mein interested hun.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Message(
        id: '2',
        senderId: 'current_user',
        senderName: 'You',
        content: 'Wa alaikum assalam. Aap ka experience kitna hai?',
        timestamp: DateTime.now().subtract(
          const Duration(hours: 1, minutes: 45),
        ),
      ),
      Message(
        id: '3',
        senderId: 'contractor1',
        senderName: 'Ahmed Builders',
        content:
            'Main 8 saal se construction business mein hun. 50+ projects complete kar chuka hun.',
        timestamp: DateTime.now().subtract(
          const Duration(hours: 1, minutes: 30),
        ),
      ),
    ];

    _chatMessages[chatId] = mockMessages;
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String content,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: senderId,
      senderName: senderName,
      content: content,
      timestamp: DateTime.now(),
    );

    if (!_chatMessages.containsKey(chatId)) {
      _chatMessages[chatId] = [];
    }

    _chatMessages[chatId]!.add(message);
    _messageController.add(message);

    // Simulate auto-reply for demo
    if (senderId == 'current_user') {
      _simulateReply(chatId);
    }
  }

  void _simulateReply(String chatId) {
    Timer(const Duration(seconds: 2), () async {
      final replies = [
        'Main aapko best rate mein kaam de sakta hun.',
        'Kya aap site visit kar sakte hain?',
        'Material aap provide karenge ya hum?',
        'Timeline kya hai is project ka?',
        'Main free estimate de sakta hun.',
      ];

      final randomReply = replies[Random().nextInt(replies.length)];

      await sendMessage(
        chatId: chatId,
        senderId: 'contractor1',
        senderName: 'Ahmed Builders',
        content: randomReply,
      );
    });
  }

  void markAsRead(String chatId, String messageId) {
    final messages = _chatMessages[chatId];
    if (messages != null) {
      final index = messages.indexWhere((msg) => msg.id == messageId);
      if (index != -1) {
        messages[index] = messages[index].copyWith(isRead: true);
      }
    }
  }

  void showTyping(String chatId, String userId) {
    _typingController.add('$chatId:$userId');

    // Auto-hide typing after 3 seconds
    Timer(const Duration(seconds: 3), () {
      _typingController.add('$chatId:$userId:stop');
    });
  }

  void dispose() {
    _messageController.close();
    _typingController.close();
  }

  // Get chat list for user
  List<Map<String, dynamic>> getChatList(String userType) {
    return userType.toLowerCase() == 'client'
        ? [
            {
              'chatId': 'chat_1',
              'name': 'Ahmed Builders',
              'lastMessage': 'Main aapko best rate mein kaam de sakta hun.',
              'time': '10:30 AM',
              'avatar': 'assets/images/avatar.png',
              'unreadCount': 2,
            },
            {
              'chatId': 'chat_2',
              'name': 'Khan Constructions',
              'lastMessage': 'Material quality guarantee hai.',
              'time': 'Yesterday',
              'avatar': 'assets/images/avatar.png',
              'unreadCount': 0,
            },
          ]
        : [
            {
              'chatId': 'chat_3',
              'name': 'Muhammad Ali',
              'lastMessage': 'Budget kya hai project ka?',
              'time': '2:15 PM',
              'avatar': 'assets/images/avatar.png',
              'unreadCount': 1,
            },
            {
              'chatId': 'chat_4',
              'name': 'Fatima Khan',
              'lastMessage': 'Site visit ka time confirm kar dein.',
              'time': '1 hour ago',
              'avatar': 'assets/images/avatar.png',
              'unreadCount': 0,
            },
          ];
  }
}
