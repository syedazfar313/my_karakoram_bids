import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class ContractorProfileViewScreen extends StatefulWidget {
  final Map<String, dynamic> bid;
  final VoidCallback? onHire;
  final VoidCallback? onMessage;

  const ContractorProfileViewScreen({
    super.key,
    required this.bid,
    this.onHire,
    this.onMessage,
  });

  @override
  State<ContractorProfileViewScreen> createState() =>
      _ContractorProfileViewScreenState();
}

class _ContractorProfileViewScreenState
    extends State<ContractorProfileViewScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _contractorData;

  @override
  void initState() {
    super.initState();
    _fetchContractorProfile();
  }

  Future<void> _fetchContractorProfile() async {
    setState(() => _isLoading = true);

    try {
      final contractorId = widget.bid['contractorId'];

      print('🔍 Fetching contractor profile for ID: $contractorId');

      if (contractorId == null || contractorId.toString().isEmpty) {
        print('❌ Contractor ID is null or empty');
        setState(() => _isLoading = false);
        return;
      }

      // Fetch contractor data from users collection
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(contractorId.toString())
          .get();

      if (docSnapshot.exists) {
        setState(() {
          _contractorData = docSnapshot.data();
          _isLoading = false;
        });
        print('✅ Contractor profile loaded successfully');
      } else {
        print('❌ Contractor profile not found');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('❌ Error fetching contractor profile: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading contractor profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildProfileImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const CircleAvatar(
        radius: 50,
        backgroundColor: Colors.white,
        child: Icon(Icons.person, size: 50, color: Colors.blue),
      );
    }

    if (imageUrl.startsWith('/') || imageUrl.startsWith('file://')) {
      return CircleAvatar(
        radius: 50,
        backgroundColor: Colors.white,
        backgroundImage: FileImage(File(imageUrl)),
        onBackgroundImageError: (exception, stackTrace) {
          debugPrint('Error loading local image: $exception');
        },
      );
    } else {
      return CircleAvatar(
        radius: 50,
        backgroundColor: Colors.white,
        backgroundImage: NetworkImage(imageUrl),
        onBackgroundImageError: (exception, stackTrace) {
          debugPrint('Error loading network image: $exception');
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Contractor Profile'),
          backgroundColor: theme.colorScheme.primary,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Use contractor data from Firestore, fallback to bid data
    final contractorName =
        _contractorData?['name'] ??
        widget.bid['contractorName'] ??
        'Unknown Contractor';
    final email = _contractorData?['email'] ?? 'Not provided';
    final phone = _contractorData?['phone'] ?? 'Not provided';
    final location = _contractorData?['location'] ?? 'Not provided';
    final experience = _contractorData?['experience'] ?? 'Not provided';
    final imageUrl = _contractorData?['imageUrl'] ?? '';
    final completedProjects = _contractorData?['completedProjects'] ?? [];

    final bidAmount = widget.bid['amount'] ?? '0';
    final completionDays = widget.bid['days'] ?? '0';
    final proposal = widget.bid['comment'] ?? widget.bid['message'] ?? '';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: theme.colorScheme.primary,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    GestureDetector(
                      onTap: imageUrl.isNotEmpty
                          ? () => _showFullScreenImage(context, imageUrl)
                          : null,
                      child: _buildProfileImage(imageUrl),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      contractorName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Professional Contractor',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),

                // Bid Details Card
                _buildBidCard(bidAmount, completionDays, proposal),

                const SizedBox(height: 12),

                // Contact Information Card
                _buildContactCard(email, phone, location),

                const SizedBox(height: 12),

                // Professional Details Card
                _buildProfessionalCard(experience, completedProjects),

                const SizedBox(height: 12),

                // Skills Card
                _buildSkillsCard(),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    if (widget.onMessage != null) widget.onMessage!();
                  },
                  icon: const Icon(Icons.message, size: 20),
                  label: const Text('Message'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    if (widget.onHire != null) widget.onHire!();
                  },
                  icon: const Icon(Icons.check_circle, size: 20),
                  label: const Text('Hire Contractor'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBidCard(String amount, String days, String proposal) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.gavel, color: Colors.orange.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Current Bid Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(
                  Icons.attach_money,
                  'Bid Amount',
                  'PKR $amount',
                  Colors.green,
                ),
                const Divider(height: 24),
                _buildInfoRow(
                  Icons.calendar_today,
                  'Completion Time',
                  '$days days',
                  Colors.blue,
                ),
                if (proposal.isNotEmpty) ...[
                  const Divider(height: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.description,
                            color: Colors.purple.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Proposal',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.purple.shade200),
                        ),
                        child: Text(
                          proposal,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade800,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(String email, String phone, String location) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.contact_phone,
                  color: Colors.blue.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Contact Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(Icons.email, 'Email', email, Colors.blue),
                const Divider(height: 24),
                _buildInfoRow(Icons.phone, 'Phone', phone, Colors.green),
                const Divider(height: 24),
                _buildInfoRow(
                  Icons.location_on,
                  'Location',
                  location,
                  Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalCard(
    String experience,
    List<dynamic> completedProjects,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.work, color: Colors.purple.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Professional Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade700,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(
                  Icons.school,
                  'Experience',
                  experience,
                  Colors.purple,
                ),
                if (completedProjects.isNotEmpty) ...[
                  const Divider(height: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.teal.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Completed Projects',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: completedProjects.map((project) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.teal.shade200),
                            ),
                            child: Text(
                              project.toString(),
                              style: TextStyle(
                                color: Colors.teal.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsCard() {
    final skills = [
      'House Construction',
      'Commercial Buildings',
      'Renovation',
      'Grey Structure',
      'Finishing Work',
      'Project Management',
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.construction, color: Colors.orange.shade600, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Skills & Expertise',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills.map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  skill,
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'Profile Picture',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4.0,
              child: imageUrl.startsWith('/') || imageUrl.startsWith('file://')
                  ? Image.file(File(imageUrl), fit: BoxFit.contain)
                  : Image.network(imageUrl, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}
