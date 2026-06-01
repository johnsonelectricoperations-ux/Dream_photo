// 갤러리에서 가져온 사진 한 장의 데이터 모델
class Photo {
  final String id;
  final String filePath;
  final DateTime takenAt;
  final double? latitude;
  final double? longitude;
  final List<String> labels;
  final String? ocrText;
  final int? eventId;

  const Photo({
    required this.id,
    required this.filePath,
    required this.takenAt,
    this.latitude,
    this.longitude,
    this.labels = const [],
    this.ocrText,
    this.eventId,
  });

  bool get hasLocation => latitude != null && longitude != null;

  Map<String, dynamic> toMap() => {
        'id': id,
        'file_path': filePath,
        'taken_at': takenAt.millisecondsSinceEpoch,
        'latitude': latitude,
        'longitude': longitude,
        'labels': labels.join(','),
        'ocr_text': ocrText,
        'event_id': eventId,
      };

  factory Photo.fromMap(Map<String, dynamic> map) => Photo(
        id: map['id'] as String,
        filePath: map['file_path'] as String,
        takenAt: DateTime.fromMillisecondsSinceEpoch(map['taken_at'] as int),
        latitude: map['latitude'] as double?,
        longitude: map['longitude'] as double?,
        labels: (map['labels'] as String?)
                ?.split(',')
                .where((s) => s.isNotEmpty)
                .toList() ??
            [],
        ocrText: map['ocr_text'] as String?,
        eventId: map['event_id'] as int?,
      );

  Photo copyWith({
    List<String>? labels,
    String? ocrText,
    int? eventId,
  }) =>
      Photo(
        id: id,
        filePath: filePath,
        takenAt: takenAt,
        latitude: latitude,
        longitude: longitude,
        labels: labels ?? this.labels,
        ocrText: ocrText ?? this.ocrText,
        eventId: eventId ?? this.eventId,
      );
}
