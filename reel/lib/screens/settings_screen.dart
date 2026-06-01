// 설정 화면 — AI 분석 토글, 알림, 저장소, 계정 관리
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/events_provider.dart';
import '../utils/constants.dart';

// 설정값 provider
final _wifiOnlyProvider = StateProvider<bool>((_) => true);
final _autoTagProvider = StateProvider<bool>((_) => true);
final _autoGroupProvider = StateProvider<bool>((_) => true);
final _memoryNotifProvider = StateProvider<bool>((_) => true);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(analysisStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.primary,
              padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 24),
              child: const Text('설정',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 프로필 카드
                _ProfileCard(),
                const SizedBox(height: 24),
                // AI 분석 현황
                statsAsync.maybeWhen(
                  data: (stats) => stats.isComplete ? const SizedBox.shrink() : _AnalysisCard(stats: stats),
                  orElse: () => const SizedBox.shrink(),
                ),
                if (statsAsync.valueOrNull?.isComplete == false) const SizedBox(height: 24),
                // AI 분석 설정
                _Section(
                  title: 'AI 분석',
                  children: [
                    _ToggleRow(
                      icon: Icons.label_rounded, iconColor: const Color(0xFF764ba2),
                      title: '자동 태그 분석',
                      subtitle: '음식, 장소, 사람 등 자동 태그',
                      provider: _autoTagProvider,
                    ),
                    _ToggleRow(
                      icon: Icons.auto_awesome_mosaic, iconColor: const Color(0xFF4facfe),
                      title: '이벤트 자동 그룹화',
                      subtitle: '시간·장소 기반 자동 앨범 생성',
                      provider: _autoGroupProvider,
                    ),
                    _ToggleRow(
                      icon: Icons.wifi_rounded, iconColor: AppColors.accent,
                      title: 'Wi-Fi에서만 분석',
                      subtitle: '모바일 데이터 절약',
                      provider: _wifiOnlyProvider,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // 알림
                _Section(
                  title: '알림',
                  children: [
                    _ToggleRow(
                      icon: Icons.notifications_rounded, iconColor: const Color(0xFF4facfe),
                      title: '추억 알림',
                      subtitle: '1년 전 오늘의 사진 알림',
                      provider: _memoryNotifProvider,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // 기타
                _Section(
                  title: '기타',
                  children: [
                    _ArrowRow(icon: Icons.info_outline_rounded, title: '버전 정보', trailing: 'v1.0.0'),
                    _ArrowRow(icon: Icons.privacy_tip_outlined, title: '개인정보 처리방침'),
                    _ArrowRow(
                      icon: Icons.logout_rounded, title: '데이터 초기화',
                      titleColor: AppColors.accent,
                      onTap: () => _showResetDialog(context),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('데이터 초기화'),
        content: const Text('모든 분석 데이터와 이벤트가 삭제됩니다. 계속하시겠어요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('초기화', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}

// ── 프로필 카드 ───────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20)],
      ),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.accent, Color(0xFFff6b8a)]),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('내 Reel', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
                SizedBox(height: 2),
                Text('무료 플랜', style: TextStyle(fontSize: 13, color: Colors.white54)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: AppColors.accent.withOpacity(0.3)),
            ),
            child: const Text('무료', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}

// ── AI 분석 현황 카드 ─────────────────────────────────────
class _AnalysisCard extends StatelessWidget {
  final AnalysisStats stats;
  const _AnalysisCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF16213E)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.accent, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI 분석 중 · ${stats.analyzed} / ${stats.total}장',
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: stats.progress,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 4),
                Text('완료 ${(stats.progress * 100).round()}%',
                    style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 섹션 그룹 ─────────────────────────────────────────────
class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title.toUpperCase(),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary, letterSpacing: 0.1)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  const Divider(height: 1, indent: 56, color: Color(0x0A000000)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── 토글 설정 행 ──────────────────────────────────────────
class _ToggleRow extends ConsumerWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final StateProvider<bool> provider;

  const _ToggleRow({
    required this.icon, required this.iconColor,
    required this.title, this.subtitle, required this.provider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(provider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (v) => ref.read(provider.notifier).state = v,
            activeColor: AppColors.accent,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

// ── 화살표 설정 행 ────────────────────────────────────────
class _ArrowRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  final Color? titleColor;
  final VoidCallback? onTap;

  const _ArrowRow({
    required this.icon, required this.title,
    this.trailing, this.titleColor, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: const Color(0xFFF0F0F5), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: titleColor ?? AppColors.textSecondary, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: titleColor ?? AppColors.textPrimary)),
            ),
            if (trailing != null)
              Text(trailing!, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFC0C0C0), size: 20),
          ],
        ),
      ),
    );
  }
}
