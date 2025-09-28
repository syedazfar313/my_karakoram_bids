import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Privacy Policy",
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Last updated: ${DateTime.now().year}",
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              title: "Information We Collect",
              content:
                  "We collect information you provide directly to us, such as when you create an account, post a project, place bids, or contact us for support. This includes:\n\n• Name and contact information\n• Profile information\n• Project details and bid information\n• Messages and communications\n• Payment information (processed securely)",
              theme: theme,
            ),

            _buildSection(
              title: "How We Use Your Information",
              content:
                  "We use the information we collect to:\n\n• Provide and maintain our services\n• Connect clients with contractors\n• Process transactions and payments\n• Send important notifications\n• Improve our app and user experience\n• Comply with legal obligations",
              theme: theme,
            ),

            _buildSection(
              title: "Information Sharing",
              content:
                  "We do not sell, trade, or rent your personal information to third parties. We may share your information only in the following circumstances:\n\n• With your consent\n• To complete transactions\n• To comply with legal requirements\n• To protect our rights and safety",
              theme: theme,
            ),

            _buildSection(
              title: "Data Security",
              content:
                  "We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. However, no method of transmission over the internet is 100% secure.",
              theme: theme,
            ),

            _buildSection(
              title: "Your Rights",
              content:
                  "You have the right to:\n\n• Access your personal information\n• Update or correct your data\n• Delete your account\n• Opt-out of marketing communications\n• Request a copy of your data",
              theme: theme,
            ),

            _buildSection(
              title: "Contact Us",
              content:
                  "If you have any questions about this Privacy Policy, please contact us at:\n\nEmail: privacy@karakorambids.com\nPhone: +92-300-1234567\nAddress: Gilgit, Pakistan",
              theme: theme,
            ),

            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                "By using Karakoram Bids, you agree to the collection and use of information in accordance with this policy.",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.blue.shade800,
                ),
                textAlign: TextAlign.center,
              ),
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
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.5,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
