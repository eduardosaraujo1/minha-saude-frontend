# LocalDatabase Service

A SQLite-based local database service for storing document metadata offline.

## Overview

The `LocalDatabase` service provides a simple interface for persisting document information locally, enabling offline access and caching of documents fetched from the API.

## Features

-   ✅ Store document metadata (title, patient, doctor, type, dates)
-   ✅ Track local file paths for downloaded documents
-   ✅ Query documents by UUID
-   ✅ Update document information
-   ✅ Clear all data on logout
-   ✅ Simple, parameter-based API (no complex DTOs required)

## Database Schema

```sql
CREATE TABLE documents (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  uuid TEXT NOT NULL UNIQUE,
  titulo TEXT NULL,
  paciente TEXT NULL,
  medico TEXT NULL,
  tipo TEXT NULL,
  data_documento TEXT NULL,
  data_adicao TEXT NULL,
  local_file_path TEXT,
  deleted_at TEXT
)
```

## Usage

### 1. Initialize the database

```dart
final localDb = LocalDatabaseImpl();
await localDb.init();
```

**Note:** Initialize the database early in your app lifecycle (e.g., in `main()` or during dependency injection setup).

### 2. Add a document

```dart
await localDb.addDocument(
  uuid: 'doc-uuid-123',
  titulo: 'Exame de Sangue',
  paciente: 'João Silva',
  medico: 'Dr. Maria Santos',
  tipo: 'Exame',
  dataDocumento: DateTime(2024, 10, 1),
  dataAdicao: DateTime.now(),
  localFilePath: '/storage/documents/doc-uuid-123.pdf', // Optional
);
```

### 3. Get all documents

```dart
final documents = await localDb.getDocuments();
for (final doc in documents) {
  print('${doc.titulo} - ${doc.paciente}');
}
```

### 4. Get a specific document

```dart
final doc = await localDb.getDocument('doc-uuid-123');
if (doc != null) {
  print('Found: ${doc.titulo}');
}
```

### 5. Check if a document exists

```dart
final exists = await localDb.hasDocument('doc-uuid-123');
if (exists) {
  print('Document is cached locally');
}
```

### 6. Update a document

```dart
// Only update specific fields (all fields are optional)
await localDb.updateDocument(
  uuid: 'doc-uuid-123',
  titulo: 'Exame de Sangue (Atualizado)',
  localFilePath: '/new/path/to/file.pdf',
);
```

### 7. Update local file path

```dart
// Convenience method for updating just the file path
await localDb.updateLocalFilePath('doc-uuid-123', '/path/to/downloaded/file.pdf');
```

### 8. Remove a document

```dart
await localDb.removeDocument('doc-uuid-123');
```

### 9. Clear all data (on logout)

```dart
await localDb.clear();
```

## Integration with Repository Pattern

The LocalDatabase is designed to work alongside an API service in a repository:

```dart
class DocumentRepository {
  final DocumentApiService _apiService;
  final LocalDatabase _localDb;

  DocumentRepository(this._apiService, this._localDb);

  Future<List<Document>> getDocuments() async {
    try {
      // Try to fetch from API
      final apiDocs = await _apiService.getDocuments();

      // Update local cache
      await _localDb.clear();
      for (final doc in apiDocs) {
        await _localDb.addDocument(
          uuid: doc.uuid,
          titulo: doc.titulo,
          paciente: doc.paciente,
          medico: doc.medico,
          tipo: doc.tipo,
          dataDocumento: doc.dataDocumento,
          dataAdicao: doc.dataAdicao,
        );
      }

      return apiDocs;
    } catch (e) {
      // Fallback to local cache on error
      print('API failed, using local cache: $e');
      return await _localDb.getDocuments();
    }
  }

  Future<String?> getDocumentFilePath(String uuid) async {
    // Check if file is already downloaded
    final doc = await _localDb.getDocument(uuid);
    if (doc != null && doc.localFilePath != null) {
      return doc.localFilePath;
    }

    // Download from API if not cached
    final filePath = await _apiService.downloadDocument(uuid);
    await _localDb.updateLocalFilePath(uuid, filePath);
    return filePath;
  }
}
```

## Notes

-   The database is initialized only once. Subsequent calls to `openDatabase` will return the existing database.
-   All `DateTime` values are stored as ISO 8601 strings.
-   The `uuid` field is unique and can be used as the primary identifier.
-   The `localFilePath` field is optional and can be used to track downloaded files.
-   Call `clear()` on user logout to prevent data leakage between accounts.
