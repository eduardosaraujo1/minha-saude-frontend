# Document Upload Repository

The `DocumentUploadRepository` provides an abstraction layer for document scanning and file picking functionality in the Minha Saúde app.

## Features

-   **Document Scanning**: Use device camera to scan documents using `flutter_doc_scanner`
-   **File Picking**: Select files from device storage using `file_picker`
-   **Result Pattern**: All methods return `Result<T, Exception>` for consistent error handling
-   **Type Safety**: Custom `DocumentFile` model for file information

## Usage

### 1. Dependency Injection

The repository is automatically registered in the GetIt container:

```dart
import 'package:get_it/get_it.dart';
import 'package:minha_saude_frontend/app/data/document/repositories/document_upload_repository.dart';

final repository = GetIt.I<DocumentUploadRepository>();
```

### 2. Scanning Documents

```dart
Future<void> scanDocument() async {
  final result = await repository.scanDocument(maxPages: 4);

  if (result.isSuccess()) {
    final documentFile = result.getOrThrow();
    print('Scanned: ${documentFile.name}');
    print('Path: ${documentFile.path}');
    print('Size: ${documentFile.size} bytes');
    print('Type: ${documentFile.mimeType}');
  } else {
    final error = result.tryGetError()!;
    print('Error: $error');
  }
}
```

### 3. Picking Files

```dart
Future<void> pickFile() async {
  final result = await repository.uploadDocumentFromFile(
    allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
  );

  if (result.isSuccess()) {
    final documentFile = result.getOrThrow();
    print('Selected: ${documentFile.name}');
    print('Path: ${documentFile.path}');
    print('Size: ${documentFile.size} bytes');
    print('Type: ${documentFile.mimeType}');
  } else {
    final error = result.tryGetError()!;
    print('Error: $error');
  }
}
```

## Models

### DocumentFile

Represents a document file with metadata:

```dart
class DocumentFile {
  final String path;        // Full path to the file
  final String name;        // File name with extension
  final int size;          // File size in bytes
  final String? mimeType;  // MIME type (e.g., 'application/pdf')
}
```

## Methods

### scanDocument

Scans a document using the device camera.

**Parameters:**

-   `maxPages` (optional): Maximum number of pages to scan (default: 4)

**Returns:** `Future<Result<DocumentFile, Exception>>`

**Behavior:**

-   Opens camera scanner interface
-   Returns PDF file path on success
-   Handles platform-specific errors gracefully

### uploadDocumentFromFile

Selects a file from device storage.

**Parameters:**

-   `allowedExtensions` (optional): List of allowed file extensions

**Returns:** `Future<Result<DocumentFile, Exception>>`

**Behavior:**

-   Opens file picker interface
-   Supports custom file type filtering
-   Validates file existence before returning

## Error Handling

Both methods use the `Result<T, Exception>` pattern:

```dart
final result = await repository.scanDocument();

// Check for success
if (result.isSuccess()) {
  final file = result.getOrThrow();
  // Handle success
}

// Check for error
if (result.isError()) {
  final error = result.tryGetError()!;
  // Handle error
}
```

## Supported File Types

The repository automatically detects MIME types for common extensions:

-   **PDF**: `application/pdf`
-   **Images**: `image/jpeg`, `image/png`, `image/gif`, etc.
-   **Documents**: `application/msword`, etc.
-   **Default**: `application/octet-stream`

## Dependencies

-   `flutter_doc_scanner: ^0.0.16` - Document scanning
-   `file_picker: ^10.3.3` - File selection
-   `multiple_result: ^5.2.0` - Result pattern

## Example Widget

See `lib/app/presentation/document/widgets/document_upload_example.dart` for a complete usage example.

## Testing

Unit tests are available in `test/unit/document_upload_repository_test.dart` covering:

-   Successful document scanning
-   Error handling scenarios
-   DocumentFile model validation
-   Mock integration testing
