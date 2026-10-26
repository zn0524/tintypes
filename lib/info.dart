import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF051F20),
      appBar: AppBar(
        title: Text(
          'How it Works',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: const Color(0xFFdaf1de),
          ),
        ),
        backgroundColor: const Color(0xFF051F20),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF8EB69B)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Section Title
            Text(
              'About Tintypes',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFdaf1de),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Tintypes uses advanced image and text analysis models to help you determine if the info you are seeing online was artificially generated or manipulated. Use Tintypes to protect yourself from misinformation.",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFFF4F1EA),
                height: 1.5,
              ),
            ),

            const SizedBox(height: 32),

            // Image Checker Card Section
            _InfoSectionCard(
              icon: Icons.image_outlined,
              title: 'Image Checker',
              description:
                  'Just take a screenshot or picture of an image you aren’t sure about and upload it to our detection model and see how likely your image was generated or tampered by AI.',
            ),

            const SizedBox(height: 16),

            // Text Checker Card Section
            _InfoSectionCard(
              icon: Icons.notes_rounded,
              title: 'Text Checker',
              description:
                  'Paste some text - try to use at least one paragraph for the most accurate results - from an email, article, or essay and see how much of your text was likely written by AI.',
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable themed card helper matching your home screen cards
class _InfoSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _InfoSectionCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF235347).withOpacity(0.92),
      elevation: 3.0,
      shadowColor: const Color(0xFF071524).withOpacity(0.6),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B2B26).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 24, color: const Color(0xFF8EB69B)),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFdaf1de),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFFF4F1EA),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}