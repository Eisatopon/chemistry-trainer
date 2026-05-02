import 'package:flutter/material.dart';
import '../main.dart';
import '../models.dart';

class ResultsScreen extends StatelessWidget {
  final QuizResult result;
  final Chapter chapter;

  const ResultsScreen({
    super.key,
    required this.result,
    required this.chapter,
  });

  Color get _scoreColor {
    final p = result.percentage;
    if (p >= 80) return AppColors.correct;
    if (p >= 50) return Colors.orange.shade700;
    return AppColors.wrong;
  }

  String get _message {
    final p = result.percentage;
    if (p >= 90) return 'Άριστα! Εξαιρετική επίδοση!';
    if (p >= 80) return 'Πολύ καλά! Συνέχισε έτσι!';
    if (p >= 60) return 'Καλά! Λίγη ακόμα εξάσκηση!';
    if (p >= 40) return 'Χρειάζεσαι επανάληψη.';
    return 'Μελέτησε ξανά το κεφάλαιο.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: AppColors.dark,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events_rounded,
                      color: AppColors.gold, size: 28),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Αποτελέσματα',
                        style: TextStyle(
                          color: AppColors.lightBeige,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        chapter.subtitle,
                        style: TextStyle(
                          color: AppColors.lightBeige.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Score circle
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.cardBg,
                        border: Border.all(
                          color: _scoreColor,
                          width: 6,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _scoreColor.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${result.percentage.round()}%',
                            style: TextStyle(
                              color: _scoreColor,
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            '${result.correctAnswers}/${result.totalQuestions}',
                            style: TextStyle(
                              color: AppColors.darkText.withOpacity(0.6),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      _message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.darkText,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Stats
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: 'Σωστές',
                            value: '${result.correctAnswers}',
                            color: AppColors.correct,
                            icon: Icons.check_circle_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            label: 'Λανθασμένες',
                            value: '${result.wrongAnswers}',
                            color: AppColors.wrong,
                            icon: Icons.cancel_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            label: 'Σύνολο',
                            value: '${result.totalQuestions}',
                            color: AppColors.dark,
                            icon: Icons.quiz_rounded,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Buttons
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // → QuizScreen
                          Navigator.pop(context); // → ChapterList
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.dark,
                          foregroundColor: AppColors.lightBeige,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'ΕΠΙΛΟΓΗ ΚΕΦΑΛΑΙΟΥ',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.dark,
                          side: const BorderSide(color: AppColors.dark),
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'ΕΠΑΝΑΛΗΨΗ ΚΕΦΑΛΑΙΟΥ',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
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
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: AppColors.darkText.withOpacity(0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
