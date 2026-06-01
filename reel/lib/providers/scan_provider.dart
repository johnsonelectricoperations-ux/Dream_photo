// 갤러리 스캔 및 이벤트 그룹화 진행 상태를 관리하는 Riverpod provider
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/gallery_service.dart';
import '../services/event_grouping_service.dart';
import '../services/ml_kit_service.dart';
import '../services/database_service.dart';

enum ScanStatus { idle, requestingPermission, scanning, grouping, analyzing, done, error }

class ScanState {
  final ScanStatus status;
  final int scanned;
  final int total;
  final String message;
  final String? errorMessage;

  const ScanState({
    this.status = ScanStatus.idle,
    this.scanned = 0,
    this.total = 0,
    this.message = '',
    this.errorMessage,
  });

  ScanState copyWith({
    ScanStatus? status,
    int? scanned,
    int? total,
    String? message,
    String? errorMessage,
  }) =>
      ScanState(
        status: status ?? this.status,
        scanned: scanned ?? this.scanned,
        total: total ?? this.total,
        message: message ?? this.message,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  double get progress => total > 0 ? scanned / total : 0.0;
  bool get isRunning => status == ScanStatus.scanning ||
      status == ScanStatus.grouping ||
      status == ScanStatus.analyzing ||
      status == ScanStatus.requestingPermission;
}

class ScanNotifier extends StateNotifier<ScanState> {
  ScanNotifier() : super(const ScanState());

  Future<bool> requestAndScan() async {
    state = state.copyWith(
      status: ScanStatus.requestingPermission,
      message: '갤러리 접근 권한 요청 중...',
    );

    final granted = await GalleryService.instance.requestPermission();
    if (!granted) {
      state = state.copyWith(
        status: ScanStatus.error,
        errorMessage: '갤러리 접근 권한이 필요합니다.\n설정에서 허용해주세요.',
      );
      return false;
    }

    await _scan();
    return true;
  }

  Future<void> _scan() async {
    state = state.copyWith(status: ScanStatus.scanning, message: '사진을 불러오는 중...');

    try {
      final photos = await GalleryService.instance.syncGallery(
        onProgress: (scanned, total) {
          state = state.copyWith(scanned: scanned, total: total);
        },
      );

      state = state.copyWith(
        status: ScanStatus.grouping,
        message: 'AI가 추억을 정리하는 중...',
        scanned: 0,
        total: 0,
      );

      await EventGroupingService.instance.groupPhotosIntoEvents(photos);

      state = state.copyWith(
        status: ScanStatus.analyzing,
        message: '사진을 분석하는 중...',
      );

      final unanalyzed = await DatabaseService.instance.getUnanalyzedPhotos();
      await MlKitService.instance.analyzeInBackground(
        unanalyzed,
        onProgress: (done, total) {
          state = state.copyWith(scanned: done, total: total);
        },
      );

      state = state.copyWith(status: ScanStatus.done, message: '완료!');
    } catch (e) {
      state = state.copyWith(
        status: ScanStatus.error,
        errorMessage: '오류가 발생했습니다: $e',
      );
    }
  }
}

final scanProvider = StateNotifierProvider<ScanNotifier, ScanState>(
  (_) => ScanNotifier(),
);
