# Data Layer Architecture Guidelines

## Core Roles

-   **Services** encapsulate integration with remote or platform-specific APIs (REST endpoints, device capabilities). They expose low-level methods that mirror the underlying API surface, without orchestrating other services or applying application-level business rules.
-   **Repositories** are the single source of truth consumed by the rest of the app. They compose service calls, persist/cache results, and expose rich domain models tailored to use cases.

## Service Design Principles

-   Provide one method per backend endpoint or platform interaction, returning typed API models. For complex payloads, declare dedicated `ApiModel` abstractions.
-   Keep services stateless and free of caching logic. They should not depend on repositories or other services.
-   Surface failures with typed error objects or exceptions that repositories can map to domain errors.

## Repository Design Principles

-   Consume at most one service per repository method to keep responsibilities isolated and testable.
-   Translate API models to domain entities and merge them with local cache or storage when needed.
-   Maintain local caches or persistence so the repository can quickly fulfill read requests and reconcile updates after successful service calls.
-   Expose results using `Future<Result<SuccessType, FailureType>>` (or equivalent) to model success/error flows explicitly.

## Use Case Alignment

-   Model repository methods around user journeys (e.g., uploadDocument, scanDocument, listDocuments), ensuring each method orchestrates only the interactions required for its specific use case.
-   Split multi-step flows into separate methods when different services are involved (e.g., `scanDocument` uses a `DocumentScannerService`, while `uploadDocument` calls the HTTP API).

## Testing Strategy

-   Unit-test repositories by stubbing dependent services and verifying caching, mapping, and error handling logic.
-   Service tests (if any) should focus on serialization/deserialization and HTTP contract adherence, but may be deprioritized compared to repository coverage.
