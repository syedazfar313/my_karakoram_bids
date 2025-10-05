import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserId;
  final String otherUserName;
  final String otherUserAvatar;
  final String currentUserId;
  final String currentUserName;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserAvatar,
    required this.currentUserId,
    required this.currentUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final ChatService _chatService = ChatService();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _ensureChatExists();
    _markAllAsRead();
  }

  @override
  void dispose() {
    msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // Chat document create karein agar exist nahi karta
  Future<void> _ensureChatExists() async {
    try {
      await _chatService.getOrCreateChat(
        currentUserId: widget.currentUserId,
        currentUserName: widget.currentUserName,
        otherUserId: widget.otherUserId,
        otherUserName: widget.otherUserName,
        otherUserAvatar: widget.otherUserAvatar,
      );
    } catch (e) {
      debugPrint('Error ensuring chat exists: $e');
    }
  }

  // Screen open hone par sare messages read mark karein
  Future<void> _markAllAsRead() async {
    try {
      await _chatService.markAllAsRead(widget.chatId, widget.currentUserId);
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }

  // Message send karein
  Future<void> _sendMessage() async {
    final text = msgCtrl.text.trim();
    if (text.isEmpty) return;

    try {
      await _chatService.sendMessage(
        chatId: widget.chatId,
        senderId: widget.currentUserId,
        senderName: widget.currentUserName,
        content: text,
      );

      msgCtrl.clear();
      setState(() => _isTyping = false);
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sending message: $e')));
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onTyping(String text) {
    if (!_isTyping && text.isNotEmpty) {
      setState(() => _isTyping = true);
    } else if (_isTyping && text.isEmpty) {
      setState(() => _isTyping = false);
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    try {
      await _chatService.deleteMessage(widget.chatId, messageId);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Message deleted')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _clearChat() async {
    try {
      await _chatService.clearChat(widget.chatId);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Chat cleared')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      body: Column(
        children: [
          // Custom App Bar
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 4,
                    color: theme.shadowColor.withOpacity(0.1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CircleAvatar(
                    backgroundImage: AssetImage(widget.otherUserAvatar),
                    radius: 18,
                    onBackgroundImageError: (_, __) {},
                    child: widget.otherUserAvatar.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.otherUserName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Tap to view profile',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.phone),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Calling feature coming soon'),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: _showOptionsMenu,
                  ),
                ],
              ),
            ),
          ),

          // Messages Area - Real-time Stream
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatService.getMessagesStream(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading chat',
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Error: ${snapshot.error}',
                            style: TextStyle(
                              color: Colors.red[600],
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'ChatId: ${widget.chatId}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {});
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final messageDocs = snapshot.data?.docs ?? [];

                if (messageDocs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Start a conversation',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                // Auto scroll to bottom
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.all(16),
                  itemCount: messageDocs.length,
                  itemBuilder: (context, index) {
                    final messageDoc = messageDocs[index];
                    final messageData =
                        messageDoc.data() as Map<String, dynamic>;
                    final isMe =
                        messageData['senderId'] == widget.currentUserId;

                    return MessageBubble(
                      messageId: messageDoc.id,
                      content: messageData['content'] ?? '',
                      timestamp: messageData['timestamp'],
                      isRead: messageData['isRead'] ?? false,
                      isMe: isMe,
                      onLongPress: () => _showMessageOptions(
                        messageDoc.id,
                        isMe,
                        messageData['content'] ?? '',
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Input Area
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 4,
                    color: theme.shadowColor.withOpacity(0.1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    color: theme.colorScheme.primary,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('File attachment coming soon'),
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        controller: msgCtrl,
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: null,
                        decoration: const InputDecoration(
                          hintText: "Type a message...",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        onChanged: _onTyping,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primary,
                    radius: 22,
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessageOptions(String messageId, bool isMe, String content) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy'),
              onTap: () {
                Navigator.pop(context);
                Clipboard.setData(ClipboardData(text: content));
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Message copied')));
              },
            ),
            if (isMe)
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteMessage(messageId);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Block User'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Block feature coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Report'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report feature coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.clear),
              title: const Text('Clear Chat'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear Chat'),
                    content: const Text(
                      'Are you sure you want to clear all messages?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _clearChat();
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Message Bubble Widget
class MessageBubble extends StatelessWidget {
  final String messageId;
  final String content;
  final dynamic timestamp;
  final bool isRead;
  final bool isMe;
  final VoidCallback? onLongPress;

  const MessageBubble({
    super.key,
    required this.messageId,
    required this.content,
    required this.timestamp,
    required this.isRead,
    required this.isMe,
    this.onLongPress,
  });

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return 'Just now';

    DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else {
      return 'Just now';
    }

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isMe
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: isMe
                    ? const Radius.circular(18)
                    : const Radius.circular(4),
                bottomRight: isMe
                    ? const Radius.circular(4)
                    : const Radius.circular(18),
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 2,
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.3,
                    color: isMe ? Colors.white : theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(timestamp),
                      style: TextStyle(
                        fontSize: 11,
                        color: isMe
                            ? Colors.white.withOpacity(0.8)
                            : theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        isRead ? Icons.done_all : Icons.done,
                        size: 14,
                        color: isRead
                            ? Colors.blue.shade200
                            : Colors.white.withOpacity(0.8),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ChatService class
class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String getChatId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return '${ids[0]}_${ids[1]}';
  }

  Future<String> getOrCreateChat({
    required String currentUserId,
    required String currentUserName,
    required String otherUserId,
    required String otherUserName,
    String otherUserAvatar = 'assets/images/avatar.png',
  }) async {
    final chatId = getChatId(currentUserId, otherUserId);
    final chatDoc = await _firestore.collection('chats').doc(chatId).get();

    if (!chatDoc.exists) {
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
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSenderId': '',
      });
    }
    return chatId;
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String content,
  }) async {
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

    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': content,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSenderId': senderId,
    });
  }

  Stream<QuerySnapshot> getMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<void> deleteMessage(String chatId, String messageId) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  Future<void> markAllAsRead(String chatId, String currentUserId) async {
    final unreadMessages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('senderId', isNotEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (var doc in unreadMessages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> clearChat(String chatId) async {
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

    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': '',
      'lastMessageSenderId': '',
    });
  }
}
