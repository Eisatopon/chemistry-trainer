import 'package:flutter/material.dart';
import '../main.dart';
import '../models.dart';
import '../services.dart';
import 'quiz_screen.dart';

class ChapterListScreen extends StatefulWidget {
  const ChapterListScreen({super.key});

  @override
  State<ChapterListScreen> createState() => _ChapterListScreenState();
}

class _ChapterListScreenState extends State<ChapterListScreen> {
  List<Chapter> _chapters = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final chapters = await ContentService.fetchChapters();
      setState(() { _chapters = chapters; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        foregroundColor: AppColors.lightBeige,
        title: const Text(
          'Επιλογή Κεφαλαίου',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        elevation: 0,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.dark),
            )
          : _error != null
              ? _ErrorWidget(message: _error!, onRetry: _load)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _chapters.length,
                  itemBuilder: (ctx, i) =>
                      _ChapterCard(chapter: _chapters[i]),
                ),
    );
  }
}

class _ChapterCard extends StatefulWidget {
  final Chapter chapter;
  const _ChapterCard({required this.chapter});

  @override
  State<_ChapterCard> createState() => _ChapterCardState();
}

class _ChapterCardState extends State<_ChapterCard> {
  QuizResult? _result;

  @override
  void initState() {
    super.initState();
    _loadResult();
  }

  Future<void> _loadResult() async {
    final r = await ProgressService.loadResult(
        widget.chapter.id, widget.chapter.questionCount);
    if (mounted) setState(() => _result = r);
  }

  Color get _progressColor {
    if (_result == null) return Colors.transparent;
    final p = _result!.percentage;
    if (p >= 80) return AppColors.correct;
    if (p >= 50) return Colors.orange.shade700;
    return AppColors.wrong;
  }

  @override
  Widget build(BuildContext context) {
    final chapter = widget.chapter;
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuizScreen(chapter: chapter),
          ),
        );
        _loadResult();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.dark.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          children: [
            // Αριστερή χρωματιστή λωρίδα
            Container(
              width: 6,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.dark,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Περιεχόμενο
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.dark.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            chapter.section,
                            style: const TextStyle(
                              color: AppColors.darkText,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${chapter.questionCount} ερωτήσεις',
                          style: TextStyle(
                            color: AppColors.dark.withOpacity(0.6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      chapter.subtitle,
                      style: const TextStyle(
                        color: AppColors.darkText,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Δεξιά: score ή βέλος
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _result != null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_result!.percentage.round()}%',
                          style: TextStyle(
                            color: _progressColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${_result!.correctAnswers}/${_result!.totalQuestions}',
                          style: TextStyle(
                            color: AppColors.dark.withOpacity(0.5),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    )
                  : Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.dark.withOpacity(0.4),
                      size: 28,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 48, color: AppColors.dark),
            const SizedBox(height: 16),
            const Text(
              'Δεν ήταν δυνατή η σύνδεση.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.darkText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dark,
                foregroundColor: AppColors.lightBeige,
              ),
              child: const Text('Επανάληψη'),
            ),
          ],
        ),
      ),
    );
  }
}
