// 이벤트 상세 화면 — 커버, AI 태그, 사진 그리드, 포토북 CTA
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event.dart';
import '../models/photo.dart';
import '../providers/events_provider.dart';
import '../utils/constants.dart';

class EventDetailScreen extends ConsumerWidget {
  final Event event;
  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosAsync = ref.watch(eventPhotosProvider(event.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _CoverSliver(event: event),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    photosAsync.maybeWhen(
                      data: (photos) => _buildBody(context, photos),
                      orElse: () => const Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
          // 포토북 FAB
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _PhotobookFab(event: event),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<Photo> photos) {
    final allTags = photos.expand((p) => p.labels).toSet().toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (allTags.isNotEmpty) _TagsRow(tags: allTags),
        if (allTags.isNotEmpty) const SizedBox(height: 20),
        _GridHeader(count: photos.length),
        const SizedBox(height: 10),
        _PhotoGrid(photos: photos),
      ],
    );
  }
}

// ── 커버 슬리버 ───────────────────────────────────────────
class _CoverSliver extends StatelessWidget {
  final Event event;
  const _CoverSliver({required this.event});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {},
          child: Container(
            margin: const EdgeInsets.all(8),
            width: 36, height: 36,
            decoration: BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
            child: const Icon(Icons.ios_share, color: Colors.white, size: 18),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Stack(
          fit: StackFit.expand,
          children: [
            // 커버 이미지 (없을 때 그라디언트)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
              ),
            ),
            // 오버레이
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x4D000000), Colors.transparent, Color(0xB3000000)],
                  stops: [0.0, 0.4, 1.0],
                ),
              ),
            ),
            // 이벤트 정보
            Positioned(
              bottom: 20, left: 20, right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.name,
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8, runSpacing: 6,
                    children: [
                      _MetaChip(icon: Icons.calendar_today, text: event.dateRangeLabel),
                      if (event.locationName != null)
                        _MetaChip(icon: Icons.location_on, text: event.locationName!),
                      _MetaChip(icon: Icons.photo, text: '${event.photoCount}장'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 11),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ── AI 태그 ───────────────────────────────────────────────
class _TagsRow extends StatelessWidget {
  final List<String> tags;
  const _TagsRow({required this.tags});

  static const _highlighted = {'해변', '노을', '산', '꽃', '바다'};

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: tags.take(8).map((tag) {
        final hl = _highlighted.contains(tag);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: hl ? AppColors.accent.withOpacity(0.1) : const Color(0xFFF0F0F5),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            tag,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: hl ? AppColors.accent : AppColors.textPrimary,
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── 사진 그리드 헤더 ─────────────────────────────────────
class _GridHeader extends StatelessWidget {
  final int count;
  const _GridHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('사진 $count장', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const Text('선택하기', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.accent)),
      ],
    );
  }
}

// ── 사진 그리드 ───────────────────────────────────────────
class _PhotoGrid extends StatelessWidget {
  final List<Photo> photos;
  const _PhotoGrid({required this.photos});

  static const _gradients = [
    [Color(0xFF667eea), Color(0xFF764ba2)],
    [Color(0xFFf093fb), Color(0xFFf5576c)],
    [Color(0xFF4facfe), Color(0xFF00f2fe)],
    [Color(0xFF43e97b), Color(0xFF38f9d7)],
    [Color(0xFFfa709a), Color(0xFFfee140)],
    [Color(0xFFa18cd1), Color(0xFFfbc2eb)],
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 3,
        crossAxisSpacing: 3,
      ),
      itemCount: photos.length,
      itemBuilder: (_, i) => _PhotoCell(photo: photos[i], fallbackIndex: i),
    );
  }
}

class _PhotoCell extends StatelessWidget {
  final Photo photo;
  final int fallbackIndex;
  const _PhotoCell({required this.photo, required this.fallbackIndex});

  @override
  Widget build(BuildContext context) {
    final file = File(photo.filePath);
    return ClipRRect(
      child: file.existsSync()
          ? Image.file(file, fit: BoxFit.cover)
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _PhotoGrid._gradients[fallbackIndex % _PhotoGrid._gradients.length],
                ),
              ),
            ),
    );
  }
}

// ── 포토북 FAB ────────────────────────────────────────────
class _PhotobookFab extends StatelessWidget {
  final Event event;
  const _PhotobookFab({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        border: const Border(top: BorderSide(color: Color(0x0F000000))),
      ),
      child: GestureDetector(
        onTap: () {
          // TODO: 포토북 주문 화면으로 이동
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.menu_book_rounded, color: AppColors.accent, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('포토북 만들기', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                    SizedBox(height: 2),
                    Text('스냅스 연동 · 3일 배송', style: TextStyle(fontSize: 12, color: Colors.white38)),
                  ],
                ),
              ),
              Container(
                width: 32, height: 32,
                decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
