import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';

// Service import karein
// import '../services/chat_service.dart';

class MessagesListScreen extends StatefulWidget {
  final String userType; // "Client" or "Contractor"
  const MessagesListScreen({super.key, required this.userType});

  @override
  State<MessagesListScreen> createState() => _MessagesListScreenState();
}

class _MessagesListScreenState extends State<MessagesListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Current user ID - Firebase Auth se lena
  late final String currentUserId;
  late final String currentUserName;

  final ChatService _chatService = ChatService();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    // Initialize user ID
    final auth = FirebaseAuth.instance;
    if (auth.currentUser != null) {
      currentUserId = auth.currentUser!.uid;
      currentUserName = auth.currentUser!.displayName ?? 'User';
    } else {
      // Demo user for testing
      currentUserId = 'demo_user_${DateTime.now().millisecondsSinceEpoch}';
      currentUserName = 'Demo User';
    }

    print('📱 Current User ID: $currentUserId');
    print('👤 Current User Name: $currentUserName');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return 'Recently';

    DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else {
      return 'Recently';
    }

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${(difference.inDays / 7).floor()} week${(difference.inDays / 7).floor() > 1 ? 's' : ''} ago';
    }
  }

  List<Map<String, dynamic>> _filterChats(List<Map<String, dynamic>> chats) {
    if (_searchQuery.isEmpty) return chats;

    final query = _searchQuery.toLowerCase();
    return chats.where((chat) {
      return (chat['name']?.toLowerCase().contains(query) ?? false) ||
          (chat['lastMessage']?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  Future<void> _refreshMessages() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Messages refreshed'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Widget _buildEmptyState() {
    if (_searchQuery.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'No Messages Found',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No conversations found for "$_searchQuery"',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _searchController.clear(),
                child: const Text('Clear Search'),
              ),
            ],
          ),
        ),
      );
    } else {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: Colors.blue[300],
              ),
              const SizedBox(height: 16),
              const Text(
                'No Messages Yet',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start conversations with ${widget.userType.toLowerCase() == "client" ? "contractors" : "clients"} to discuss projects.',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search messages...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: theme.colorScheme.primary),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ),

          // Messages List - Real-time Stream
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatService.getUserChatsStream(currentUserId),
              builder: (context, snapshot) {
                // Debug info
                print('🔍 Stream state: ${snapshot.connectionState}');
                print('🆔 Querying with userId: $currentUserId');

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  print('❌ Stream error: ${snapshot.error}');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Error loading chats',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${snapshot.error}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'User ID: $currentUserId',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final chatDocs = snapshot.data?.docs ?? [];
                print('💬 Found ${chatDocs.length} chats');

                // Convert to list of maps
                final allChats = chatDocs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final otherUser = _chatService.getOtherUserInfo(
                    data,
                    currentUserId,
                  );

                  return {
                    'chatId': doc.id,
                    'name': otherUser['name']!,
                    'lastMessage': data['lastMessage'] ?? '',
                    'time': _formatTime(data['lastMessageTime']),
                    'timestamp': data['lastMessageTime'],
                    'avatar': otherUser['avatar']!,
                    'otherUserId': otherUser['userId']!,
                    'unreadCount': 0,
                  };
                }).toList();

                final filteredChats = _filterChats(allChats);

                if (_searchQuery.isNotEmpty) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Text(
                              '${filteredChats.length} conversation${filteredChats.length == 1 ? '' : 's'} found',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: filteredChats.isEmpty
                            ? _buildEmptyState()
                            : _buildChatList(filteredChats),
                      ),
                    ],
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refreshMessages,
                  child: filteredChats.isEmpty
                      ? _buildEmptyState()
                      : _buildChatList(filteredChats),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList(List<Map<String, dynamic>> chats) {
    return ListView.separated(
      padding: const EdgeInsets.only(top: 12),
      itemCount: chats.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final chat = chats[index];
        final hasUnread = chat['unreadCount'] > 0;

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage(chat["avatar"]!),
            radius: 24,
            onBackgroundImageError: (exception, stackTrace) {},
            child: chat["avatar"]!.isEmpty ? const Icon(Icons.person) : null,
          ),
          title: Text(
            chat["name"]!,
            style: TextStyle(
              fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
              fontSize: 15,
            ),
          ),
          subtitle: Text(
            chat["lastMessage"]!.isEmpty
                ? 'No messages yet'
                : chat["lastMessage"]!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
              fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                chat["time"]!,
                style: TextStyle(
                  color: hasUnread
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade500,
                  fontSize: 12,
                  fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (hasUnread) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${chat['unreadCount']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  chatId: chat["chatId"]!,
                  otherUserId: chat["otherUserId"]!,
                  otherUserName: chat["name"]!,
                  otherUserAvatar: chat["avatar"]!,
                  currentUserId: currentUserId,
                  currentUserName: currentUserName,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ChatService class - Same as before
class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String getChatId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return '${ids[0]}_${ids[1]}';
  }

  Stream<QuerySnapshot> getUserChatsStream(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

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
