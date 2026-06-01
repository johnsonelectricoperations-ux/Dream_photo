// 홈 화면에서 이벤트(추억)를 보여주는 카드 위젯
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/event.dart';
import '../utils/constants.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;

  const EventCard({super.key, required this.event, this.onTap});

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
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.eventCardRadius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _CoverImage(photoId: event.coverPhotoId),
              _Gradient(),
              _EventInfo(event: event),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  final String photoId;
  const _CoverImage({required this.photoId});

  @override
  Widget build(BuildContext context) {
    // TODO: DatabaseService로 파일 경로 조회 후 표시
    return Container(color: AppColors.textSecondary.withOpacity(0.3));
  }
}

class _Gradient extends StatelessWidget {
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
      left: 16,
      right: 16,
      bottom: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            event.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                event.dateRangeLabel,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${event.photoCount}${AppStrings.photos}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
