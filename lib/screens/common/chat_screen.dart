import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class ChatScreen extends StatefulWidget {
  final String userName;
  final String userImage;
  final String chatId;

  const ChatScreen({
    super.key,
    required this.userName,
    required this.userImage,
    this.chatId = '',
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<ChatMessage> messages = [];
  Timer? _typingTimer;
  bool _isTyping = false;
  bool _otherUserTyping = false;
  StreamSubscription? _messageSubscription;

  // Mock responses for demo
  final List<String> mockResponses = [
    "That sounds great! When can we start?",
    "I'm interested in this project. Can we discuss the details?",
    "What's your budget range for this work?",
    "I have 5 years of experience in construction.",
    "Can you share the project location?",
    "When do you need this completed?",
    "I can provide references if needed.",
    "Let me check my schedule and get back to you.",
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialMessages();
    _simulateRealTimeUpdates();
  }

  @override
  void dispose() {
    msgCtrl.dispose();
    _scrollCtrl.dispose();
    _typingTimer?.cancel();
    _messageSubscription?.cancel();
    super.dispose();
  }

  void _loadInitialMessages() {
    // Load some initial messages
    final initialMessages = [
      ChatMessage(
        id: '1',
        content: 'Hello! I saw your project posting.',
        senderId: 'other',
        senderName: widget.userName,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        isMe: false,
      ),
      ChatMessage(
        id: '2',
        content:
            'Hi! Thanks for your interest. Can you tell me about your experience?',
        senderId: 'me',
        senderName: 'You',
        timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
        isMe: true,
      ),
      ChatMessage(
        id: '3',
        content:
            'I have 3 years of construction experience and have completed similar projects.',
        senderId: 'other',
        senderName: widget.userName,
        timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        isMe: false,
      ),
    ];

    setState(() {
      messages.addAll(initialMessages);
    });

    _scrollToBottom();
  }

  void _simulateRealTimeUpdates() {
    // Simulate incoming messages occasionally
    _messageSubscription =
        Stream.periodic(const Duration(seconds: 30), (count) => count).listen((
          count,
        ) {
          if (mounted && Random().nextBool() && count < 5) {
            _simulateIncomingMessage();
          }
        });
  }

  void _simulateIncomingMessage() {
    final randomResponse =
        mockResponses[Random().nextInt(mockResponses.length)];
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: randomResponse,
      senderId: 'other',
      senderName: widget.userName,
      timestamp: DateTime.now(),
      isMe: false,
    );

    setState(() {
      messages.add(message);
    });

    _scrollToBottom();
    _showNewMessageNotification();
  }

  void _showNewMessageNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('New message from ${widget.userName}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(top: 100, left: 16, right: 16),
      ),
    );
  }

  void _sendMessage() {
    final text = msgCtrl.text.trim();
    if (text.isEmpty) return;

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: text,
      senderId: 'me',
      senderName: 'You',
      timestamp: DateTime.now(),
      isMe: true,
    );

    setState(() {
      messages.add(message);
      msgCtrl.clear();
      _isTyping = false;
    });

    _scrollToBottom();
    _simulateTypingResponse();
  }

  void _simulateTypingResponse() {
    // Show other user typing
    setState(() => _otherUserTyping = true);

    // Send response after 2-5 seconds
    Timer(Duration(seconds: 2 + Random().nextInt(3)), () {
      if (mounted) {
        setState(() => _otherUserTyping = false);

        // Send a relevant response
        final responses = [
          "Got it, thanks for the information!",
          "That works for me. Let's proceed.",
          "Sounds good! I'll prepare a detailed proposal.",
          "Perfect! When can we start?",
        ];

        final response = responses[Random().nextInt(responses.length)];
        final message = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: response,
          senderId: 'other',
          senderName: widget.userName,
          timestamp: DateTime.now(),
          isMe: false,
        );

        setState(() => messages.add(message));
        _scrollToBottom();
      }
    });
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

    // Reset typing timer
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isTyping = false);
      }
    });
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
                    backgroundImage: AssetImage(widget.userImage),
                    radius: 18,
                    onBackgroundImageError: (_, __) {},
                    child: widget.userImage.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.userName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_otherUserTyping)
                          Text(
                            'typing...',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.primary,
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        else
                          Text(
                            'Online',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade600,
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
                    onPressed: () {
                      _showOptionsMenu();
                    },
                  ),
                ],
              ),
            ),
          ),

          // Messages Area
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text(
                      'Start a conversation',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return MessageBubble(
                        message: message,
                        onLongPress: () => _showMessageOptions(message),
                      );
                    },
                  ),
          ),

          // Typing indicator
          if (_otherUserTyping)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 10,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildTypingDot(0),
                            _buildTypingDot(1),
                            _buildTypingDot(2),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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

  Widget _buildTypingDot(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500 + (index * 100)),
      width: 4,
      height: 4,
      decoration: const BoxDecoration(
        color: Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }

  void _showMessageOptions(ChatMessage message) {
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
                // Copy to clipboard logic
              },
            ),
            if (message.isMe)
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => messages.remove(message));
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
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Report'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.clear),
              title: const Text('Clear Chat'),
              onTap: () {
                Navigator.pop(context);
                setState(() => messages.clear());
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Chat Message Model
class ChatMessage {
  final String id;
  final String content;
  final String senderId;
  final String senderName;
  final DateTime timestamp;
  final bool isMe;
  final MessageType type;

  ChatMessage({
    required this.id,
    required this.content,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
    required this.isMe,
    this.type = MessageType.text,
  });
}

enum MessageType { text, image, file }

// Message Bubble Widget
class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onLongPress;

  const MessageBubble({super.key, required this.message, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
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
              color: message.isMe
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: message.isMe
                    ? const Radius.circular(18)
                    : const Radius.circular(4),
                bottomRight: message.isMe
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
                  message.content,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.3,
                    color: message.isMe
                        ? Colors.white
                        : theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 11,
                    color: message.isMe
                        ? Colors.white.withOpacity(0.8)
                        : theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

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
}
