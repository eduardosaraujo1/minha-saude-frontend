/// Fake Server Database - Simulates server-side persistence
///
/// Uses SQLite to store users, documents, and shares just like a real backend.
/// This enables offline demos and comprehensive testing.
library;

import 'package:sqflite_common/sqlite_api.dart';

import '../../sqlite/sqlite_database.dart';

class FakeServerDatabase {
  FakeServerDatabase({required this.sqliteDatabase});

  final SqliteDatabase sqliteDatabase;

  UserTableORM? _userTable;
  DocumentTableORM? _documentTable;
  ShareTableORM? _shareTable;

  Database get database => sqliteDatabase.database;

  /// User table operations
  UserTableORM get users {
    if (_userTable == null) {
      throw StateError('Database not initialized. Call init() first.');
    }
    return _userTable!;
  }

  /// Document table operations
  DocumentTableORM get documents {
    if (_documentTable == null) {
      throw StateError('Database not initialized. Call init() first.');
    }
    return _documentTable!;
  }

  /// Share table operations
  ShareTableORM get shares {
    if (_shareTable == null) {
      throw StateError('Database not initialized. Call init() first.');
    }
    return _shareTable!;
  }

  Future<void> init() async {
    await sqliteDatabase.init();

    // Initialize ORM instances
    _userTable = UserTableORM(database);
    _documentTable = DocumentTableORM(database);
    _shareTable = ShareTableORM(database);
  }

  /// Clear all data (useful for testing)
  Future<void> clearAll() async {
    await database.delete('tb_compartilhamento_documento');
    await database.delete('tb_compartilhamento');
    await database.delete('tb_documento');
    await database.delete('tb_usuario');
  }
}

// ========== ORM Base Interface ==========

abstract class TableORM {
  Future<int> create(Map<String, dynamic> data);
  Future<Map<String, dynamic>?> read(int id);
  Future<List<Map<String, dynamic>>> readAll();
  Future<void> update(int id, Map<String, dynamic> data);
  Future<void> delete(int id);
}

// ========== User Table ORM ==========

class UserTableORM implements TableORM {
  final Database database;

  UserTableORM(this.database);

  @override
  Future<int> create(Map<String, dynamic> data) async {
    return await database.insert('tb_usuario', data);
  }

  @override
  Future<Map<String, dynamic>?> read(int id) async {
    final results = await database.query(
      'tb_usuario',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> findByEmail(String email) async {
    final results = await database.query(
      'tb_usuario',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> findByCpf(String cpf) async {
    final results = await database.query(
      'tb_usuario',
      where: 'cpf = ?',
      whereArgs: [cpf],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> findByGoogleId(String googleId) async {
    final results = await database.query(
      'tb_usuario',
      where: 'google_id = ?',
      whereArgs: [googleId],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  @override
  Future<List<Map<String, dynamic>>> readAll() async {
    return await database.query('tb_usuario', where: 'deleted_at IS NULL');
  }

  @override
  Future<void> update(int id, Map<String, dynamic> data) async {
    await database.update('tb_usuario', data, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> delete(int id) async {
    // Soft delete
    await database.update(
      'tb_usuario',
      {'deleted_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> hardDelete(int id) async {
    await database.delete('tb_usuario', where: 'id = ?', whereArgs: [id]);
  }
}

// ========== Document Table ORM ==========

class DocumentTableORM implements TableORM {
  final Database database;

  DocumentTableORM(this.database);

  @override
  Future<int> create(Map<String, dynamic> data) async {
    return await database.insert('tb_documento', data);
  }

  @override
  Future<Map<String, dynamic>?> read(int id) async {
    final results = await database.query(
      'tb_documento',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> findByUuid(String uuid) async {
    final results = await database.query(
      'tb_documento',
      where: 'uuid = ?',
      whereArgs: [uuid],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> findByUser(int userId) async {
    return await database.query(
      'tb_documento',
      where: 'fk_id_usuario = ? AND deleted_at IS NULL',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> findDeletedByUser(int userId) async {
    return await database.query(
      'tb_documento',
      where: 'fk_id_usuario = ? AND deleted_at IS NOT NULL',
      whereArgs: [userId],
      orderBy: 'deleted_at DESC',
    );
  }

  @override
  Future<List<Map<String, dynamic>>> readAll() async {
    return await database.query('tb_documento', where: 'deleted_at IS NULL');
  }

  @override
  Future<void> update(int id, Map<String, dynamic> data) async {
    await database.update(
      'tb_documento',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateByUuid(String uuid, Map<String, dynamic> data) async {
    await database.update(
      'tb_documento',
      data,
      where: 'uuid = ?',
      whereArgs: [uuid],
    );
  }

  @override
  Future<void> delete(int id) async {
    // Soft delete
    await database.update(
      'tb_documento',
      {'deleted_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> restore(int id) async {
    await database.update(
      'tb_documento',
      {'deleted_at': null},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> hardDelete(int id) async {
    await database.delete('tb_documento', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> hardDeleteByUuid(String uuid) async {
    await database.delete('tb_documento', where: 'uuid = ?', whereArgs: [uuid]);
  }
}

// ========== Share Table ORM ==========

class ShareTableORM implements TableORM {
  final Database database;

  ShareTableORM(this.database);

  @override
  Future<int> create(Map<String, dynamic> data) async {
    return await database.insert('tb_compartilhamento', data);
  }

  @override
  Future<Map<String, dynamic>?> read(int id) async {
    final results = await database.query(
      'tb_compartilhamento',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> findByCode(String code) async {
    final results = await database.query(
      'tb_compartilhamento',
      where: 'codigo = ? AND deleted_at IS NULL',
      whereArgs: [code],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> findByUser(int userId) async {
    return await database.query(
      'tb_compartilhamento',
      where: 'fk_id_usuario = ? AND deleted_at IS NULL',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  @override
  Future<List<Map<String, dynamic>>> readAll() async {
    return await database.query(
      'tb_compartilhamento',
      where: 'deleted_at IS NULL',
    );
  }

  @override
  Future<void> update(int id, Map<String, dynamic> data) async {
    await database.update(
      'tb_compartilhamento',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateByCode(String code, Map<String, dynamic> data) async {
    await database.update(
      'tb_compartilhamento',
      data,
      where: 'codigo = ?',
      whereArgs: [code],
    );
  }

  @override
  Future<void> delete(int id) async {
    // Soft delete
    await database.update(
      'tb_compartilhamento',
      {'deleted_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteByCode(String code) async {
    await database.update(
      'tb_compartilhamento',
      {'deleted_at': DateTime.now().toIso8601String()},
      where: 'codigo = ?',
      whereArgs: [code],
    );
  }

  Future<void> hardDelete(int id) async {
    await database.delete(
      'tb_compartilhamento',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Share-Document relationship methods
  Future<void> addDocument(int shareId, int documentId) async {
    await database.insert('tb_compartilhamento_documento', {
      'id_compartilhamento': shareId,
      'id_documento': documentId,
    });
  }

  Future<void> removeDocument(int shareId, int documentId) async {
    await database.delete(
      'tb_compartilhamento_documento',
      where: 'id_compartilhamento = ? AND id_documento = ?',
      whereArgs: [shareId, documentId],
    );
  }

  Future<List<Map<String, dynamic>>> getDocuments(int shareId) async {
    final results = await database.rawQuery(
      '''
      SELECT d.* FROM tb_documento d
      INNER JOIN tb_compartilhamento_documento cd ON d.id = cd.id_documento
      WHERE cd.id_compartilhamento = ?
    ''',
      [shareId],
    );
    return results;
  }
}
