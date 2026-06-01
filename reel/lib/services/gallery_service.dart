// 휴대폰 갤러리 접근 및 EXIF 파싱 서비스
import 'package:photo_manager/photo_manager.dart';
import 'package:exif/exif.dart';
import '../models/photo.dart';
import 'database_service.dart';

class GalleryService {
  static final GalleryService instance = GalleryService._();
  GalleryService._() : _db = DatabaseService();
  factory GalleryService() => instance;

  final DatabaseService _db;

  // 갤러리 접근 권한 요청
  Future<bool> requestPermission() async {
    final result = await PhotoManager.requestPermissionExtend();
    return result.isAuth;
  }

  // 전체 사진을 DB에 등록 (EXIF만 읽음 - 빠름, 무료)
  Future<int> syncGallery({
    void Function(int current, int total)? onProgress,
  }) async {
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: FilterOptionGroup(
        imageOption: const FilterOption(needTitle: true),
        orders: [const OrderOption(type: OrderOptionType.createDate, asc: false)],
      ),
    );

    if (albums.isEmpty) return 0;

    final allPhotos = await albums.first.getAssetListRange(start: 0, end: 999999);
    int synced = 0;

    for (int i = 0; i < allPhotos.length; i++) {
      final asset = allPhotos[i];
      onProgress?.call(i + 1, allPhotos.length);

      final photo = await _assetToPhoto(asset);
      if (photo != null) {
        await _db.insertPhoto(photo);
        synced++;
      }
    }

    return synced;
  }

  Future<Photo?> _assetToPhoto(AssetEntity asset) async {
    try {
      final file = await asset.file;
      if (file == null) return null;

      DateTime takenAt = asset.createDateTime;
      double? lat = asset.latitude;
      double? lng = asset.longitude;

      // EXIF에서 정밀한 촬영 시간·위치 추출
      try {
        final bytes = await file.readAsBytes();
        final exifData = await readExifFromBytes(bytes);

        if (exifData.containsKey('Image DateTime')) {
          final raw = exifData['Image DateTime']!.printable;
          takenAt = _parseExifDate(raw) ?? takenAt;
        }

        if (exifData.containsKey('GPS GPSLatitude')) {
          lat = _parseGpsValue(exifData['GPS GPSLatitude']!.printable,
              exifData['GPS GPSLatitudeRef']?.printable ?? 'N');
          lng = _parseGpsValue(exifData['GPS GPSLongitude']!.printable,
              exifData['GPS GPSLongitudeRef']?.printable ?? 'E');
        }
      } catch (_) {
        // EXIF 파싱 실패 시 기본값 사용
      }

      return Photo(
        id: asset.id,
        filePath: file.path,
        takenAt: takenAt,
        latitude: lat != 0 ? lat : null,
        longitude: lng != 0 ? lng : null,
      );
    } catch (_) {
      return null;
    }
  }

  DateTime? _parseExifDate(String raw) {
    try {
      // EXIF 형식: "2023:08:01 14:32:00"
      final parts = raw.split(' ');
      final dateParts = parts[0].split(':');
      final timeParts = parts.length > 1 ? parts[1].split(':') : ['0', '0', '0'];
      return DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
        int.parse(timeParts[2]),
      );
    } catch (_) {
      return null;
    }
  }

  double _parseGpsValue(String value, String ref) {
    try {
      // "37/1, 27/1, 3456/100" 형식 파싱
      final parts = value.split(', ');
      double degrees = _parseFraction(parts[0]);
      double minutes = parts.length > 1 ? _parseFraction(parts[1]) : 0;
      double seconds = parts.length > 2 ? _parseFraction(parts[2]) : 0;
      double result = degrees + minutes / 60 + seconds / 3600;
      return (ref == 'S' || ref == 'W') ? -result : result;
    } catch (_) {
      return 0;
    }
  }

  double _parseFraction(String frac) {
    final parts = frac.trim().split('/');
    if (parts.length == 2) return double.parse(parts[0]) / double.parse(parts[1]);
    return double.parse(parts[0]);
  }
}
