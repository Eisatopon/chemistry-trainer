import 'package:flutter/material.dart';
import '../main.dart';
import '../models.dart';
import '../services.dart';
import 'results_screen.dart';

class QuizScreen extends StatefulWidget {
  final Chapter chapter;
  const QuizScreen({super.key, required this.chapter});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  List<Question> _questions = [];
  bool _loading = true;
  int _current = 0;
  dynamic _selected; // String (A/B/C/D) ή bool
  bool _answered = false;
  int _correct = 0;
  int _wrong = 0;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(_animCtrl);
    _load();
  }

  Future<void> _load() async {
    try {
      final qs = await ContentService.fetchQuestions(widget.chapter.file);
      setState(() {
        _questions = qs;
        _loading = false;
      });
      _animCtrl.forward();
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _select(dynamic value) {
    if (_answered) return;
    setState(() {
      _selected = value;
      _answered = true;
      if (_questions[_current].correctAnswer.isCorrect(value)) {
        _correct++;
      } else {
        _wrong++;
      }
    });
  }

  void _next() {
    if (_current < _questions.length - 1) {
      _animCtrl.reset();
      setState(() {
        _current++;
        _selected = null;
        _answered = false;
      });
      _animCtrl.forward();
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final result = QuizResult(
      chapterId: widget.chapter.id,
      totalQuestions: _questions.length,
      correctAnswers: _correct,
      wrongAnswers: _wrong,
    );
    await ProgressService.saveResult(result);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultsScreen(
            result: result,
            chapter: widget.chapter,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.dark),
        ),
      );
    }
    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: AppColors.dark,
            foregroundColor: AppColors.lightBeige,
            title: const Text('Σφάλμα')),
        body: const Center(child: Text('Δεν φορτώθηκαν ερωτήσεις.')),
      );
    }

    final q = _questions[_current];
    final progress = (_current + 1) / _questions.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Progress Header ─────────────────────────────
            Container(
              color: AppColors.dark,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close_rounded,
                            color: AppColors.lightBeige, size: 22),
                      ),
                      Text(
                        '${_current + 1} / ${_questions.length}',
                        style: const TextStyle(
                          color: AppColors.lightBeige,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.check_circle_outline,
                              color: Colors.greenAccent, size: 16),
                          const SizedBox(width: 4),
                          Text('$_correct',
                              style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(width: 12),
                          const Icon(Icons.cancel_outlined,
                              color: Colors.redAccent, size: 16),
                          const SizedBox(width: 4),
                          Text('$_wrong',
                              style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.lightBeige.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.gold),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
              ),
            ),

            // ── Question Area ────────────────────────────────
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Difficulty badge
                      Row(
                        children: [
                          _DifficultyBadge(difficulty: q.difficulty),
                          const SizedBox(width: 8),
                          Text(
                            q.source.split('—').first.trim(),
                            style: TextStyle(
                              color: AppColors.dark.withOpacity(0.5),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Question text
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.dark.withOpacity(0.15),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              offset: const Offset(0, 2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Text(
                          // Απλοποίηση LaTeX για εμφάνιση
                          _simplifyLatex(q.question),
                          style: const TextStyle(
                            color: AppColors.darkText,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Answers
                      if (q.type == 'single_choice' && q.options != null)
                        ...q.options!.map((opt) => _OptionTile(
                              option: opt,
                              selected: _selected == opt.id,
                              answered: _answered,
                              isCorrect:
                                  q.correctAnswer.value == opt.id,
                              onTap: () => _select(opt.id),
                            ))
                      else if (q.type == 'true_false')
                        Row(
                          children: [
                            Expanded(
                              child: _TFButton(
                                label: 'ΣΩΣΤΟ',
                                value: true,
                                selected: _selected == true,
                                answered: _answered,
                                isCorrect: q.correctAnswer.value == true,
                                onTap: () => _select(true),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _TFButton(
                                label: 'ΛΑΘΟΣ',
                                value: false,
                                selected: _selected == false,
                                answered: _answered,
                                isCorrect: q.correctAnswer.value == false,
                                onTap: () => _select(false),
                              ),
                            ),
                          ],
                        ),

                      // Explanation (μετά απάντηση)
                      if (_answered) ...[
                        const SizedBox(height: 20),
                        _ExplanationCard(question: q),
                      ],

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),

            // ── Next Button ──────────────────────────────────
            if (_answered)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: AppColors.dark,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.darkText,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _current < _questions.length - 1
                        ? 'ΕΠΟΜΕΝΗ ΕΡΩΤΗΣΗ'
                        : 'ΑΠΟΤΕΛΕΣΜΑΤΑ',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _simplifyLatex(String text) {
    // Αφαίρεση LaTeX delimiters για απλή εμφάνιση
    return text
        .replaceAll(r'\rightarrow', '→')
        .replaceAll(r'\rightleftharpoons', '⇌')
        .replaceAll(r'\leq', '≤')
        .replaceAll(r'\geq', '≥')
        .replaceAll(r'\Delta H', 'ΔΗ')
        .replaceAll(r'\Delta', 'Δ')
        .replaceAll(r'\times', '×')
        .replaceAll(r'\circ', '°')
        .replaceAll(r'\frac{', '')
        .replaceAll('}{', '/')
        .replaceAll('}', '')
        .replaceAll(r'\sqrt{', '√(')
        .replaceAll('\$', '')
        .replaceAll(r'\\', '\n');
  }
}

// ── Βοηθητικά Widgets ──────────────────────────────────────

class _DifficultyBadge extends StatelessWidget {
  final String difficulty;
  const _DifficultyBadge({required this.difficulty});

  Color get color {
    switch (difficulty) {
      case 'easy': return Colors.green.shade700;
      case 'medium': return Colors.orange.shade700;
      case 'hard': return Colors.red.shade700;
      default: return AppColors.dark;
    }
  }

  String get label {
    switch (difficulty) {
      case 'easy': return 'Εύκολη';
      case 'medium': return 'Μέτρια';
      case 'hard': return 'Δύσκολη';
      default: return difficulty;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final Option option;
  final bool selected;
  final bool answered;
  final bool isCorrect;
  final VoidCallback onTap;

  const _OptionTile({
    required this.option,
    required this.selected,
    required this.answered,
    required this.isCorrect,
    required this.onTap,
  });

  Color get bgColor {
    if (!answered) return AppColors.cardBg;
    if (isCorrect) return AppColors.correct.withOpacity(0.15);
    if (selected && !isCorrect) return AppColors.wrong.withOpacity(0.15);
    return AppColors.cardBg.withOpacity(0.5);
  }

  Color get borderColor {
    if (!answered) {
      return selected
          ? AppColors.dark
          : AppColors.dark.withOpacity(0.2);
    }
    if (isCorrect) return AppColors.correct;
    if (selected && !isCorrect) return AppColors.wrong;
    return AppColors.dark.withOpacity(0.1);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: answered ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: answered && isCorrect
                    ? AppColors.correct
                    : answered && selected && !isCorrect
                        ? AppColors.wrong
                        : AppColors.dark.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  option.id,
                  style: TextStyle(
                    color: answered && (isCorrect || selected)
                        ? AppColors.white
                        : AppColors.darkText,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option.text
                    .replaceAll(r'\rightarrow', '→')
                    .replaceAll(r'\rightleftharpoons', '⇌')
                    .replaceAll('\$', '')
                    .replaceAll(r'\Delta H', 'ΔΗ')
                    .replaceAll(r'\Delta', 'Δ')
                    .replaceAll(r'\times', '×'),
                style: TextStyle(
                  color: AppColors.darkText,
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (answered)
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: isCorrect ? AppColors.correct : AppColors.wrong,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _TFButton extends StatelessWidget {
  final String label;
  final bool value;
  final bool selected;
  final bool answered;
  final bool isCorrect;
  final VoidCallback onTap;

  const _TFButton({
    required this.label,
    required this.value,
    required this.selected,
    required this.answered,
    required this.isCorrect,
    required this.onTap,
  });

  Color get bgColor {
    if (!answered) return selected ? AppColors.dark : AppColors.cardBg;
    if (isCorrect) return AppColors.correct;
    if (selected && !isCorrect) return AppColors.wrong;
    return AppColors.cardBg.withOpacity(0.5);
  }

  Color get textColor {
    if (!answered) return selected ? AppColors.lightBeige : AppColors.darkText;
    if (isCorrect || (selected && !isCorrect)) return AppColors.white;
    return AppColors.darkText.withOpacity(0.4);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: answered ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.dark.withOpacity(0.2),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _ExplanationCard extends StatelessWidget {
  final Question question;
  const _ExplanationCard({required this.question});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.dark.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.dark.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_rounded,
                  color: AppColors.gold, size: 18),
              const SizedBox(width: 6),
              const Text(
                'Εξήγηση',
                style: TextStyle(
                  color: AppColors.darkText,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            question.explanation
                .replaceAll(r'\rightarrow', '→')
                .replaceAll(r'\rightleftharpoons', '⇌')
                .replaceAll('\$', '')
                .replaceAll(r'\Delta H', 'ΔΗ')
                .replaceAll(r'\Delta', 'Δ')
                .replaceAll(r'\times', '×')
                .replaceAll(r'\Rightarrow', '→'),
            style: const TextStyle(
              color: AppColors.darkText,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          if (question.commonMistake.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(color: AppColors.dark, height: 1, thickness: 0.3),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: AppColors.wrong.withOpacity(0.7), size: 15),
                const SizedBox(width: 6),
                const Text(
                  'Συνήθες λάθος',
                  style: TextStyle(
                    color: AppColors.darkText,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              question.commonMistake.replaceAll('\$', ''),
              style: TextStyle(
                color: AppColors.darkText.withOpacity(0.8),
                fontSize: 12,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
