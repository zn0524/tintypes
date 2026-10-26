import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'info.dart';
import 'image.dart';
import 'text.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tintypes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF051F20),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF051F20),
        textTheme: GoogleFonts.outfitTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Clean, Unframed Photo Collage Background
          Positioned.fill(
            child: Container(
              color: const Color(0xFF051F20),
              child: Stack(
                children: [
                  Positioned(
                    top: -30,
                    left: -20,
                    child: Transform.rotate(
                      angle: -0.3,
                      child: const _AlbumPhoto(
                        width: 200,
                        height: 240,
                        assetPath: 'assets/images/photo1.jpg',
                      ),
                    ),
                  ),
                  Positioned(
                    top: 80,
                    right: -20,
                    child: Transform.rotate(
                      angle: 0.25,
                      child: const _AlbumPhoto(
                        width: 210,
                        height: 200,
                        assetPath: 'assets/images/photo2.jpg',
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: -20,
                    child: Transform.rotate(
                      angle: 0.2,
                      child: const _AlbumPhoto(
                        width: 230,
                        height: 260,
                        assetPath: 'assets/images/photo3.jpg',
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    right: -10,
                    child: Transform.rotate(
                      angle: -0.25,
                      child: const _AlbumPhoto(
                        width: 210,
                        height: 210,
                        assetPath: 'assets/images/photo4.jpg',
                      ),
                    ),
                  ),

                  // 2. Lighter Overlap Layer
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF051F20).withOpacity(0.65),
                          const Color(0xFF051F20).withOpacity(0.82),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Foreground App Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 24.0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom -
                      48,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Branding
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF235347).withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.12),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_rounded,
                            color: Color(0xFF8EB69B),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'TINTYPES',
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.5,
                            color: const Color(0xFFdaf1de),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Main Headline and Subtitle
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Real or Generated?",
                          style: GoogleFonts.outfit(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF8EB69B),
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Instantly spot deepfakes, AI art, or machine-written text. Just upload a picture or paste some text.",
                          style: TextStyle(
                            fontSize: 17,
                            color: Color(0xFFF4F1EA),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Primary Action Cards with Navigation
                        _ActionCard(
                          icon: Icons.image_outlined,
                          title: 'Check an Image',
                          subtitle: 'Upload a photo, graphic, or screenshot',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ImageCheckerScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        _ActionCard(
                          icon: Icons.notes_rounded,
                          title: 'Check Text',
                          subtitle: 'Paste an article, email, or message',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TextCheckerScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Footer Option with Navigation to InfoScreen
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const InfoScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.info_outline_rounded, size: 20),
                        label: const Text(
                          'How it works',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF8EB69B),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Unframed, Sharp Photo Widget
class _AlbumPhoto extends StatelessWidget {
  final double width;
  final double height;
  final String assetPath;

  const _AlbumPhoto({
    required this.width,
    required this.height,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: 0.85,
          child: Image.asset(
            assetPath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: const Color(0xFF133832),
              child: const Center(
                child: Icon(
                  Icons.broken_image,
                  color: Color(0xFF8EB69B),
                  size: 30,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF235347).withOpacity(0.92),
      elevation: 3.0,
      shadowColor: const Color(0xFF071524).withOpacity(0.6),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B2B26).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28, color: const Color(0xFFF4F1EA)),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFdaf1de),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFF4F1EA),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Color(0xFFF4F1EA),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
