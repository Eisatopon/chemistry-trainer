class Chapter {
  final String id;
  final String title;
  final String file;
  final String subtitle;
  final String section;
  final int questionCount;

  Chapter({
    required this.id,
    required this.title,
    required this.file,
    required this.subtitle,
    required this.section,
    required this.questionCount,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) => Chapter(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    file: json['file'] ?? '',
    subtitle: json['subtitle'] ?? '',
    section: json['section'] ?? '',
    questionCount: json['question_count'] ?? json['questionCount'] ?? 0,
  );
}

class Option {
  final String id;
  final String text;

  Option({required this.id, required this.text});

  factory Option.fromJson(Map<String, dynamic> json) => Option(
    id: json['id'] ?? '',
    text: json['text'] ?? '',
  );
}

class CorrectAnswer {
  final dynamic value;

  CorrectAnswer(this.value);

  bool isCorrect(dynamic answer) => value == answer;

  factory CorrectAnswer.fromJson(dynamic json) => CorrectAnswer(json);
}

class Question {
  final String question;
  final List<Option>? options;
  final CorrectAnswer correctAnswer;
  final String explanation;
  final String commonMistake;
  final String type;
  final String difficulty;
  final String source;

  Question({
    required this.question,
    this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.commonMistake,
    required this.type,
    required this.difficulty,
    required this.source,
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
    question: json['question'] ?? '',
    options: json['options'] != null
        ? (json['options'] as List).map((o) => Option.fromJson(o)).toList()
        : null,
    correctAnswer: CorrectAnswer.fromJson(json['correctAnswer']),
    explanation: json['explanation'] ?? '',
    commonMistake: json['commonMistake'] ?? '',
    type: json['type'] ?? 'single_choice',
    difficulty: json['difficulty'] ?? 'medium',
    source: json['source'] ?? '',
  );
}

class QuizResult {
  final String chapterId;
  final int correctAnswers;
  final int wrongAnswers;
  final int totalQuestions;
  final DateTime completedAt;

  QuizResult({
    required this.chapterId,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.totalQuestions,
    DateTime? completedAt,
  }) : completedAt = completedAt ?? DateTime.now();

  double get percentage => totalQuestions == 0 ? 0 : (correctAnswers / totalQuestions) * 100;
}
