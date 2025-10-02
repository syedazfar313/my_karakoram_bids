import 'package:flutter/material.dart';
import 'dart:io';
import '../common/chat_screen.dart';
import 'contractor_profile_view_screen.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Map<String, dynamic> project;
  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  // Track accepted/rejected bids
  final Map<String, String> _bidStatuses = {}; // bidId -> status

  @override
  Widget build(BuildContext context) {
    final bids = widget.project['bids'] ?? [];
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.project['title'] ?? 'Project Details',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (widget.project['planImage'] != null)
            IconButton(
              icon: const Icon(Icons.fullscreen, color: Colors.white),
              onPressed: () =>
                  _showFullScreenImage(context, widget.project['planImage']),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Image (Naksha) - ENHANCED SECTION
            if (widget.project['planImage'] != null) ...[
              Container(
                width: double.infinity,
                height: 300,
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () => _showFullScreenImage(
                        context,
                        widget.project['planImage'],
                      ),
                      child: Container(
                        width: double.infinity,
                        height: 300,
                        child: Image.file(
                          widget.project['planImage'] as File,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 300,
                              color: Colors.grey[200],
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image,
                                      size: 80,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Image not available',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.architecture,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Floor Plan / Naksha',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _showFullScreenImage(
                                context,
                                widget.project['planImage'],
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                child: const Text(
                                  'View Full',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                height: 150,
                color: Colors.grey[100],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No floor plan uploaded',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],

            // Content Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Project Title
                  Text(
                    widget.project['title'] ?? 'Untitled Project',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Project Info Cards
                  Row(
                    children: [
                      if (widget.project['budget'] != null &&
                          widget.project['budget'].isNotEmpty)
                        Expanded(
                          child: _buildInfoCard(
                            icon: Icons.attach_money,
                            title: 'Budget',
                            value: 'PKR ${widget.project['budget']}',
                            color: Colors.green.shade700,
                            backgroundColor: Colors.green.shade50,
                          ),
                        ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInfoCard(
                          icon: Icons.location_on,
                          title: 'Location',
                          value: widget.project['location'] ?? 'Not specified',
                          color: Colors.blue.shade700,
                          backgroundColor: Colors.blue.shade50,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Description Section
                  _buildSection(
                    title: 'Project Description',
                    content:
                        widget.project['description'] ??
                        'No description provided.',
                    theme: theme,
                  ),

                  if (widget.project['planImage'] != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.blue.shade700,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Floor Plan Available',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Detailed architectural plan has been uploaded',
                                  style: TextStyle(
                                    color: Colors.blue.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showFullScreenImage(
                              context,
                              widget.project['planImage'],
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.shade300),
                              ),
                              child: Text(
                                'View',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Bids Section
                  Row(
                    children: [
                      Text(
                        'Bids Received',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${bids.length}',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Bids List or Empty State
                  _buildBidsSection(bids, theme),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Color backgroundColor,
  }) {
    return Card(
      color: backgroundColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBidsSection(List bids, ThemeData theme) {
    if (bids.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              'No bids received yet',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Contractors will see your project and place bids',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: bids.map<Widget>((bid) {
        final bidId =
            bid['id']?.toString() ?? bid['contractorId']?.toString() ?? '';
        final currentStatus = _bidStatuses[bidId] ?? 'pending';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Contractor Name and Amount
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Icon(Icons.person, color: Colors.blue.shade700),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bid['contractorName'] ?? 'Unknown Contractor',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Completion: ${bid['days']} days',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'PKR ${bid['amount']}',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),

                if (bid['comment'] != null && bid['comment'].isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      bid['comment'],
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Action Buttons based on status
                if (currentStatus == 'pending') ...[
                  // Profile View button for pending bids
                  OutlinedButton.icon(
                    onPressed: () => _viewProfile(bid),
                    icon: const Icon(Icons.person, size: 18),
                    label: const Text('View Contractor Profile'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _acceptBid(bid, bidId),
                          icon: const Icon(Icons.check_circle, size: 18),
                          label: const Text('Hire'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _rejectBid(bid, bidId),
                          icon: const Icon(Icons.cancel, size: 18),
                          label: const Text('Reject'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else if (currentStatus == 'accepted') ...[
                  // Show Message and Profile View buttons after hiring
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Contractor Hired',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _openChat(bid),
                          icon: const Icon(Icons.message, size: 18),
                          label: const Text('Message'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _viewProfile(bid),
                          icon: const Icon(Icons.person, size: 18),
                          label: const Text('View Profile'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            side: const BorderSide(color: Colors.blue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else if (currentStatus == 'rejected') ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.cancel,
                          color: Colors.red.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Bid Rejected',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showFullScreenImage(BuildContext context, File imageFile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(imageFile: imageFile),
      ),
    );
  }

  void _acceptBid(Map<String, dynamic> bid, String bidId) {
    setState(() {
      _bidStatuses[bidId] = 'accepted';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contractor Hired Successfully!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'You can now message ${bid['contractorName']} to discuss project details',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );

    debugPrint('Hired contractor: ${bid['contractorName']}');
    debugPrint('Bid Amount: PKR ${bid['amount']}');
  }

  void _rejectBid(Map<String, dynamic> bid, String bidId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Bid'),
        content: Text(
          'Are you sure you want to reject the bid from ${bid['contractorName']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _bidStatuses[bidId] = 'rejected';
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Bid from ${bid['contractorName']} rejected'),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 2),
                ),
              );

              debugPrint('Rejected bid from ${bid['contractorName']}');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _openChat(Map<String, dynamic> bid) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          userName: bid['contractorName'] ?? 'Contractor',
          userImage: 'assets/images/avatar.png',
        ),
      ),
    );
  }

  void _viewProfile(Map<String, dynamic> bid) {
    final bidId =
        bid['id']?.toString() ?? bid['contractorId']?.toString() ?? '';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContractorProfileViewScreen(
          bid: bid,
          onHire: () => _acceptBid(bid, bidId),
          onMessage: () => _openChat(bid),
        ),
      ),
    );
  }
}

// Full Screen Image Viewer
class FullScreenImageViewer extends StatelessWidget {
  final File imageFile;

  const FullScreenImageViewer({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Floor Plan', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share functionality not implemented yet'),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.file(
            imageFile,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, size: 80, color: Colors.white54),
                    SizedBox(height: 16),
                    Text(
                      'Unable to load image',
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
