import 'package:flutter/material.dart';
import '../core/services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();

  // Typing status tracking
  final Map<String, bool> _typingStatus = {};

  // Unread counts tracking
  final Map<String, int> _unreadCounts = {};

  Map<String, int> get unreadCounts => _unreadCounts;

  // Get or create chat
  Future<String> getOrCreateChat({
    required String currentUserId,
    required String currentUserName,
    required String otherUserId,
    required String otherUserName,
    String otherUserAvatar = 'assets/images/avatar.png',
  }) async {
    try {
      return await _chatService.getOrCreateChat(
        currentUserId: currentUserId,
        currentUserName: currentUserName,
        otherUserId: otherUserId,
        otherUserName: otherUserName,
        otherUserAvatar: otherUserAvatar,
      );
    } catch (e) {
      debugPrint('❌ Error in getOrCreateChat: $e');
      rethrow;
    }
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

      // Clear typing status after sending
      setTypingStatus(chatId, senderId, false);

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error sending message: $e');
      rethrow;
    }
  }

  // Set typing status
  void setTypingStatus(String chatId, String userId, bool isTyping) {
    final key = '${chatId}_$userId';
    _typingStatus[key] = isTyping;
    notifyListeners();
  }

  // Check if user is typing
  bool isUserTyping(String userId) {
    return _typingStatus.values.any((status) => status);
  }

  // Mark messages as read
  Future<void> markAsRead(String chatId, String currentUserId) async {
    try {
      await _chatService.markAllAsRead(chatId, currentUserId);

      // Update unread count
      _unreadCounts[chatId] = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error marking as read: $e');
    }
  }

  // Update unread count for a chat
  Future<void> updateUnreadCount(String chatId, String currentUserId) async {
    try {
      final count = await _chatService.getUnreadCount(chatId, currentUserId);
      _unreadCounts[chatId] = count;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error updating unread count: $e');
    }
  }

  // Delete message
  Future<void> deleteMessage(String chatId, String messageId) async {
    try {
      await _chatService.deleteMessage(chatId, messageId);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error deleting message: $e');
      rethrow;
    }
  }

  // Clear chat
  Future<void> clearChat(String chatId) async {
    try {
      await _chatService.clearChat(chatId);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error clearing chat: $e');
      rethrow;
    }
  }

  // Clear all data
  void clearAll() {
    _typingStatus.clear();
    _unreadCounts.clear();
    notifyListeners();
  }
}
