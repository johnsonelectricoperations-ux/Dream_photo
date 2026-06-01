// 앱 전체에서 공유하는 상수 정의
import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF1A1A2E);      // 딥 네이비
  static const accent = Color(0xFFE94560);        // 따뜻한 레드-핑크
  static const background = Color(0xFFF8F8F8);
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF8A8A9A);
  static const cardShadow = Color(0x14000000);
}

class AppStrings {
  static const appName = 'Reel';
  static const tagline = '우리의 추억이 저절로 정리됩니다';
  static const scanningPhotos = '사진을 불러오는 중...';
  static const analyzingPhotos = 'AI가 추억을 정리하는 중...';
  static const noEvents = '아직 추억이 없어요\n사진을 찍고 돌아오면 자동으로 정리됩니다';
  static const photos = '장';
  static const memories = '추억';
}

class AppDimens {
  static const eventCardHeight = 200.0;
  static const eventCardRadius = 16.0;
  static const padding = 16.0;
  static const paddingSmall = 8.0;
}
