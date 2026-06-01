// SQLite 로컬 DB - 사진 분석 결과와 이벤트를 저장하는 서비스
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/photo.dart';
import '../models/event.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._();
  static Database? _db;

  DatabaseService._();
  factory DatabaseService() => _instance;

  Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'reel.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE photos (
            id TEXT PRIMARY KEY,
            file_path TEXT NOT NULL,
            taken_at INTEGER NOT NULL,
            latitude REAL,
            longitude REAL,
            labels TEXT,
            ocr_text TEXT,
            event_id INTEGER,
            analyzed INTEGER DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE events (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            cover_photo_id TEXT NOT NULL,
            start_at INTEGER NOT NULL,
            end_at INTEGER NOT NULL,
            location_name TEXT,
            latitude REAL,
            longitude REAL,
            photo_count INTEGER DEFAULT 0
          )
        ''');

        await db.execute('CREATE INDEX idx_photos_taken_at ON photos(taken_at)');
        await db.execute('CREATE INDEX idx_photos_event_id ON photos(event_id)');
        await db.execute('CREATE VIRTUAL TABLE photos_fts USING fts5(id, labels, ocr_text)');
      },
    );
  }

  // 사진 저장 (이미 있으면 무시)
  Future<void> insertPhoto(Photo photo) async {
    final database = await db;
    await database.insert(
      'photos',
      {...photo.toMap(), 'analyzed': 0},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // 분석 완료된 사진 업데이트
  Future<void> updatePhotoAnalysis(Photo photo) async {
    final database = await db;
    await database.update(
      'photos',
      {
        'labels': photo.labels.join(','),
        'ocr_text': photo.ocrText,
        'event_id': photo.eventId,
        'analyzed': 1,
      },
      where: 'id = ?',
      whereArgs: [photo.id],
    );
    // FTS 인덱스 업데이트
    await database.insert(
      'photos_fts',
      {'id': photo.id, 'labels': photo.labels.join(' '), 'ocr_text': photo.ocrText ?? ''},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 아직 분석 안 된 사진 목록
  Future<List<Photo>> getUnanalyzedPhotos({int limit = 50}) async {
    final database = await db;
    final rows = await database.query(
      'photos',
      where: 'analyzed = 0',
      orderBy: 'taken_at DESC',
      limit: limit,
    );
    return rows.map(Photo.fromMap).toList();
  }

  // 이벤트 저장
  Future<int> insertEvent(Event event) async {
    final database = await db;
    return database.insert('events', event.toMap());
  }

  // 이벤트 전체 목록 (최신순)
  Future<List<Event>> getAllEvents() async {
    final database = await db;
    final rows = await database.query('events', orderBy: 'start_at DESC');
    return rows.map(Event.fromMap).toList();
  }

  // 이벤트에 속한 사진 목록
  Future<List<Photo>> getPhotosByEvent(int eventId) async {
    final database = await db;
    final rows = await database.query(
      'photos',
      where: 'event_id = ?',
      whereArgs: [eventId],
      orderBy: 'taken_at ASC',
    );
    return rows.map(Photo.fromMap).toList();
  }

  // 자연어 검색 (FTS)
  Future<List<Photo>> searchPhotos(String query) async {
    final database = await db;
    final rows = await database.rawQuery(
      'SELECT p.* FROM photos p JOIN photos_fts f ON p.id = f.id WHERE photos_fts MATCH ? ORDER BY p.taken_at DESC',
      [query],
    );
    return rows.map(Photo.fromMap).toList();
  }

  // 총 사진 수
  Future<int> getPhotoCount() async {
    final database = await db;
    final result = await database.rawQuery('SELECT COUNT(*) as cnt FROM photos');
    return (result.first['cnt'] as int?) ?? 0;
  }
}
