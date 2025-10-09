import 'package:multiple_result/multiple_result.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'models/document_db_model.dart';
import 'document_cache_database.dart';

/// Implementation of CacheDatabase using SQLite via sqflite package.
/// Uses DocumentDbModel for database operations with snake_case field mapping.
class DocumentCacheDatabaseImpl implements DocumentCacheDatabase {
  Database? _database;

  Database get database {
    if (_database == null) {
      throw StateError(
        'Database not initialized. Call init() before using the database.',
      );
    }
    return _database!;
  }

  @override
  Future<void> init() async {
    // Get the application documents directory for persistent storage
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'minha_saude.db');

    // openDatabase only creates the database if it doesn't exist
    // onCreate is only called once when the database is first created
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE documents (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            uuid TEXT NOT NULL UNIQUE,
            titulo TEXT NULL,
            paciente TEXT NULL,
            medico TEXT NULL,
            tipo TEXT NULL,
            data_documento TEXT NULL,
            created_at TEXT NOT NULL,
            deleted_at TEXT,
            cached_at TEXT NOT NULL
          )
        ''');
      },
    );
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
    String? titulo,
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

      // DEBUG
      // TODO: remove this print
      print('Upserted document: ${document.toJson()}');
      // Run the list query to show current state of the table
      final allDocs = await listDocuments();
      if (allDocs.isSuccess()) {
        print(
          'Current documents in DB: ${allDocs.getOrThrow().map((d) => d.toJson()).toList()}',
        );
      } else {
        print('Error listing documents: ${allDocs.tryGetError()}');
      }

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
