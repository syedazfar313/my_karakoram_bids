import 'package:flutter/material.dart';
import 'chat_screen.dart';

class MessagesListScreen extends StatefulWidget {
  final String userType; // "Client" or "Contractor"
  const MessagesListScreen({super.key, required this.userType});

  @override
  State<MessagesListScreen> createState() => _MessagesListScreenState();
}

class _MessagesListScreenState extends State<MessagesListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _filteredChats = [];
  String _searchQuery = '';

  // Original chat data
  List<Map<String, String>> get _originalChats {
    return widget.userType.toLowerCase() == "client"
        ? _clientChats
        : _contractorChats;
  }

  final List<Map<String, String>> _clientChats = [
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
    {
      "name": "Ahmed Builders",
      "message": "Project ka estimate ready hai. Kab discuss kar sakte hain?",
      "time": "3 days ago",
      "avatar": "assets/images/avatar.png",
    },
    {
      "name": "Khan Construction",
      "message": "Material quality guarantee ke saath kaam karenge.",
      "time": "1 week ago",
      "avatar": "assets/images/avatar.png",
    },
  ];

  final List<Map<String, String>> _contractorChats = [
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
    {
      "name": "Muhammad Ali",
      "message": "Boundary wall ka kaam kab shuru kar sakte hain?",
      "time": "5 days ago",
      "avatar": "assets/images/avatar.png",
    },
    {
      "name": "Fatima Sheikh",
      "message": "Shop construction project ke liye meeting set karte hain.",
      "time": "1 week ago",
      "avatar": "assets/images/avatar.png",
    },
  ];

  @override
  void initState() {
    super.initState();
    _filteredChats = _originalChats;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filterChats();
    });
  }

  void _filterChats() {
    if (_searchQuery.isEmpty) {
      _filteredChats = _originalChats;
    } else {
      final query = _searchQuery.toLowerCase();
      _filteredChats = _originalChats.where((chat) {
        return (chat['name']?.toLowerCase().contains(query) ?? false) ||
            (chat['message']?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
  }

  Future<void> _refreshMessages() async {
    // Simulate refresh delay
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Messages refreshed successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildEmptyState() {
    if (_searchQuery.isNotEmpty) {
      // No search results
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
                onPressed: () {
                  _searchController.clear();
                },
                child: const Text('Clear Search'),
              ),
            ],
          ),
        ),
      );
    } else {
      // No messages at all
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
                        onPressed: () {
                          _searchController.clear();
                        },
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

          // Results count
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    '${_filteredChats.length} conversation${_filteredChats.length == 1 ? '' : 's'} found',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),

          // Messages List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshMessages,
              child: _filteredChats.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.only(top: 12),
                      itemCount: _filteredChats.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final chat = _filteredChats[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: AssetImage(chat["avatar"]!),
                            radius: 24,
                            onBackgroundImageError: (exception, stackTrace) {},
                            child: chat["avatar"]!.isEmpty
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          title: Text(
                            chat["name"]!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Text(
                            chat["message"]!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                          trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                chat["time"]!,
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Optional: Add unread message indicator
                              if (index <
                                  2) // First 2 messages as unread example
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
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
            ),
          ),
        ],
      ),
    );
  }
}
