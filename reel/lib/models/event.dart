// 여러 장의 사진을 하나의 추억 단위로 묶은 이벤트 모델
class Event {
  final int? id;
  final String name;
  final String coverPhotoId;
  final DateTime startAt;
  final DateTime endAt;
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final int photoCount;
  final List<String> photoIds;

  const Event({
    this.id,
    required this.name,
    required this.coverPhotoId,
    required this.startAt,
    required this.endAt,
    this.locationName,
    this.latitude,
    this.longitude,
    required this.photoCount,
    this.photoIds = const [],
  });

  // 날짜 범위를 한국어로 표현
  String get dateRangeLabel {
    final start = _formatDate(startAt);
    final end = _formatDate(endAt);
    return startAt.day == endAt.day ? start : '$start ~ $end';
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'cover_photo_id': coverPhotoId,
        'start_at': startAt.millisecondsSinceEpoch,
        'end_at': endAt.millisecondsSinceEpoch,
        'location_name': locationName,
        'latitude': latitude,
        'longitude': longitude,
        'photo_count': photoCount,
      };

  factory Event.fromMap(Map<String, dynamic> map) => Event(
        id: map['id'] as int?,
        name: map['name'] as String,
        coverPhotoId: map['cover_photo_id'] as String,
        startAt:
            DateTime.fromMillisecondsSinceEpoch(map['start_at'] as int),
        endAt: DateTime.fromMillisecondsSinceEpoch(map['end_at'] as int),
        locationName: map['location_name'] as String?,
        latitude: map['latitude'] as double?,
        longitude: map['longitude'] as double?,
        photoCount: map['photo_count'] as int,
      );
}
