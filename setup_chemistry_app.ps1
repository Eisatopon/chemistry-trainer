# ============================================================
# Chemistry Trainer — Setup Script
# Τρέξε: cd C:\chemistry_trainer && .\setup_chemistry_app.ps1
# ============================================================

Write-Host "Δημιουργία αρχείων Chemistry Trainer..." -ForegroundColor Yellow

# pubspec.yaml
@'
name: chemistry_trainer
description: Χημεία Πανελλαδικών - Trainer App
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  shared_preferences: ^2.2.0

flutter:
  uses-material-design: true
'@ | Set-Content -Path "pubspec.yaml" -Encoding UTF8

Write-Host "✓ pubspec.yaml" -ForegroundColor Green

# lib/main.dart
@'
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const ChemistryTrainerApp());
}

class ChemistryTrainerApp extends StatelessWidget {
  const ChemistryTrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Χημεία Πανελλαδικών',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.gold,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class AppColors {
  static const Color background = Color(0xFFC9A84C);
  static const Color cardBg     = Color(0xFFDDBE6A);
  static const Color dark       = Color(0xFF7A5C1E);
  static const Color darkText   = Color(0xFF4A3510);
  static const Color gold       = Color(0xFFE8B84B);
  static const Color lightBeige = Color(0xFFF2DFA0);
  static const Color white      = Color(0xFFFFFFFF);
  static const Color correct    = Color(0xFF2E7D32);
  static const Color wrong      = Color(0xFFC62828);
}
'@ | Set-Content -Path "lib\main.dart" -Encoding UTF8

Write-Host "✓ lib/main.dart" -ForegroundColor Green

# lib/models.dart
@'
class Chapter {
  final String id, title, subtitle, section, file;
  final int questionCount;
  Chapter({required this.id, required this.title, required this.subtitle,
    required this.section, required this.file, required this.questionCount});
  factory Chapter.fromJson(Map<String, dynamic> j) => Chapter(
    id: j['id'], title: j['title'], subtitle: j['subtitle'],
    section: j['section'], file: j['file'], questionCount: j['question_count']);
}

class Question {
  final String id, type, difficulty, learningObjective, question, explanation, commonMistake, source;
  final int points;
  final List<String> tags;
  final List<Option>? options;
  final CorrectAnswer correctAnswer;
  Question({required this.id, required this.type, required this.difficulty,
    required this.points, required this.tags, required this.learningObjective,
    required this.question, this.options, required this.correctAnswer,
    required this.explanation, required this.commonMistake, required this.source});
  factory Question.fromJson(Map<String, dynamic> j) {
    List<Option>? opts;
    if (j['options'] != null) opts = (j['options'] as List).map((o) => Option.fromJson(o)).toList();
    return Question(
      id: j['id'], type: j['type'], difficulty: j['difficulty'], points: j['points'],
      tags: List<String>.from(j['tags'] ?? []), learningObjective: j['learning_objective'] ?? '',
      question: j['question'], options: opts,
      correctAnswer: CorrectAnswer.fromJson(j['correct_answer']),
      explanation: j['explanation'] ?? '', commonMistake: j['common_mistake'] ?? '',
      source: j['source'] ?? '');
  }
}

class Option {
  final String id, text;
  Option({required this.id, required this.text});
  factory Option.fromJson(Map<String, dynamic> j) => Option(id: j['id'], text: j['text']);
}

class CorrectAnswer {
  final String type;
  final dynamic value;
  CorrectAnswer({required this.type, required this.value});
  factory CorrectAnswer.fromJson(Map<String, dynamic> j) =>
    CorrectAnswer(type: j['type'], value: j['value']);
  bool isCorrect(dynamic userAnswer) => value.toString() == userAnswer.toString();
}

class QuizResult {
  final String chapterId;
  final int totalQuestions;
  int correctAnswers, wrongAnswers;
  DateTime completedAt;
  QuizResult({required this.chapterId, required this.totalQuestions,
    this.correctAnswers = 0, this.wrongAnswers = 0, DateTime? completedAt})
    : completedAt = completedAt ?? DateTime.now();
  double get percentage => totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;
}
'@ | Set-Content -Path "lib\models.dart" -Encoding UTF8

Write-Host "✓ lib/models.dart" -ForegroundColor Green

# lib/services.dart
@'
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class ContentService {
  static const String baseUrl = 'https://eisatopon.github.io/chemistry-trainer-content';

  static Future<List<Chapter>> fetchChapters() async {
    final r = await http.get(Uri.parse('$baseUrl/index.json'));
    if (r.statusCode == 200) {
      final data = json.decode(utf8.decode(r.bodyBytes));
      return (data['chapters'] as List).map((c) => Chapter.fromJson(c)).toList();
    }
    throw Exception('Αποτυχία φόρτωσης');
  }

  static Future<List<Question>> fetchQuestions(String file) async {
    final r = await http.get(Uri.parse('$baseUrl/$file'));
    if (r.statusCode == 200) {
      final data = json.decode(utf8.decode(r.bodyBytes));
      return (data['questions'] as List).map((q) => Question.fromJson(q)).toList();
    }
    throw Exception('Αποτυχία φόρτωσης ερωτήσεων');
  }
}

class ProgressService {
  static Future<void> saveResult(QuizResult r) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('result_${r.chapterId}', json.encode({
      'correct': r.correctAnswers, 'wrong': r.wrongAnswers,
      'total': r.totalQuestions, 'date': r.completedAt.toIso8601String(),
    }));
  }

  static Future<QuizResult?> loadResult(String chapterId, int total) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('result_$chapterId');
    if (raw == null) return null;
    final data = json.decode(raw);
    return QuizResult(chapterId: chapterId, totalQuestions: total,
      correctAnswers: data['correct'], wrongAnswers: data['wrong'],
      completedAt: DateTime.parse(data['date']));
  }
}
'@ | Set-Content -Path "lib\services.dart" -Encoding UTF8

Write-Host "✓ lib/services.dart" -ForegroundColor Green
Write-Host ""
Write-Host "Τώρα τρέχω: flutter pub get" -ForegroundColor Yellow
flutter pub get
Write-Host ""
Write-Host "Βήμα 2: Τρέξε το script για τις screens" -ForegroundColor Cyan
Write-Host "  .\setup_chemistry_screens.ps1" -ForegroundColor White
