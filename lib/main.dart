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
          seedColor: const Color(0xFFC9973A),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class AppColors {
  static const Color background  = Color(0xFFF9F3E3);
  static const Color cardBg      = Color(0xFFFFFFFF);
  static const Color dark        = Color(0xFF3D2B00);
  static const Color darkText    = Color(0xFF3D2B00);
  static const Color gold        = Color(0xFFC9973A);
  static const Color lightBeige  = Color(0xFFFFF8E7);
  static const Color white       = Color(0xFFFFFFFF);
  static const Color correct     = Color(0xFF2E7D32);
  static const Color wrong       = Color(0xFFC62828);
  static const Color border      = Color(0xFFDFC98A);
  static const Color mutedText   = Color(0xFF8B5E0A);
}
