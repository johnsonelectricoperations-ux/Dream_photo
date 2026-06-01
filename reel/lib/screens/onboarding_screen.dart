// 앱 첫 실행 화면 - 갤러리 권한 요청 및 초기 사진 스캔
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  _Step _step = _Step.welcome;
  int _scanProgress = 0;
  int _scanTotal = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: switch (_step) {
            _Step.welcome => _WelcomePage(onStart: _requestPermission),
            _Step.scanning => _ScanningPage(
                progress: _scanProgress,
                total: _scanTotal,
              ),
            _Step.done => _DonePage(onComplete: widget.onComplete),
          },
        ),
      ),
    );
  }

  Future<void> _requestPermission() async {
    // TODO: GalleryService.requestPermission() 호출
    // 권한 허용 시 스캔 시작
    setState(() => _step = _Step.scanning);
    await _startScan();
  }

  Future<void> _startScan() async {
    // TODO: GalleryService.syncGallery() 호출
    // 완료 후 이벤트 그룹화 시작
    setState(() => _step = _Step.done);
  }
}

enum _Step { welcome, scanning, done }

class _WelcomePage extends StatelessWidget {
  final VoidCallback onStart;
  const _WelcomePage({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        const Text(
          'Reel',
          style: TextStyle(
            color: Colors.white,
            fontSize: 56,
            fontWeight: FontWeight.w800,
            letterSpacing: -2,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '우리의 추억이\n저절로 정리됩니다',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 22,
            height: 1.4,
          ),
        ),
        const Spacer(flex: 2),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onStart,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              '사진 불러오기',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            '사진은 내 폰 안에서만 분석됩니다',
            style: TextStyle(color: Colors.white38, fontSize: 13),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _ScanningPage extends StatelessWidget {
  final int progress;
  final int total;
  const _ScanningPage({required this.progress, required this.total});

  @override
  Widget build(BuildContext context) {
    final percent = total > 0 ? progress / total : 0.0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('추억을 찾는 중...',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 32),
        LinearProgressIndicator(
          value: percent,
          backgroundColor: Colors.white24,
          color: AppColors.accent,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
        const SizedBox(height: 12),
        Text(
          total > 0 ? '$progress / $total장' : '불러오는 중...',
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
      ],
    );
  }
}

class _DonePage extends StatelessWidget {
  final VoidCallback onComplete;
  const _DonePage({required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle_outline, color: AppColors.accent, size: 72),
        const SizedBox(height: 24),
        const Text('추억 정리 완료!',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
        const SizedBox(height: 48),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onComplete,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('앨범 보러 가기',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}
