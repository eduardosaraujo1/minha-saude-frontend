// Use fake_server.sqlite file, creating if it doesn't exist, just like in local/cache_database
// This simulates a server-side database
// Store Documents, Users and Shares
// DB Schema (needs to be adapted to SQLite):
/*
CREATE TABLE tb_usuario (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    nome VARCHAR(255) NOT NULL,
    data_nascimento DATE NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    metodo_autenticacao VARCHAR(255) NOT NULL, -- Google, Email
    google_id VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

CREATE TABLE tb_documento (
    id INT PRIMARY KEY AUTO_INCREMENT,
    uuid CHAR(36) NOT NULL UNIQUE, -- Usado no app para referenciar o documento
    caminho_arquivo VARCHAR(255) NOT NULL,
    titulo VARCHAR(255) NOT NULL,
    nome_paciente VARCHAR(255),
    nome_medico VARCHAR(255),
    tipo_documento VARCHAR(120),
    data_documento DATE,
    processando_metadados TINYINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    fk_id_usuario CHAR(36) NOT NULL,
    FOREIGN KEY (fk_id_usuario) REFERENCES tb_usuario(id)
);

CREATE TABLE tb_compartilhamento (
    id INT PRIMARY KEY AUTO_INCREMENT,
    codigo CHAR(8) NOT NULL UNIQUE,
    data_primeiro_uso TIMESTAMP NULL,
    expirado BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    fk_id_usuario CHAR(36) NOT NULL,
    FOREIGN KEY (fk_id_usuario) REFERENCES tb_usuario(id)
);

CREATE TABLE tb_compartilhamento_documento (
    id_compartilhamento CHAR(36),
    id_documento CHAR(36),
    PRIMARY KEY (id_compartilhamento, id_documento),
    FOREIGN KEY (id_compartilhamento) REFERENCES tb_compartilhamento(id) ON DELETE CASCADE,
    FOREIGN KEY (id_documento) REFERENCES tb_documento(id) ON DELETE CASCADE
);
 */

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class FakeServerDatabase {
  FakeServerDatabase();

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
    final databasesPath = await getApplicationDocumentsDirectory();
    final path = join(databasesPath.path, 'fake_server.sqlite');

    // openDatabase only creates the database if it doesn't exist
    // onCreate is only called once when the database is first created
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          
        ''');
      },
    );
  }
}

abstract class TableORM {
  Future<void> create(Map<String, dynamic> data);
  Future<Map<String, dynamic>?> read(String id);
  Future<List<Map<String, dynamic>>> readAll();
  Future<void> update(String id, Map<String, dynamic> data);
  Future<void> delete(String id);
}

class DocumentTableORM implements TableORM {
  final Database database;

  DocumentTableORM(this.database);

  @override
  Future<void> create(Map<String, dynamic> data) async {
    await database.insert('tb_documento', data);
  }

  @override
  Future<Map<String, dynamic>?> read(String id) async {
    final results = await database.query(
      'tb_documento',
      where: 'uuid = ?',
      whereArgs: [id],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  @override
  Future<List<Map<String, dynamic>>> readAll() async {
    return await database.query('tb_documento');
  }

  @override
  Future<void> update(String id, Map<String, dynamic> data) async {
    await database.update(
      'tb_documento',
      data,
      where: 'uuid = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> delete(String id) async {
    await database.delete('tb_documento', where: 'uuid = ?', whereArgs: [id]);
  }
}
