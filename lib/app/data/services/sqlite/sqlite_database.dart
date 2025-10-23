import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Cross-platform SQLite database wrapper using sqflite_common_ffi
///
/// Supports iOS, Android, Windows, Linux, and MacOS.
/// Each instance manages a separate database file.
/// Must be initialized before use by calling [init].
class SqliteDatabase {
  SqliteDatabase({
    required this.databaseFileName,
    required this.onCreate,
    this.version = 1,
  });

  /// The name of the database file (e.g., 'minha_saude.db', 'fake_server.sqlite')
  final String databaseFileName;

  /// Callback to create the database schema on first initialization
  final Future<void> Function(Database db, int version) onCreate;

  /// Database schema version
  final int version;

  Database? _database;
  static DatabaseFactory? _databaseFactory;

  /// Get the database instance
  ///
  /// Throws [StateError] if not initialized. Call [init] first.
  Database get database {
    if (_database == null) {
      throw StateError(
        'Database not initialized. Call init() before using the database.',
      );
    }
    return _database!;
  }

  /// Get the appropriate database factory for the platform
  static DatabaseFactory get databaseFactory {
    if (_databaseFactory != null) {
      return _databaseFactory!;
    }

    // Initialize FFI for Windows/Linux
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      _databaseFactory = databaseFactoryFfi;
    } else {
      // On iOS/Android/MacOS, use the default factory
      // This will use the system SQLite (or sqlite3_flutter_libs if added)
      _databaseFactory = databaseFactoryFfi;
    }

    return _databaseFactory!;
  }

  /// Initialize the database
  ///
  /// Creates the database file if it doesn't exist and runs [onCreate] callback.
  /// Subsequent calls will reuse the existing database.
  Future<void> init() async {
    if (_database != null) {
      return; // Already initialized
    }

    // Handle in-memory database
    if (databaseFileName == ':memory:') {
      final path = inMemoryDatabasePath;

      // Open or create the in-memory database
      _database = await databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(version: version, onCreate: onCreate),
      );
      return;
    }

    // Get the application documents directory for persistent storage
    final databasesPath = await getApplicationDocumentsDirectory();
    final path = p.join(databasesPath.path, databaseFileName);

    // Open or create the database
    _database = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(version: version, onCreate: onCreate),
    );
  }

  /// Close the database connection
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // ========== Factory Methods ==========

  /// Create a SqliteDatabase instance for the cache database (client-side)
  static SqliteDatabase forCacheDatabase({bool inMemory = false}) {
    return SqliteDatabase(
      databaseFileName: inMemory ? ':memory:' : 'minha_saude.db',
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE documents (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            uuid TEXT NOT NULL UNIQUE,
            titulo TEXT NOT NULL,
            paciente TEXT NULL,
            medico TEXT NULL,
            tipo TEXT NULL,
            data_documento TEXT NULL,
            created_at TEXT NOT NULL,
            deleted_at TEXT NULL,
            cached_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  /// Create a SqliteDatabase instance for the fake server database
  static SqliteDatabase forFakeServerDatabase({bool inMemory = false}) {
    return SqliteDatabase(
      databaseFileName: inMemory ? ':memory:' : 'fake_server.sqlite',
      version: 1,
      onCreate: (db, version) async {
        // Users table
        await db.execute('''
          CREATE TABLE tb_usuario (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cpf TEXT NOT NULL UNIQUE,
            nome TEXT NOT NULL,
            data_nascimento TEXT NOT NULL,
            telefone TEXT,
            email TEXT NOT NULL UNIQUE,
            metodo_autenticacao TEXT NOT NULL,
            google_id TEXT,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP,
            deleted_at TEXT
          )
        ''');

        // Documents table
        await db.execute('''
          CREATE TABLE tb_documento (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            uuid TEXT NOT NULL UNIQUE,
            titulo TEXT NOT NULL,
            nome_paciente TEXT,
            nome_medico TEXT,
            tipo_documento TEXT,
            data_documento TEXT,
            processando_metadados INTEGER NOT NULL DEFAULT 0,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP,
            deleted_at TEXT,
            fk_id_usuario INTEGER NOT NULL,
            FOREIGN KEY (fk_id_usuario) REFERENCES tb_usuario(id)
          )
        ''');

        // Shares table
        await db.execute('''
          CREATE TABLE tb_compartilhamento (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            codigo TEXT NOT NULL UNIQUE,
            data_primeiro_uso TEXT,
            expirado INTEGER DEFAULT 0,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP,
            deleted_at TEXT,
            fk_id_usuario INTEGER NOT NULL,
            FOREIGN KEY (fk_id_usuario) REFERENCES tb_usuario(id)
          )
        ''');

        // Share-Document junction table
        await db.execute('''
          CREATE TABLE tb_compartilhamento_documento (
            id_compartilhamento INTEGER,
            id_documento INTEGER,
            PRIMARY KEY (id_compartilhamento, id_documento),
            FOREIGN KEY (id_compartilhamento) REFERENCES tb_compartilhamento(id) ON DELETE CASCADE,
            FOREIGN KEY (id_documento) REFERENCES tb_documento(id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }
}
