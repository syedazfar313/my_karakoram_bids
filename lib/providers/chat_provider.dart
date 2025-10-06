import 'package:flutter/foundation.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/services/chat_service.dart';
import '../models/message_model.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();

  // Current chat state
  String? _currentChatId;
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;

  // Typing indicator
  Map<String, bool> _typingUsers = {};

  // Unread counts
  Map<String, int> _unreadCounts = {};

  // Getters
  String? get currentChatId => _currentChatId;
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, int> get unreadCounts => _unreadCounts;

  bool isUserTyping(String userId) => _typingUsers[userId] ?? false;

  // Set current chat
  void setCurrentChat(String chatId) {
    _currentChatId = chatId;
    notifyListeners();
  }

  // Send message
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String content,
  }) async {
    try {
      await _chatService.sendMessage(
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        content: content,
      );

      // Stop typing indicator
      setTypingStatus(chatId, senderId, false);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Set typing status
  Future<void> setTypingStatus(
    String chatId,
    String userId,
    bool isTyping,
  ) async {
    _typingUsers[userId] = isTyping;
    notifyListeners();

    // Auto-clear typing after 3 seconds
    if (isTyping) {
      Future.delayed(const Duration(seconds: 3), () {
        if (_typingUsers[userId] == true) {
          _typingUsers[userId] = false;
          notifyListeners();
        }
      });
    }
  }

  // Mark messages as read
  Future<void> markAsRead(String chatId, String currentUserId) async {
    try {
      await _chatService.markAllAsRead(chatId, currentUserId);
      _unreadCounts[chatId] = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }

  // Update unread count
  Future<void> updateUnreadCount(String chatId, String currentUserId) async {
    try {
      final count = await _chatService.getUnreadCount(chatId, currentUserId);
      _unreadCounts[chatId] = count;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating unread count: $e');
    }
  }

  // Get or create chat
  Future<String> getOrCreateChat({
    required String currentUserId,
    required String currentUserName,
    required String otherUserId,
    required String otherUserName,
    String? otherUserAvatar,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final chatId = await _chatService.getOrCreateChat(
        currentUserId: currentUserId,
        currentUserName: currentUserName,
        otherUserId: otherUserId,
        otherUserName: otherUserName,
        otherUserAvatar: otherUserAvatar ?? 'assets/images/avatar.png',
      );

      _currentChatId = chatId;
      _isLoading = false;
      notifyListeners();

      return chatId;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Delete message
  Future<void> deleteMessage(String chatId, String messageId) async {
    try {
      await _chatService.deleteMessage(chatId, messageId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Clear chat
  Future<void> clearChat(String chatId) async {
    try {
      await _chatService.clearChat(chatId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
