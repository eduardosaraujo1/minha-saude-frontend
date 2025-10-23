# Big Refactor: Fake Server Implementation

## Date

October 23, 2025

## Context

Major refactor decision: Replaced per-resource ApiClient classes (DocumentApiClient, AuthApiClient, TrashApiClient) with a unified ApiGateway approach. This eliminates duplicate logic between repositories and service layers.

## Tasks

### Phase 1: Auth Repository Refactor ✅

-   Refactored `LocalAuthRepository` to use `ApiGateway` instead of `AuthApiClient`
-   Updated dependency injection in `dependencies_dev.dart`
-   Fixed JSON encoding in `ApiGatewayImpl`
-   Made `routes.dart` standalone (removed invalid part-of directive)
-   Updated all auth repository tests to use `MockApiGateway`
-   Completed comprehensive documentation for all routes in `GatewayRoutes`

### Phase 2: Fake Server Implementation 🚧

**Goal**: Create a complete fake backend for offline demos and testing

#### 2.1 Fake Server Database (`FakeServerDatabase`)

Implement a SQLite-based server-side database simulator:

-   **Tables**:
    -   `tb_usuario`: User accounts with auth methods
    -   `tb_documento`: Document metadata and file references
    -   `tb_compartilhamento`: Share codes
    -   `tb_compartilhamento_documento`: Share-document relationships
-   **ORM Classes**:
    -   `UserTableORM`: CRUD operations for users
    -   `DocumentTableORM`: CRUD operations for documents
    -   `ShareTableORM`: CRUD operations for shares
-   **Features**:
    -   Persistent SQLite storage (fake_server.sqlite)
    -   Full schema initialization
    -   Public getters for all ORM tables

#### 2.2 Fake API Gateway (`FakeApiGateway`)

Implement full API simulation using FakeServerDatabase:

-   **Authentication Routes**: Login (Google/Email), Register, Logout, Send Email Code
-   **User/Profile Routes**: Get profile, Edit name/birthdate/phone, Link Google, Delete account
-   **Document Routes**: Upload, List, Categories, Get/Edit/Delete documents, Download
-   **Export Routes**: Generate data export
-   **Trash Routes**: List, View, Restore, Destroy documents
-   **Share Routes**: Create, List, Get details, Delete shares

#### 2.3 Integration & Testing

-   Write feature tests for FakeApiGateway in `test/feature/fake_server/`
-   May require `sqflite_common_ffi` for desktop/test environments
-   Ensure compatibility with existing FakeServerFileStorage
-   Validate all routes match API specification from `list.md`

## Architecture Benefits

1. **Cleaner separation**: Repository → Gateway → API (no intermediate service layer)
2. **Consistent error handling**: All errors are `ApiGatewayException` types
3. **Type-safe routing**: Centralized route definitions
4. **Better testability**: Single mock point (`ApiGateway`)
5. **Offline capability**: Complete fake backend for demos

## Future Phases

-   Phase 3: Refactor Document Repository to use ApiGateway
-   Phase 4: Refactor Profile Repository to use ApiGateway
-   Phase 5: Refactor Trash Repository to use ApiGateway
-   Phase 6: Remove deprecated ApiClient classes

## Notes

-   Keep fake backend implementations separate for now (as requested)
-   All dates use 'YYYY-MM-DD' format
-   Phone numbers: 10-11 digits without country code
-   Status fields: 'success' or 'error' (with 4xx/5xx HTTP codes on error)
