import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Chat ID generate karein (2 users ke beech unique)
  String getChatId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort(); // Alphabetically sort to ensure same ID for both users
    return '${ids[0]}_${ids[1]}';
  }

  // New chat create ya existing fetch karein
  Future<String> getOrCreateChat({
    required String currentUserId,
    required String currentUserName,
    required String otherUserId,
    required String otherUserName,
    String otherUserAvatar = 'assets/images/avatar.png',
  }) async {
    try {
      final chatId = getChatId(currentUserId, otherUserId);
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();

      if (!chatDoc.exists) {
        // Naya chat create karein
        await _firestore.collection('chats').doc(chatId).set({
          'chatId': chatId,
          'participants': [currentUserId, otherUserId],
          'participantNames': {
            currentUserId: currentUserName,
            otherUserId: otherUserName,
          },
          'participantAvatars': {
            currentUserId: 'assets/images/avatar.png',
            otherUserId: otherUserAvatar,
          },
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessage': '', // Empty for new chats
          'lastMessageTime': FieldValue.serverTimestamp(),
          'lastMessageSenderId': '',
        });
      }

      return chatId;
    } catch (e) {
      throw Exception('Error creating/fetching chat: $e');
    }
  }

  // Message send karein
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String content,
  }) async {
    try {
      // Message add karein
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
            'senderId': senderId,
            'senderName': senderName,
            'content': content,
            'timestamp': FieldValue.serverTimestamp(),
            'isRead': false,
          });

      // Chat document update karein
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': content,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSenderId': senderId,
      });
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  // Messages stream - Real-time
  Stream<QuerySnapshot> getMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // ✅ FIXED: User ke sare chats - Real-time WITH FALLBACK
  Stream<QuerySnapshot> getUserChatsStream(String userId) {
    try {
      // Try with orderBy first (requires composite index)
      return _firestore
          .collection('chats')
          .where('participants', arrayContains: userId)
          .orderBy('lastMessageTime', descending: true)
          .snapshots();
    } catch (e) {
      // ✅ FALLBACK: If index missing, fetch without orderBy
      print('⚠️ Composite index missing, using fallback query');
      return _firestore
          .collection('chats')
          .where('participants', arrayContains: userId)
          .snapshots();
    }
  }

  // Message delete karein
  Future<void> deleteMessage(String chatId, String messageId) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting message: $e');
    }
  }

  // Message ko read mark karein
  Future<void> markAsRead(String chatId, String messageId) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({'isRead': true});
    } catch (e) {
      throw Exception('Error marking message as read: $e');
    }
  }

  // All messages ko read mark karein - SIMPLIFIED VERSION (No index needed)
  Future<void> markAllAsRead(String chatId, String currentUserId) async {
    try {
      final allMessages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();

      final batch = _firestore.batch();

      for (var doc in allMessages.docs) {
        final data = doc.data();
        if (data['senderId'] != currentUserId && data['isRead'] == false) {
          batch.update(doc.reference, {'isRead': true});
        }
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Error marking all as read: $e');
    }
  }

  // Chat clear karein
  Future<void> clearChat(String chatId) async {
    try {
      final messages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();

      final batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Last message update karein
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': '',
        'lastMessageSenderId': '',
      });
    } catch (e) {
      throw Exception('Error clearing chat: $e');
    }
  }

  // Unread count - SIMPLIFIED VERSION (No index needed)
  Future<int> getUnreadCount(String chatId, String currentUserId) async {
    try {
      final allMessages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();

      int unreadCount = 0;
      for (var doc in allMessages.docs) {
        final data = doc.data();
        if (data['senderId'] != currentUserId && data['isRead'] == false) {
          unreadCount++;
        }
      }

      return unreadCount;
    } catch (e) {
      return 0;
    }
  }

  // Get other user info from chat
  Map<String, String> getOtherUserInfo(
    Map<String, dynamic> chatData,
    String currentUserId,
  ) {
    final participants = List<String>.from(chatData['participants'] ?? []);
    final otherUserId = participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );

    final participantNames = Map<String, dynamic>.from(
      chatData['participantNames'] ?? {},
    );
    final participantAvatars = Map<String, dynamic>.from(
      chatData['participantAvatars'] ?? {},
    );

    return {
      'userId': otherUserId,
      'name': participantNames[otherUserId] ?? 'Unknown User',
      'avatar': participantAvatars[otherUserId] ?? 'assets/images/avatar.png',
    };
  }
}
