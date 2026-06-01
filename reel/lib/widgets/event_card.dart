// 홈 화면에서 이벤트(추억)를 보여주는 카드 위젯
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/event.dart';
import '../utils/constants.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;

  const EventCard({super.key, required this.event, this.onTap});

  // 커버 이미지 없을 때 이벤트 이름 기반 그라디언트 선택
  static const _gradients = [
    [Color(0xFF667eea), Color(0xFF764ba2)],
    [Color(0xFFf093fb), Color(0xFFf5576c)],
    [Color(0xFF4facfe), Color(0xFF00f2fe)],
    [Color(0xFF43e97b), Color(0xFF38f9d7)],
    [Color(0xFFfa709a), Color(0xFFfee140)],
  ];

  List<Color> _gradientColors() {
    final idx = event.name.codeUnits.fold(0, (a, b) => a + b) % _gradients.length;
    return _gradients[idx];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppDimens.eventCardHeight,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.eventCardRadius),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 6)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.eventCardRadius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _CoverImage(photoId: event.coverPhotoId, gradientColors: _gradientColors()),
              _Overlay(),
              _EventInfo(event: event),
              _PhotobookButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  final String photoId;
  final List<Color> gradientColors;
  const _CoverImage({required this.photoId, required this.gradientColors});

  @override
  Widget build(BuildContext context) {
    // photoId가 파일 경로를 겸할 경우 이미지 로드 시도
    if (photoId.startsWith('/')) {
      final file = File(photoId);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    }
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
    );
  }
}

class _Overlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
          stops: const [0.4, 1.0],
        ),
      ),
    );
  }
}

class _EventInfo extends StatelessWidget {
  final Event event;
  const _EventInfo({required this.event});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16, right: 80, bottom: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            event.name,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.3),
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6, runSpacing: 4,
            children: [
              _InfoChip(text: event.dateRangeLabel),
              if (event.locationName != null) _InfoChip(text: event.locationName!),
              _InfoChip(text: '${event.photoCount}장'),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String text;
  const _InfoChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13));
  }
}

class _PhotobookButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 14, bottom: 14,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
          // frosted glass effect
        ),
        child: const Text('포토북', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
