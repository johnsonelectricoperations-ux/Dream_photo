// ML Kit 온디바이스 AI - 이미지 라벨링·OCR (무료·오프라인)
import 'dart:io';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/photo.dart';
import 'database_service.dart';

class MlKitService {
  final DatabaseService _db;
  late final ImageLabeler _labeler;
  late final TextRecognizer _textRecognizer;

  // ML Kit 라벨 → 한국어 태그 변환 (주요 카테고리)
  static const Map<String, String> _labelMap = {
    'Food': '음식',
    'Beach': '해변',
    'Mountain': '산',
    'Sky': '하늘',
    'Nature': '자연',
    'Tree': '나무',
    'Water': '물',
    'Ocean': '바다',
    'Flower': '꽃',
    'Building': '건물',
    'City': '도시',
    'Car': '자동차',
    'Vehicle': '차량',
    'Person': '사람',
    'Face': '얼굴',
    'Animal': '동물',
    'Dog': '강아지',
    'Cat': '고양이',
    'Document': '문서',
    'Text': '텍스트',
    'Receipt': '영수증',
    'Night': '야경',
    'Sunset': '노을',
    'Snow': '눈',
    'Wedding': '결혼식',
    'Birthday': '생일',
    'Festival': '축제',
  };

  MlKitService(this._db) {
    _labeler = ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: 0.75),
    );
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.korean);
  }

  // 사진 한 장 분석 (라벨링 + OCR)
  Future<Photo> analyzePhoto(Photo photo) async {
    final inputImage = InputImage.fromFilePath(photo.filePath);
    final file = File(photo.filePath);
    if (!await file.exists()) return photo;

    final labels = await _getLabels(inputImage);
    final ocrText = await _getOcrText(inputImage);

    final analyzed = photo.copyWith(labels: labels, ocrText: ocrText);
    await _db.updatePhotoAnalysis(analyzed);
    return analyzed;
  }

  // 백그라운드 일괄 분석 (충전 중일 때 조금씩)
  Future<void> analyzeInBackground({
    int batchSize = 10,
    void Function(int done, int total)? onProgress,
  }) async {
    final pending = await _db.getUnanalyzedPhotos(limit: batchSize);
    final total = await _db.getPhotoCount();

    for (int i = 0; i < pending.length; i++) {
      await analyzePhoto(pending[i]);
      onProgress?.call(i + 1, total);
      // UI 응답성 유지를 위해 잠시 대기
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<List<String>> _getLabels(InputImage inputImage) async {
    try {
      final results = await _labeler.processImage(inputImage);
      return results
          .map((label) => _labelMap[label.label] ?? label.label)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<String?> _getOcrText(InputImage inputImage) async {
    try {
      final result = await _textRecognizer.processImage(inputImage);
      final text = result.text.trim();
      return text.isEmpty ? null : text;
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    _labeler.close();
    _textRecognizer.close();
  }
}
