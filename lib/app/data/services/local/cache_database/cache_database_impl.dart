import 'package:multiple_result/multiple_result.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '../../sqlite/sqlite_database.dart';
import 'cache_database.dart';
import 'models/document_db_model.dart';

/// Implementation of CacheDatabase using SQLite via sqflite_common_ffi.
/// Uses DocumentDbModel for database operations with snake_case field mapping.
class CacheDatabaseImpl implements CacheDatabase {
  CacheDatabaseImpl({required this.sqliteDatabase});

  final SqliteDatabase sqliteDatabase;

  Database get database => sqliteDatabase.database;

  @override
  Future<void> init() async {
    await sqliteDatabase.init();
  }

  @override
  Future<Result<void, Exception>> clear() async {
    try {
      await database.delete('documents');
      return const Success(null);
    } catch (e) {
      return Error(Exception('Failed to clear database: $e'));
    }
  }

  @override
  Future<Result<DocumentDbModel, Exception>> upsertDocument(
    String uuid, {
    required String titulo,
    String? paciente,
    String? medico,
    String? tipo,
    DateTime? dataDocumento,
    required DateTime createdAt,
    DateTime? deletedAt,
    DateTime? cachedAt,
  }) async {
    try {
      // Create document with cachedAt defaulting to now if not provided
      final document = DocumentDbModel(
        uuid: uuid,
        titulo: titulo,
        paciente: paciente,
        medico: medico,
        tipo: tipo,
        dataDocumento: dataDocumento,
        createdAt: createdAt,
        deletedAt: deletedAt,
        cachedAt: cachedAt ?? DateTime.now(),
      );

      // Use toJson to get snake_case mapped fields
      // ConflictAlgorithm.replace makes this an upsert operation
      await database.insert(
        'documents',
        document.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return Success(document);
    } catch (e) {
      return Error(Exception('Failed to upsert document: $e'));
    }
  }

  @override
  Future<Result<void, Exception>> removeDocument(String uuid) async {
    try {
      final count = await database.delete(
        'documents',
        where: 'uuid = ?',
        whereArgs: [uuid],
      );

      if (count == 0) {
        return Error(Exception('Document not found'));
      }

      return const Success(null);
    } catch (e) {
      return Error(Exception('Failed to remove document: $e'));
    }
  }

  @override
  Future<Result<List<DocumentDbModel>, Exception>> listDocuments() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'documents',
        orderBy: 'created_at DESC',
      );

      // Convert from database maps to DocumentDbModel using fromJson (handles snake_case)
      final documents = maps.map((map) {
        return DocumentDbModel.fromJson(map);
      }).toList();

      return Success(documents);
    } catch (e) {
      return Error(Exception('Failed to list documents: $e'));
    }
  }

  @override
  Future<Result<DocumentDbModel?, Exception>> getDocument(String uuid) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'documents',
        where: 'uuid = ?',
        whereArgs: [uuid],
        limit: 1,
      );

      if (maps.isEmpty) {
        return const Success(null);
      }

      // Convert from database map to DocumentDbModel using fromJson (handles snake_case)
      final document = DocumentDbModel.fromJson(maps.first);

      return Success(document);
    } catch (e) {
      return Error(Exception('Failed to get document: $e'));
    }
  }

  @override
  Future<Result<void, Exception>> trashDocument(String uuid) async {
    try {
      final count = await database.update(
        'documents',
        {'deleted_at': DateTime.now().toIso8601String()},
        where: 'uuid = ?',
        whereArgs: [uuid],
      );

      if (count == 0) {
        return Error(Exception('Document not found'));
      }

      return const Success(null);
    } catch (e) {
      return Error(Exception('Failed to trash document: $e'));
    }
  }
}
