// 메인 홈 화면 — 다크 헤더, AI 분석 배너, 이벤트 카드 목록
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event.dart';
import '../providers/events_provider.dart';
import '../utils/constants.dart';
import '../widgets/event_card.dart';
import 'event_detail_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);
    final statsAsync = ref.watch(analysisStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _DarkHeader(statsAsync: statsAsync),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            sliver: eventsAsync.when(
              loading: () => const SliverToBoxAdapter(child: _LoadingShimmer()),
              error: (_, __) => const SliverToBoxAdapter(child: _ErrorState()),
              data: (events) => events.isEmpty
                  ? const SliverToBoxAdapter(child: _EmptyState())
                  : _EventList(events: events),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 다크 헤더 ─────────────────────────────────────────────
class _DarkHeader extends ConsumerWidget {
  final AsyncValue<AnalysisStats> statsAsync;
  const _DarkHeader({required this.statsAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverToBoxAdapter(
      child: Container(
        color: AppColors.primary,
        padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('안녕하세요 👋', style: TextStyle(color: Colors.white54, fontSize: 14)),
                      SizedBox(height: 2),
                      Text('나의 추억', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                    ],
                  ),
                ),
                // 통계 칩
                statsAsync.maybeWhen(
                  data: (stats) => Row(
                    children: [
                      _StatChip(label: '${stats.total}장'),
                      const SizedBox(width: 8),
                    ],
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
            // AI 분석 배너
            statsAsync.maybeWhen(
              data: (stats) => stats.isComplete ? const SizedBox.shrink() : _AnalysisBanner(stats: stats),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  const _StatChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }
}

// ── AI 분석 진행 배너 ─────────────────────────────────────
class _AnalysisBanner extends StatelessWidget {
  final AnalysisStats stats;
  const _AnalysisBanner({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.auto_awesome, color: AppColors.accent, size: 20),
          ),
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
                    backgroundColor: Colors.white.withOpacity(0.15),
                    valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 이벤트 목록 ───────────────────────────────────────────
class _EventList extends ConsumerWidget {
  final List<Event> events;
  const _EventList({required this.events});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, i) => EventCard(
          event: events[i],
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => EventDetailScreen(event: events[i])),
          ),
        ),
        childCount: events.length,
      ),
    );
  }
}

// ── 빈 상태 ───────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          Icon(Icons.photo_album_outlined, size: 72, color: AppColors.textSecondary.withOpacity(0.4)),
          const SizedBox(height: 20),
          const Text('아직 추억이 없어요', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const Text('사진을 찍고 돌아오면\nAI가 자동으로 정리해드려요',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.6),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _LoadingShimmer extends StatelessWidget {
  const _LoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (i) => Container(
        height: AppDimens.eventCardHeight,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.15),
          borderRadius: BorderRadius.circular(AppDimens.eventCardRadius),
        ),
      )),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('불러오기 실패', style: TextStyle(color: AppColors.textSecondary)),
    );
  }
}
