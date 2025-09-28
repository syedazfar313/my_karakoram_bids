import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("About Us"),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App logo/icon section
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.home_work,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Karakoram Bids",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    "Build Better • Faster • Smarter",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            _buildSection(
              title: "Our Mission",
              content:
                  "Karakoram Bids ka mission hai Gilgit Baltistan mein construction industry ko digitalize karna aur clients ko skilled contractors se connect karna. Hum transparent, efficient aur affordable construction services provide karte hain.",
              icon: Icons.flag,
              theme: theme,
            ),

            _buildSection(
              title: "Our Vision",
              content:
                  "Humara vision hai Gilgit baltistan ka number 1 construction marketplace banana jahan har client ko best contractors mil saken aur har contractor ko genuine projects mil saken.",
              icon: Icons.visibility,
              theme: theme,
            ),

            _buildSection(
              title: "What We Do",
              content:
                  "• Clients aur contractors ko connect karte hain\n• Project bidding platform provide karte hain\n• Quality assurance ensure karte hain\n• Secure communication facilitate karte hain\n• Construction industry ko modern banate hain",
              icon: Icons.work,
              theme: theme,
            ),

            _buildSection(
              title: "Why Choose Us",
              content:
                  "• 100% Free registration\n• Verified contractors\n• Secure platform\n• 24/7 customer support\n• Wide network across Pakistan\n• Transparent bidding process",
              icon: Icons.star,
              theme: theme,
            ),

            _buildSection(
              title: "Our Values",
              content:
                  "• Trust aur transparency\n• Quality workmanship\n• Customer satisfaction\n• Innovation aur technology\n• Supporting local businesses\n• Building strong communities",
              icon: Icons.favorite,
              theme: theme,
            ),

            const SizedBox(height: 32),

            // Statistics section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    "Our Impact",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat("500+", "Projects", Colors.white),
                      _buildStat("200+", "Contractors", Colors.white),
                      _buildStat("1000+", "Happy Clients", Colors.white),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Contact section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.contact_mail,
                    color: theme.colorScheme.primary,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Get in Touch",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Questions ya suggestions hain? Hum sunne ke liye ready hain!",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to contact screen
                    },
                    child: const Text("Contact Us"),
                  ),
                ],
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
    required IconData icon,
    required ThemeData theme,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String number, String label, Color color) {
    return Column(
      children: [
        Text(
          number,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: color.withOpacity(0.9)),
        ),
      ],
    );
  }
}
