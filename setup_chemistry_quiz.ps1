# ============================================================
# Chemistry Trainer — Quiz Screen (Μέρος 3)
# ============================================================

Write-Host "Δημιουργία quiz_screen.dart..." -ForegroundColor Yellow

@'
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

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  List<Question> _questions = [];
  bool _loading = true;
  int _current = 0;
  dynamic _selected;
  bool _answered = false;
  int _correct = 0, _wrong = 0;
  late AnimationController _ac;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fade = Tween<double>(begin: 0, end: 1).animate(_ac);
    _load();
  }

  Future<void> _load() async {
    try {
      final qs = await ContentService.fetchQuestions(widget.chapter.file);
      setState(() { _questions = qs; _loading = false; });
      _ac.forward();
    } catch (e) { setState(() => _loading = false); }
  }

  void _select(dynamic value) {
    if (_answered) return;
    setState(() {
      _selected = value;
      _answered = true;
      if (_questions[_current].correctAnswer.isCorrect(value)) _correct++; else _wrong++;
    });
  }

  void _next() {
    if (_current < _questions.length - 1) {
      _ac.reset();
      setState(() { _current++; _selected = null; _answered = false; });
      _ac.forward();
    } else { _finish(); }
  }

  Future<void> _finish() async {
    final result = QuizResult(chapterId: widget.chapter.id,
      totalQuestions: _questions.length, correctAnswers: _correct, wrongAnswers: _wrong);
    await ProgressService.saveResult(result);
    if (mounted) Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (_) => ResultsScreen(result: result, chapter: widget.chapter)));
  }

  String _clean(String t) => t
    .replaceAll(r'\rightarrow', '→').replaceAll(r'\rightleftharpoons', '⇌')
    .replaceAll(r'\Delta H', 'ΔΗ').replaceAll(r'\Delta', 'Δ')
    .replaceAll(r'\times', '×').replaceAll(r'\circ', '°')
    .replaceAll(r'\frac{', '(').replaceAll('}{', '/')
    .replaceAll(r'\sqrt{', '√(').replaceAll('\$', '').replaceAll('\\\\', '\n')
    .replaceAll(r'\geq', '≥').replaceAll(r'\leq', '≤')
    .replaceAll(RegExp(r'\\[a-zA-Z]+\{'), '').replaceAll('}', '');

  @override
  void dispose() { _ac.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (_loading) return Scaffold(backgroundColor: AppColors.background,
      body: const Center(child: CircularProgressIndicator(color: AppColors.dark)));
    if (_questions.isEmpty) return Scaffold(backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.dark, foregroundColor: AppColors.lightBeige),
      body: const Center(child: Text('Σφάλμα φόρτωσης.')));

    final q = _questions[_current];
    final progress = (_current + 1) / _questions.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: Column(children: [
        Container(color: AppColors.dark,
          padding: const EdgeInsets.fromLTRB(16,12,16,0),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              GestureDetector(onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close_rounded, color: AppColors.lightBeige, size: 22)),
              Text('${_current+1} / ${_questions.length}',
                style: const TextStyle(color: AppColors.lightBeige, fontSize: 14, fontWeight: FontWeight.w600)),
              Row(children: [
                const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 16),
                const SizedBox(width: 4),
                Text('$_correct', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.w700)),
                const SizedBox(width: 12),
                const Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 16),
                const SizedBox(width: 4),
                Text('$_wrong', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700)),
              ]),
            ]),
            const SizedBox(height: 8),
            ClipRRect(borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: progress,
                backgroundColor: AppColors.lightBeige.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                minHeight: 6)),
            const SizedBox(height: 2),
          ])),
        Expanded(child: FadeTransition(opacity: _fade,
          child: SingleChildScrollView(padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                _DiffBadge(d: q.difficulty),
                const SizedBox(width: 8),
                Flexible(child: Text(q.source.split('—').first.trim(),
                  style: TextStyle(color: AppColors.dark.withOpacity(0.5), fontSize: 11))),
              ]),
              const SizedBox(height: 16),
              Container(width: double.infinity, padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.dark.withOpacity(0.15)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08),
                    offset: const Offset(0,2), blurRadius: 8)]),
                child: Text(_clean(q.question), style: const TextStyle(
                  color: AppColors.darkText, fontSize: 16, fontWeight: FontWeight.w600, height: 1.5))),
              const SizedBox(height: 20),
              if (q.type == 'single_choice' && q.options != null)
                ...q.options!.map((o) => _OptionTile(
                  option: o, selected: _selected == o.id, answered: _answered,
                  isCorrect: q.correctAnswer.value == o.id,
                  onTap: () => _select(o.id), clean: _clean))
              else if (q.type == 'true_false')
                Row(children: [
                  Expanded(child: _TFBtn(label: 'ΣΩΣΤΟ', value: true,
                    selected: _selected == true, answered: _answered,
                    isCorrect: q.correctAnswer.value == true, onTap: () => _select(true))),
                  const SizedBox(width: 12),
                  Expanded(child: _TFBtn(label: 'ΛΑΘΟΣ', value: false,
                    selected: _selected == false, answered: _answered,
                    isCorrect: q.correctAnswer.value == false, onTap: () => _select(false))),
                ]),
              if (_answered) ...[
                const SizedBox(height: 20),
                _ExplCard(q: q, clean: _clean),
              ],
              const SizedBox(height: 80),
            ])))),
        if (_answered)
          Container(width: double.infinity, padding: const EdgeInsets.all(16),
            color: AppColors.dark,
            child: ElevatedButton(onPressed: _next,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold,
                foregroundColor: AppColors.darkText,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0),
              child: Text(_current < _questions.length-1 ? 'ΕΠΟΜΕΝΗ ΕΡΩΤΗΣΗ' : 'ΑΠΟΤΕΛΕΣΜΑΤΑ',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 1)))),
      ])),
    );
  }
}

class _DiffBadge extends StatelessWidget {
  final String d;
  const _DiffBadge({required this.d});
  Color get c => d=='easy' ? Colors.green.shade700 : d=='medium' ? Colors.orange.shade700 : Colors.red.shade700;
  String get l => d=='easy' ? 'Εύκολη' : d=='medium' ? 'Μέτρια' : 'Δύσκολη';
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    decoration: BoxDecoration(color: c.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20), border: Border.all(color: c.withOpacity(0.4))),
    child: Text(l, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w700)));
}

class _OptionTile extends StatelessWidget {
  final Option option;
  final bool selected, answered, isCorrect;
  final VoidCallback onTap;
  final String Function(String) clean;
  const _OptionTile({required this.option, required this.selected, required this.answered,
    required this.isCorrect, required this.onTap, required this.clean});

  Color get bg {
    if (!answered) return AppColors.cardBg;
    if (isCorrect) return AppColors.correct.withOpacity(0.15);
    if (selected) return AppColors.wrong.withOpacity(0.15);
    return AppColors.cardBg.withOpacity(0.5);
  }
  Color get border {
    if (!answered) return selected ? AppColors.dark : AppColors.dark.withOpacity(0.2);
    if (isCorrect) return AppColors.correct;
    if (selected) return AppColors.wrong;
    return AppColors.dark.withOpacity(0.1);
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: answered ? null : onTap,
    child: AnimatedContainer(duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: 1.5)),
      child: Row(children: [
        Container(width: 32, height: 32,
          decoration: BoxDecoration(
            color: answered && isCorrect ? AppColors.correct
              : answered && selected && !isCorrect ? AppColors.wrong
              : AppColors.dark.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6)),
          child: Center(child: Text(option.id,
            style: TextStyle(
              color: answered && (isCorrect || selected) ? AppColors.white : AppColors.darkText,
              fontWeight: FontWeight.w800, fontSize: 14)))),
        const SizedBox(width: 12),
        Expanded(child: Text(clean(option.text),
          style: TextStyle(color: AppColors.darkText, fontSize: 14,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400))),
        if (answered) Icon(isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
          color: isCorrect ? AppColors.correct : AppColors.wrong, size: 20),
      ])));
}

class _TFBtn extends StatelessWidget {
  final String label;
  final bool value, selected, answered, isCorrect;
  final VoidCallback onTap;
  const _TFBtn({required this.label, required this.value, required this.selected,
    required this.answered, required this.isCorrect, required this.onTap});

  Color get bg {
    if (!answered) return selected ? AppColors.dark : AppColors.cardBg;
    if (isCorrect) return AppColors.correct;
    if (selected) return AppColors.wrong;
    return AppColors.cardBg.withOpacity(0.5);
  }
  Color get tc {
    if (!answered) return selected ? AppColors.lightBeige : AppColors.darkText;
    if (isCorrect || selected) return AppColors.white;
    return AppColors.darkText.withOpacity(0.4);
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: answered ? null : onTap,
    child: AnimatedContainer(duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dark.withOpacity(0.2))),
      child: Center(child: Text(label,
        style: TextStyle(color: tc, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1)))));
}

class _ExplCard extends StatelessWidget {
  final Question q;
  final String Function(String) clean;
  const _ExplCard({required this.q, required this.clean});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.dark.withOpacity(0.08),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.dark.withOpacity(0.2))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.lightbulb_rounded, color: AppColors.gold, size: 18),
        const SizedBox(width: 6),
        const Text('Εξήγηση', style: TextStyle(color: AppColors.darkText,
          fontWeight: FontWeight.w800, fontSize: 13)),
      ]),
      const SizedBox(height: 8),
      Text(clean(q.explanation), style: const TextStyle(color: AppColors.darkText, fontSize: 13, height: 1.5)),
      if (q.commonMistake.isNotEmpty) ...[
        const SizedBox(height: 10),
        const Divider(color: AppColors.dark, height: 1, thickness: 0.3),
        const SizedBox(height: 8),
        Row(children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.wrong.withOpacity(0.7), size: 15),
          const SizedBox(width: 6),
          const Text('Συνήθες λάθος', style: TextStyle(color: AppColors.darkText,
            fontWeight: FontWeight.w700, fontSize: 12)),
        ]),
        const SizedBox(height: 4),
        Text(clean(q.commonMistake), style: TextStyle(color: AppColors.darkText.withOpacity(0.8),
          fontSize: 12, fontStyle: FontStyle.italic, height: 1.4)),
      ],
    ]));
}
'@ | Set-Content -Path "lib\screens\quiz_screen.dart" -Encoding UTF8

Write-Host "✓ quiz_screen.dart" -ForegroundColor Green
Write-Host ""
Write-Host "Όλα έτοιμα! Τώρα τρέξε:" -ForegroundColor Green
Write-Host "  flutter run" -ForegroundColor White
