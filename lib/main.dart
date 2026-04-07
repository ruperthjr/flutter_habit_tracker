import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/habits/presentation/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const ProviderScope(child: HabitTrackerApp()));
}

class HabitTrackerApp extends StatelessWidget {
  const HabitTrackerApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Habit Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: const MainScreen(),
      );
}