import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class ContentService {
  static Future<List<Chapter>> fetchChapters() async {
    final s = await rootBundle.loadString('assets/data/index.json');
    final data = json.decode(s);
    return (data['chapters'] as List).map((c) => Chapter.fromJson(c)).toList();
  }

  static Future<List<Question>> fetchQuestions(String file) async {
    final s = await rootBundle.loadString('assets/data/$file');
    final data = json.decode(s);
    return (data['questions'] as List).map((q) => Question.fromJson(q)).toList();
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
    return QuizResult(
      chapterId: chapterId, totalQuestions: total,
      correctAnswers: data['correct'], wrongAnswers: data['wrong'],
      completedAt: DateTime.parse(data['date']),
    );
  }
}