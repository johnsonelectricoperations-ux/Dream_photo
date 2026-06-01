// 앱 첫 실행 화면 — 갤러리 권한 요청 및 초기 사진 스캔
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/scan_provider.dart';
import '../utils/constants.dart';

class OnboardingScreen extends ConsumerWidget {
  final VoidCallback onComplete;
  const OnboardingScreen({super.key, required this.onComplete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scan = ref.watch(scanProvider);

    if (scan.status == ScanStatus.done) {
      WidgetsBinding.instance.addPostFrameCallback((_) => onComplete());
    }

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 24, 32, 48),
          child: switch (scan.status) {
            ScanStatus.idle || ScanStatus.requestingPermission => _WelcomePage(
                loading: scan.status == ScanStatus.requestingPermission,
                onStart: () => ref.read(scanProvider.notifier).requestAndScan(),
              ),
            ScanStatus.error => _ErrorPage(
                message: scan.errorMessage ?? '오류가 발생했습니다.',
                onRetry: () => ref.read(scanProvider.notifier).requestAndScan(),
              ),
            _ => _ScanningPage(scan: scan),
          },
        ),
      ),
    );
  }
}

// ── 웰컴 페이지 ──────────────────────────────────────────
class _WelcomePage extends StatelessWidget {
  final bool loading;
  final VoidCallback onStart;
  const _WelcomePage({required this.loading, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        // 배지
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.15),
            border: Border.all(color: AppColors.accent.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _AccentDot(),
              SizedBox(width: 6),
              Text(
                'AI 추억 앨범',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accent),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Reel',
          style: TextStyle(color: Colors.white, fontSize: 72, fontWeight: FontWeight.w800, letterSpacing: -3),
        ),
        const SizedBox(height: 16),
        const Text(
          '우리의 추억이\n저절로 정리됩니다',
          style: TextStyle(color: Colors.white60, fontSize: 20, height: 1.5),
        ),
        const Spacer(flex: 2),
        // 미리보기 카드 3장
        _PreviewCards(),
        const SizedBox(height: 40),
        // CTA 버튼
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: loading ? null : onStart,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.accent.withOpacity(0.6),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('사진 불러오기', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                      SizedBox(width: 8),
                      Text('→', style: TextStyle(fontSize: 20)),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🔒', style: TextStyle(fontSize: 13)),
              SizedBox(width: 6),
              Text('사진은 내 폰 안에서만 분석됩니다', style: TextStyle(color: Colors.white38, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }
}

// ── 미리보기 카드 ─────────────────────────────────────────
class _PreviewCards extends StatelessWidget {
  final _cards = const [
    (label: '강릉 여행', count: '24장', colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
    (label: '생일 파티', count: '18장', colors: [Color(0xFFf093fb), Color(0xFFf5576c)]),
    (label: '가족 모임', count: '31장', colors: [Color(0xFF4facfe), Color(0xFF00f2fe)]),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Row(
        children: [
          for (int i = 0; i < _cards.length; i++)
            Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < 2 ? 12 : 0, top: i == 1 ? 0 : 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _cards[i].colors,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    Positioned(
                      top: 10, right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(_cards[i].count, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    Positioned(
                      bottom: 10, left: 10,
                      child: Text(_cards[i].label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── 스캔 진행 페이지 ──────────────────────────────────────
class _ScanningPage extends StatelessWidget {
  final ScanState scan;
  const _ScanningPage({required this.scan});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 32),
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.auto_awesome, color: AppColors.accent, size: 36),
        ),
        const SizedBox(height: 32),
        Text(
          scan.message,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: scan.total > 0 ? scan.progress : null,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 12),
        if (scan.total > 0)
          Text(
            '${scan.scanned} / ${scan.total}장',
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
      ],
    );
  }
}

// ── 오류 페이지 ────────────────────────────────────────────
class _ErrorPage extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorPage({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, color: AppColors.accent, size: 64),
        const SizedBox(height: 24),
        Text(message, style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.6), textAlign: TextAlign.center),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('다시 시도', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}

class _AccentDot extends StatelessWidget {
  const _AccentDot();

  @override
  Widget build(BuildContext context) {
    return Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle));
  }
}
