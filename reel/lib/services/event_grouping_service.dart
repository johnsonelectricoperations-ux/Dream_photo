// 사진들을 시간·위치 기반으로 이벤트(추억)로 자동 그룹화하는 핵심 알고리즘
import 'dart:math';
import 'package:geocoding/geocoding.dart';
import '../models/photo.dart';
import '../models/event.dart';
import 'database_service.dart';

class EventGroupingService {
  final DatabaseService _db;

  // 같은 이벤트로 묶는 기준
  static const int _timeGapHours = 6;       // 6시간 이상 간격 = 새 이벤트
  static const double _distanceKm = 50.0;   // 50km 이상 이동 = 새 이벤트

  static final EventGroupingService instance = EventGroupingService._();
  EventGroupingService._() : _db = DatabaseService();
  factory EventGroupingService() => instance;

  // 전체 사진을 이벤트로 그룹화
  Future<List<Event>> groupPhotosIntoEvents(List<Photo> photos) async {
    if (photos.isEmpty) return [];

    // 시간순 정렬
    final sorted = [...photos]..sort((a, b) => a.takenAt.compareTo(b.takenAt));

    final groups = <List<Photo>>[];
    var currentGroup = <Photo>[sorted.first];

    for (int i = 1; i < sorted.length; i++) {
      final prev = sorted[i - 1];
      final curr = sorted[i];

      final timeGap = curr.takenAt.difference(prev.takenAt).inHours;
      final distGap = _distanceBetween(prev, curr);

      // 시간 또는 거리 기준 초과 시 새 이벤트 시작
      final isNewEvent = timeGap >= _timeGapHours ||
          (distGap != null && distGap > _distanceKm);

      if (isNewEvent) {
        groups.add(currentGroup);
        currentGroup = [curr];
      } else {
        currentGroup.add(curr);
      }
    }
    groups.add(currentGroup);

    // 그룹이 1장뿐이면 이벤트로 만들지 않음 (단순 스냅샷)
    final validGroups = groups.where((g) => g.length >= 2).toList();

    final events = <Event>[];
    for (final group in validGroups) {
      final event = await _createEvent(group);
      if (event != null) {
        final id = await _db.insertEvent(event);
        // 해당 사진들의 event_id 업데이트
        for (final photo in group) {
          await _db.updatePhotoAnalysis(photo.copyWith(eventId: id));
        }
        events.add(Event(
          id: id,
          name: event.name,
          coverPhotoId: event.coverPhotoId,
          startAt: event.startAt,
          endAt: event.endAt,
          locationName: event.locationName,
          latitude: event.latitude,
          longitude: event.longitude,
          photoCount: event.photoCount,
        ));
      }
    }

    return events;
  }

  Future<Event?> _createEvent(List<Photo> photos) async {
    if (photos.isEmpty) return null;

    final start = photos.first.takenAt;
    final end = photos.last.takenAt;
    final center = _centerLocation(photos);
    String? locationName;

    // GPS 있으면 지역명 조회
    if (center != null) {
      locationName = await _reverseGeocode(center.$1, center.$2);
    }

    final name = _generateEventName(start, end, locationName);

    return Event(
      name: name,
      coverPhotoId: _selectCoverPhoto(photos).id,
      startAt: start,
      endAt: end,
      locationName: locationName,
      latitude: center?.$1,
      longitude: center?.$2,
      photoCount: photos.length,
      photoIds: photos.map((p) => p.id).toList(),
    );
  }

  // 이벤트 이름 자동 생성
  String _generateEventName(DateTime start, DateTime end, String? location) {
    final duration = end.difference(start).inDays;
    final month = '${start.month}월';

    if (location != null) {
      if (duration >= 1) return '$location 여행';
      return location;
    }

    // 위치 없으면 계절·시기로 이름 생성
    final season = _getSeason(start.month);
    if (duration >= 2) return '$season 여행';
    return '$month 추억';
  }

  String _getSeason(int month) {
    if (month >= 3 && month <= 5) return '봄';
    if (month >= 6 && month <= 8) return '여름';
    if (month >= 9 && month <= 11) return '가을';
    return '겨울';
  }

  // 사진들의 중심 좌표 계산
  (double, double)? _centerLocation(List<Photo> photos) {
    final withLocation = photos.where((p) => p.hasLocation).toList();
    if (withLocation.isEmpty) return null;

    final avgLat = withLocation.map((p) => p.latitude!).reduce((a, b) => a + b) /
        withLocation.length;
    final avgLng = withLocation.map((p) => p.longitude!).reduce((a, b) => a + b) /
        withLocation.length;
    return (avgLat, avgLng);
  }

  // GPS 좌표 → 지역명 (한국어)
  Future<String?> _reverseGeocode(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return null;
      final p = placemarks.first;
      // 시·군·구 수준 지역명 반환
      return p.locality ?? p.subAdministrativeArea ?? p.administrativeArea;
    } catch (_) {
      return null;
    }
  }

  // 표지 사진 선택 (중간 시점의 사진)
  Photo _selectCoverPhoto(List<Photo> photos) {
    // 위치 정보 있는 사진 우선
    final withLocation = photos.where((p) => p.hasLocation).toList();
    if (withLocation.isNotEmpty) return withLocation[withLocation.length ~/ 2];
    return photos[photos.length ~/ 2];
  }

  // 두 사진 사이 거리 계산 (km)
  double? _distanceBetween(Photo a, Photo b) {
    if (!a.hasLocation || !b.hasLocation) return null;
    return _haversine(a.latitude!, a.longitude!, b.latitude!, b.longitude!);
  }

  double _haversine(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0; // 지구 반지름 (km)
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _toRad(double deg) => deg * pi / 180;
}
