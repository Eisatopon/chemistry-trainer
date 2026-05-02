# ============================================================
# Chemistry Trainer — Screens Setup Script (Μέρος 2)
# Τρέξε: cd C:\chemistry_trainer && .\setup_chemistry_screens.ps1
# ============================================================

Write-Host "Δημιουργία screens..." -ForegroundColor Yellow

# lib/screens/home_screen.dart
@'
import 'package:flutter/material.dart';
import '../main.dart';
import 'chapter_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _slide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFFD4B060), Color(0xFFC9A84C), Color(0xFFB8903A)],
          ),
        ),
        child: SafeArea(child: Column(children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            color: AppColors.dark,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('ΙΤΥΕ · ΔΙΟΦΑΝΤΟΣ',
                style: TextStyle(color: AppColors.lightBeige.withOpacity(0.7),
                  fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text('Γ΄ ΓΕΝΙΚΟΥ ΛΥΚΕΙΟΥ',
                style: TextStyle(color: AppColors.lightBeige.withOpacity(0.9),
                  fontSize: 12, letterSpacing: 1.5)),
            ]),
          ),
          Expanded(child: FadeTransition(opacity: _fade, child: SlideTransition(position: _slide,
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Padding(padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Wrap(spacing: 16, runSpacing: 8, alignment: WrapAlignment.center,
                  children: ['H₂SO₄','HNO₃','KMnO₄','C₆H₁₂O₆','CH₃COOH','NH₃']
                    .map((f) => Text(f, style: TextStyle(
                      color: AppColors.dark.withOpacity(0.25), fontSize: 16,
                      fontStyle: FontStyle.italic, fontWeight: FontWeight.w600))).toList())),
              const SizedBox(height: 32),
              Text('Χημεία', style: TextStyle(
                color: AppColors.dark, fontSize: 56, fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic, letterSpacing: -1,
                shadows: [Shadow(color: Colors.black.withOpacity(0.2),
                  offset: const Offset(2,3), blurRadius: 6)])),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(4)),
                child: const Text('Ομάδας Προσανατολισμού Θετικών Σπουδών',
                  style: TextStyle(color: AppColors.lightBeige, fontSize: 12, letterSpacing: 0.5))),
              const SizedBox(height: 48),
              GestureDetector(
                onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ChapterListScreen())),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  decoration: BoxDecoration(color: AppColors.dark,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0,4), blurRadius: 12)]),
                  child: const Text('ΕΝΑΡΞΗ ΕΞΕΤΑΣΗΣ',
                    style: TextStyle(color: AppColors.lightBeige, fontSize: 16,
                      fontWeight: FontWeight.w700, letterSpacing: 2)))),
              const SizedBox(height: 24),
              Text('174 ερωτήσεις · 13 κεφάλαια',
                style: TextStyle(color: AppColors.dark.withOpacity(0.6), fontSize: 13)),
            ])))),
          Container(width: double.infinity, padding: const EdgeInsets.all(16),
            color: AppColors.dark,
            child: const Center(child: Text('eisatopon.gr',
              style: TextStyle(color: AppColors.lightBeige, fontSize: 12, letterSpacing: 1)))),
        ])),
      ),
    );
  }
}
'@ | Set-Content -Path "lib\screens\home_screen.dart" -Encoding UTF8

Write-Host "✓ home_screen.dart" -ForegroundColor Green

# lib/screens/chapter_list_screen.dart
@'
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
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final c = await ContentService.fetchChapters();
      setState(() { _chapters = c; _loading = false; });
    } catch (e) { setState(() { _error = e.toString(); _loading = false; }); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.dark, foregroundColor: AppColors.lightBeige,
        title: const Text('Επιλογή Κεφαλαίου',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5)),
        elevation: 0),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppColors.dark))
        : _error != null
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.dark),
              const SizedBox(height: 16),
              const Text('Δεν ήταν δυνατή η σύνδεση.',
                style: TextStyle(color: AppColors.darkText, fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _load,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.dark, foregroundColor: AppColors.lightBeige),
                child: const Text('Επανάληψη'))]))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _chapters.length,
              itemBuilder: (ctx, i) => _ChapterCard(chapter: _chapters[i])),
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
  void initState() { super.initState(); _loadResult(); }

  Future<void> _loadResult() async {
    final r = await ProgressService.loadResult(widget.chapter.id, widget.chapter.questionCount);
    if (mounted) setState(() => _result = r);
  }

  Color get _pc {
    if (_result == null) return Colors.transparent;
    final p = _result!.percentage;
    if (p >= 80) return AppColors.correct;
    if (p >= 50) return Colors.orange.shade700;
    return AppColors.wrong;
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.chapter;
    return GestureDetector(
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen(chapter: c)));
        _loadResult();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.dark.withOpacity(0.2)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1),
            offset: const Offset(0,2), blurRadius: 6)]),
        child: Row(children: [
          Container(width: 6, height: 80,
            decoration: const BoxDecoration(color: AppColors.dark,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10)))),
          const SizedBox(width: 14),
          Expanded(child: Padding(padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.dark.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4)),
                  child: Text(c.section, style: const TextStyle(color: AppColors.darkText,
                    fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5))),
                const SizedBox(width: 8),
                Text('${c.questionCount} ερωτήσεις',
                  style: TextStyle(color: AppColors.dark.withOpacity(0.6), fontSize: 11)),
              ]),
              const SizedBox(height: 6),
              Text(c.subtitle, style: const TextStyle(color: AppColors.darkText,
                fontSize: 15, fontWeight: FontWeight.w700)),
            ]))),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _result != null
              ? Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('${_result!.percentage.round()}%',
                    style: TextStyle(color: _pc, fontSize: 18, fontWeight: FontWeight.w800)),
                  Text('${_result!.correctAnswers}/${_result!.totalQuestions}',
                    style: TextStyle(color: AppColors.dark.withOpacity(0.5), fontSize: 11)),
                ])
              : Icon(Icons.chevron_right_rounded,
                  color: AppColors.dark.withOpacity(0.4), size: 28)),
        ]),
      ),
    );
  }
}
'@ | Set-Content -Path "lib\screens\chapter_list_screen.dart" -Encoding UTF8

Write-Host "✓ chapter_list_screen.dart" -ForegroundColor Green

# lib/screens/results_screen.dart
@'
import 'package:flutter/material.dart';
import '../main.dart';
import '../models.dart';

class ResultsScreen extends StatelessWidget {
  final QuizResult result;
  final Chapter chapter;
  const ResultsScreen({super.key, required this.result, required this.chapter});

  Color get _sc {
    final p = result.percentage;
    if (p >= 80) return AppColors.correct;
    if (p >= 50) return Colors.orange.shade700;
    return AppColors.wrong;
  }

  String get _msg {
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
      body: SafeArea(child: Column(children: [
        Container(color: AppColors.dark, padding: const EdgeInsets.all(20),
          child: Row(children: [
            const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 28),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Αποτελέσματα', style: TextStyle(color: AppColors.lightBeige,
                fontSize: 18, fontWeight: FontWeight.w800)),
              Text(chapter.subtitle, style: TextStyle(
                color: AppColors.lightBeige.withOpacity(0.7), fontSize: 12)),
            ])
          ])),
        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(24),
          child: Column(children: [
            const SizedBox(height: 20),
            Container(width: 150, height: 150,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.cardBg,
                border: Border.all(color: _sc, width: 6),
                boxShadow: [BoxShadow(color: _sc.withOpacity(0.3), blurRadius: 20, spreadRadius: 4)]),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('${result.percentage.round()}%',
                  style: TextStyle(color: _sc, fontSize: 36, fontWeight: FontWeight.w900)),
                Text('${result.correctAnswers}/${result.totalQuestions}',
                  style: TextStyle(color: AppColors.darkText.withOpacity(0.6), fontSize: 14)),
              ])),
            const SizedBox(height: 24),
            Text(_msg, textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.darkText, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 32),
            Row(children: [
              Expanded(child: _Stat(label: 'Σωστές', value: '${result.correctAnswers}',
                color: AppColors.correct, icon: Icons.check_circle_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _Stat(label: 'Λάθος', value: '${result.wrongAnswers}',
                color: AppColors.wrong, icon: Icons.cancel_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _Stat(label: 'Σύνολο', value: '${result.totalQuestions}',
                color: AppColors.dark, icon: Icons.quiz_rounded)),
            ]),
            const SizedBox(height: 40),
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: () { Navigator.pop(context); Navigator.pop(context); },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.dark,
                foregroundColor: AppColors.lightBeige,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text('ΕΠΙΛΟΓΗ ΚΕΦΑΛΑΙΟΥ',
                style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1)))),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.dark,
                side: const BorderSide(color: AppColors.dark),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text('ΕΠΑΝΑΛΗΨΗ',
                style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1)))),
          ]))),
      ])),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _Stat({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3))),
      child: Column(children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900)),
        Text(label, style: TextStyle(color: AppColors.darkText.withOpacity(0.6), fontSize: 11)),
      ]));
  }
}
'@ | Set-Content -Path "lib\screens\results_screen.dart" -Encoding UTF8

Write-Host "✓ results_screen.dart" -ForegroundColor Green
Write-Host ""
Write-Host "Βήμα 3: Τρέξε το script για το quiz screen" -ForegroundColor Cyan
Write-Host "  .\setup_chemistry_quiz.ps1" -ForegroundColor White
