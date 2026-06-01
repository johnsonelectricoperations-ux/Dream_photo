// 이벤트(추억) 목록과 검색 결과를 관리하는 Riverpod provider
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event.dart';
import '../models/photo.dart';
import '../services/database_service.dart';

// 전체 이벤트 목록
final eventsProvider = FutureProvider<List<Event>>((ref) async {
  return DatabaseService.instance.getAllEvents();
});

// 특정 이벤트의 사진 목록
final eventPhotosProvider = FutureProvider.family<List<Photo>, String>((ref, eventId) async {
  return DatabaseService.instance.getPhotosByEvent(eventId);
});

// 검색어 상태
final searchQueryProvider = StateProvider<String>((_) => '');

// 검색 결과 (FTS5)
final searchResultsProvider = FutureProvider<List<Photo>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return [];
  return DatabaseService.instance.searchPhotos(query);
});

// 분석 진행 상황 (홈 배너용)
class AnalysisStats {
  final int total;
  final int analyzed;

  const AnalysisStats({required this.total, required this.analyzed});
  double get progress => total > 0 ? analyzed / total : 0.0;
  bool get isComplete => total > 0 && analyzed >= total;
}

final analysisStatsProvider = FutureProvider<AnalysisStats>((ref) async {
  final db = DatabaseService.instance;
  final total = await db.getPhotoCount();
  final unanalyzed = await db.getUnanalyzedPhotos();
  return AnalysisStats(total: total, analyzed: total - unanalyzed.length);
});
