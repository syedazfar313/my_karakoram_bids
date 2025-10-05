// lib/screens/contractor/my_bids.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyBidsPage extends StatefulWidget {
  final List<Map<String, dynamic>> myBids;
  const MyBidsPage({super.key, required this.myBids});

  @override
  State<MyBidsPage> createState() => _MyBidsPageState();
}

class _MyBidsPageState extends State<MyBidsPage> {
  List<Map<String, dynamic>> _allBids = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyBids();
  }

  // Database se apne bids fetch karna
  Future<void> _fetchMyBids() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Pehle createdAt field ke saath try karo
      QuerySnapshot snapshot;
      try {
        snapshot = await FirebaseFirestore.instance
            .collection('bids')
            .where('contractorId', isEqualTo: currentUser.uid)
            .orderBy('createdAt', descending: true)
            .get();
      } catch (e) {
        // Agar createdAt se sort nahi ho sakta to bina sort ke fetch karo
        print('Fetching without orderBy: $e');
        snapshot = await FirebaseFirestore.instance
            .collection('bids')
            .where('contractorId', isEqualTo: currentUser.uid)
            .get();
      }

      List<Map<String, dynamic>> fetchedBids = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> bidData = doc.data() as Map<String, dynamic>;
        bidData['id'] = doc.id;

        // Timestamp ko String mein convert karna
        if (bidData['createdAt'] is Timestamp) {
          bidData['createdAt'] = (bidData['createdAt'] as Timestamp)
              .toDate()
              .toIso8601String();
        } else if (bidData['createdAt'] == null) {
          // Agar createdAt null hai to current time set kar do
          bidData['createdAt'] = DateTime.now().toIso8601String();
        }

        fetchedBids.add(bidData);
      }

      // Manual sort kar lo agar orderBy kaam nahi kiya
      fetchedBids.sort((a, b) {
        try {
          final dateA = DateTime.parse(a['createdAt'] ?? '');
          final dateB = DateTime.parse(b['createdAt'] ?? '');
          return dateB.compareTo(dateA); // Descending order
        } catch (e) {
          return 0;
        }
      });

      setState(() {
        _allBids = fetchedBids;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching bids: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading bids: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _refreshBids() async {
    await _fetchMyBids();
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_allBids.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.gavel_outlined, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                "No bids placed yet",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Browse projects and place your first bid",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshBids,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _allBids.length,
        itemBuilder: (context, index) {
          final bid = _allBids[index];
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Project Title
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          bid['projectTitle'] ??
                              bid['project'] ??
                              'Untitled Project',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            bid['status'],
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getStatusColor(bid['status']),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          bid['status'] ?? 'Pending',
                          style: TextStyle(
                            color: _getStatusColor(bid['status']),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Bid Details
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          Icons.attach_money,
                          'Bid Amount',
                          'PKR ${bid['amount'] ?? bid['bidAmount'] ?? '0'}',
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          Icons.calendar_today,
                          'Duration',
                          '${bid['days'] ?? bid['duration'] ?? '0'} days',
                        ),
                      ),
                    ],
                  ),
                  if (bid['message'] != null &&
                      bid['message'].toString().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 4),
                    Text(
                      'Message:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bid['message'],
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                  if (bid['createdAt'] != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Submitted on ${_formatDate(bid['createdAt'])}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
