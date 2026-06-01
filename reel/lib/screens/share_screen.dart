// 공유 화면 — 이벤트 앨범 링크 생성 및 공유 (MVP: 플레이스홀더)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

class ShareScreen extends StatelessWidget {
  const ShareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // 헤더
          Container(
            width: double.infinity,
            color: AppColors.primary,
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 24),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('앨범 공유', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                SizedBox(height: 4),
                Text('소중한 추억을 함께 나눠보세요', style: TextStyle(color: Colors.white54, fontSize: 14)),
              ],
            ),
          ),
          // 콘텐츠
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 준비 중 배너
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16)],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 64, height: 64,
                          decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.share_rounded, color: AppColors.accent, size: 30),
                        ),
                        const SizedBox(height: 16),
                        const Text('앨범 공유 기능', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        const Text('가족·친구와 추억을 공유하는 기능을\n곧 만나보실 수 있어요.',
                            style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 24),
                        // 미리보기 링크 카드
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F0F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.link, color: AppColors.textSecondary, size: 18),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text('reel.app/s/my-memories',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(const ClipboardData(text: 'reel.app/s/my-memories'));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('링크가 복사됐어요'), duration: Duration(seconds: 2)),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text('복사', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 공유 방법 아이콘
                  _SectionTitle(text: '공유 방법 (출시 예정)'),
                  const SizedBox(height: 16),
                  const _ShareMethodGrid(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary));
  }
}

class _ShareMethodGrid extends StatelessWidget {
  const _ShareMethodGrid();

  static const _methods = [
    (icon: '💬', name: '카카오톡', color: Color(0xFFFEE500)),
    (icon: '📸', name: '인스타그램', color: Color(0xFFE1306C)),
    (icon: '✉️', name: '문자', color: Color(0xFF34C759)),
    (icon: '···', name: '더 보기', color: Color(0xFFF0F0F5)),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: _methods.map((m) => Column(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(color: m.color, borderRadius: BorderRadius.circular(18)),
            child: Center(child: Text(m.icon, style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(height: 8),
          Text(m.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      )).toList(),
    );
  }
}
