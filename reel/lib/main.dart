// Reel 앱 진입점 — 온보딩 완료 여부에 따라 첫 화면 분기
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/constants.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool('onboarding_done') ?? false;

  runApp(ProviderScope(child: ReelApp(onboardingDone: onboardingDone)));
}

class ReelApp extends StatelessWidget {
  final bool onboardingDone;
  const ReelApp({super.key, required this.onboardingDone});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
        fontFamily: 'Pretendard',
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: onboardingDone ? const MainShell() : const _OnboardingEntry(),
    );
  }
}

class _OnboardingEntry extends StatelessWidget {
  const _OnboardingEntry();

  @override
  Widget build(BuildContext context) {
    return OnboardingScreen(
      onComplete: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('onboarding_done', true);
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainShell()),
          );
        }
      },
    );
  }
}
