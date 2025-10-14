# Data Layer Request Template

Use this template when documenting or requesting work on a specific feature module (e.g., Documents, Shares, Trash, User Profile).

## Context to Provide

-   Feature name: `<Feature>`
-   Relevant user journeys / use cases with primary and alternate flows
-   Backend endpoints or platform services that must be supported, including request/response skeletons
-   Notes about required caching, offline behaviour, or consistency guarantees
-   Any known platform integrations (scanners, storage, analytics, etc.)

## Expected Deliverables

1. Summarise data-layer architecture expectations:

    - Services wrap a single remote or platform API and expose one method per endpoint.
    - Repositories act as the single source of truth, orchestrating caches and domain mapping.
    - Each repository method collaborates with **at most one service**.

2. Define or update the `<Feature>ApiClient` interface:

    - Add one method per endpoint or platform call.
    - Return typed API models (`Result<ApiModel, Exception>` or equivalent).
    - Create temporary abstract API models when full implementations are not yet available.

3. Define or update the `<Feature>Repository` interface:

    - Provide methods aligned to the feature’s use cases (list, detail, create, update, delete, etc.).
    - Include cache management hooks (`warmUp`, `clearCache`, observers) when useful.
    - Accept domain-centric payload objects rather than raw request maps.

4. List the unit tests required for `<Feature>RepositoryImpl`:
    - Organise them by behaviour (caching, error propagation, service interaction, streaming outputs).
    - Only name the tests; implementations can be added later.

## Optional Extras

-   Extract long-form notes from transient locations (e.g., test files) into dedicated documentation under `docs/`.
-   Add TODO comments or `skip` reasons so unfinished tests are easy to track.
-   Suggest next steps for related modules that share the same patterns.
