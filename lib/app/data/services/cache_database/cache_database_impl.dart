import 'package:sqflite/sqflite.dart';

import '../../../domain/models/document/document.dart';
import 'cache_database.dart';

class CacheDatabaseImpl implements CacheDatabase {
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
    // openDatabase only creates the database if it doesn't exist
    // onCreate is only called once when the database is first created
    _database = await openDatabase(
      'minha_saude.db',
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
  Future<void> clear() async {
    await database.delete('documents');
  }

  @override
  Future<void> addDocument({
    required String uuid,
    String? titulo,
    String? paciente,
    String? medico,
    String? tipo,
    DateTime? dataDocumento,
    required DateTime createdAt,
    DateTime? deletedAt,
  }) async {
    await database.insert('documents', {
      'uuid': uuid,
      'titulo': titulo,
      'paciente': paciente,
      'medico': medico,
      'tipo': tipo,
      'data_documento': dataDocumento.toIso8601String(),
      'data_adicao': dataAdicao.toIso8601String(),
      'local_file_path': localFilePath,
      'deleted_at': null,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> removeDocument(String uuid) async {
    await database.delete('documents', where: 'uuid = ?', whereArgs: [uuid]);
  }

  @override
  Future<void> updateDocument({
    required String uuid,
    String? titulo,
    String? paciente,
    String? medico,
    String? tipo,
    DateTime? dataDocumento,
    DateTime? dataAdicao,
    String? localFilePath,
  }) async {
    // Build update map with only provided fields
    final Map<String, dynamic> updates = {};

    if (titulo != null) updates['titulo'] = titulo;
    if (paciente != null) updates['paciente'] = paciente;
    if (medico != null) updates['medico'] = medico;
    if (tipo != null) updates['tipo'] = tipo;
    if (dataDocumento != null) {
      updates['data_documento'] = dataDocumento.toIso8601String();
    }
    if (dataAdicao != null) {
      updates['data_adicao'] = dataAdicao.toIso8601String();
    }
    if (localFilePath != null) updates['local_file_path'] = localFilePath;

    if (updates.isEmpty) return;

    await database.update(
      'documents',
      updates,
      where: 'uuid = ?',
      whereArgs: [uuid],
    );
  }

  @override
  Future<List<Document>> getDocuments() async {
    final List<Map<String, dynamic>> maps = await database.query(
      'documents',
      orderBy: 'data_adicao DESC',
    );

    return maps.map(Document.fromJson).toList();
  }

  @override
  Future<Document?> getDocument(String uuid) async {
    final List<Map<String, dynamic>> maps = await database.query(
      'documents',
      where: 'uuid = ?',
      whereArgs: [uuid],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    return Document.fromJson(maps.first);
  }

  @override
  Future<bool> hasDocument(String uuid) async {
    final result = await database.query(
      'documents',
      columns: ['uuid'],
      where: 'uuid = ?',
      whereArgs: [uuid],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  @override
  Future<void> updateLocalFilePath(String uuid, String? filePath) async {
    await database.update(
      'documents',
      {'local_file_path': filePath},
      where: 'uuid = ?',
      whereArgs: [uuid],
    );
  }

  /// Helper method to convert database map to Document model
  // Replaced by document.fromJson()
  // Document _mapToDocument(Map<String, dynamic> map) {
  //   return Document(
  //     // Use uuid as id for local documents since we don't have a server id yet
  //     id: map['uuid'] as String,
  //     uuid: map['uuid'] as String,
  //     titulo: map['titulo'] as String,
  //     paciente: map['paciente'] as String,
  //     medico: map['medico'] as String,
  //     tipo: map['tipo'] as String,
  //     dataDocumento: DateTime.parse(map['data_documento'] as String),
  //     dataAdicao: DateTime.parse(map['data_adicao'] as String),
  //     deletedAt: map['deleted_at'] != null
  //         ? DateTime.parse(map['deleted_at'] as String)
  //         : null,
  //   );
  // }
}
