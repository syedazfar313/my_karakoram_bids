import 'package:flutter/material.dart';

class FAQsScreen extends StatefulWidget {
  const FAQsScreen({super.key});

  @override
  State<FAQsScreen> createState() => _FAQsScreenState();
}

class _FAQsScreenState extends State<FAQsScreen> {
  final List<FAQItem> faqs = [
    FAQItem(
      question: "Karakoram Bids kya hai?",
      answer:
          "Karakoram Bids ek platform hai jo clients aur contractors ko connect karta hai. Clients apne construction projects post kar sakte hain aur contractors bid laga sakte hain.",
    ),
    FAQItem(
      question: "Kya main free mein account bana sakta hun?",
      answer:
          "Haan bilkul! Account banana completely free hai. Aap client ya contractor dono ke roop mein register kar sakte hain.",
    ),
    FAQItem(
      question: "Payment kaise karta hai?",
      answer:
          "Payment clients aur contractors ke beech direct hoti hai. Hum recommend karte hain ke secure payment methods use karein jaise bank transfer ya mobile banking.",
    ),
    FAQItem(
      question: "Kya platform ka koi service fee hai?",
      answer:
          "Haan, successful project connections pe humara chhota sa service fee hai. Ye fee project complete hone ke baad charge hoti hai.",
    ),
    FAQItem(
      question: "Main apna project kaise post karun?",
      answer:
          "Login karne ke baad 'Post Project' section mein jaayen, project details fill karein, budget aur location add karein, phir submit kar dein.",
    ),
    FAQItem(
      question: "Contractor ke roop mein bid kaise lagaayen?",
      answer:
          "Browse Projects section mein available projects dekh sakte hain, interested project pe click karke apna bid amount aur timeline submit kar sakte hain.",
    ),
    FAQItem(
      question: "Kya main multiple projects pe bid laga sakta hun?",
      answer:
          "Haan, aap multiple projects pe bid laga sakte hain. Bas make sure karein ke aap har project ko properly handle kar saken.",
    ),
    FAQItem(
      question: "Contract aur agreement kaun banayega?",
      answer:
          "Clients aur contractors ko apne beech proper agreement karna chahiye. Hum recommend karte hain written contract banayein.",
    ),
    FAQItem(
      question: "Agar koi dispute ho to kya karna hai?",
      answer:
          "Pehle direct client/contractor se baat karke resolve karne ki koshish karein. Agar issue resolve nahi hota to humein contact karein.",
    ),
    FAQItem(
      question: "Material kaun provide karega?",
      answer:
          "Ye client aur contractor ke beech decide hota hai. Project post karte waqt clearly mention karein ke material kaun provide karega.",
    ),
    FAQItem(
      question: "Profile mein kya information add karun?",
      answer:
          "Apna complete profile banayein - experience, completed projects, contact details, aur relevant certifications add karein.",
    ),
    FAQItem(
      question: "Kya main apna bid cancel kar sakta hun?",
      answer:
          "Haan, agar abhi tak accept nahi hua hai to bid cancel kar sakte hain. Lekin accepted bid cancel karna professional nahi hai.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("FAQs"),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Frequently Asked Questions",
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Common questions and answers about using Karakoram Bids",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            ...faqs.map((faq) => _buildFAQItem(faq, theme)).toList(),

            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.help_center,
                    color: Colors.green.shade700,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Still have questions?",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Contact our support team at support@karakorambids.com",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.green.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(FAQItem faq, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          faq.question,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              faq.answer,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.4,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}
