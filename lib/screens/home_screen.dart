import 'package:flutter/material.dart';
import '../main.dart';
import '../models.dart';
import '../services.dart';
import 'chapter_list_screen.dart';

// ============================================================
// HOME SCREEN — στυλ εξωφύλλου βιβλίου
// ============================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFD4B060),
              Color(0xFFC9A84C),
              Color(0xFFB8903A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: 20, horizontal: 24),
                decoration: const BoxDecoration(
                  color: Color(0xFF7A5C1E),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ΙΤΥΕ · ΔΙΟΦΑΝΤΟΣ',
                      style: TextStyle(
                        color: AppColors.lightBeige.withOpacity(0.7),
                        fontSize: 11,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Γ΄ ΓΕΝΙΚΟΥ ΛΥΚΕΙΟΥ',
                      style: TextStyle(
                        color: AppColors.lightBeige.withOpacity(0.9),
                        fontSize: 12,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Main Content ─────────────────────────────────
              Expanded(
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: SlideTransition(
                    position: _slideUp,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Χημικοί τύποι (διακοσμητικοί)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              'H₂SO₄', 'HNO₃', 'KMnO₄',
                              'C₆H₁₂O₆', 'CH₃COOH', 'NH₃'
                            ].map((f) => Text(
                              f,
                              style: TextStyle(
                                color: AppColors.dark.withOpacity(0.25),
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w600,
                              ),
                            )).toList(),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Τίτλος
                        Text(
                          'Χημεία',
                          style: TextStyle(
                            color: AppColors.dark,
                            fontSize: 56,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            letterSpacing: -1,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.2),
                                offset: const Offset(2, 3),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Υπότιτλος
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.dark,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Ομάδας Προσανατολισμού Θετικών Σπουδών',
                            style: TextStyle(
                              color: AppColors.lightBeige,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Κουμπί Έναρξης
                        _StartButton(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ChapterListScreen(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        Text(
                          '174 ερωτήσεις · 13 κεφάλαια',
                          style: TextStyle(
                            color: AppColors.dark.withOpacity(0.6),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Footer ──────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: AppColors.dark,
                child: const Center(
                  child: Text(
                    'eisatopon.gr',
                    style: TextStyle(
                      color: AppColors.lightBeige,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  final VoidCallback onTap;
  const _StartButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.dark,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: const Text(
          'ΕΝΑΡΞΗ ΕΞΕΤΑΣΗΣ',
          style: TextStyle(
            color: AppColors.lightBeige,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
