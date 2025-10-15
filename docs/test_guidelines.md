## Test Guidelines

This document aims to create a standard as to what should be tested in each component of the application

## Application Components

The application is divided into the following layers:

1. Data Layer
    - Repositories
    - Services
2. Domain Layer
    - Actions
3. UI Layer
    - ViewModels
    - Views

### Important Rules

1. Always test business logic
2. Modularize tests, aim for each test function testing a single funcionality
3. Use models and mocks provided in the [testing](/testing/) folder.

## Test Scope

### Data Layer: Repositories

Each function in Repositories should be tested for:

-   [UNIT] Returns value provided by data source after the Act
-   [INTEGRATION] Calls correct services on the Act
-   [CACHE] Performs a cache hit on frequent READ calls

### Data Layer: Services

Services should not be tested, as they rely on external APIs that cannot be mocked.

### Domain Layer: Action

Actions should be tested for:

-   [UNIT] Returns the same value as provided by the data sources after action is performed
-   [INTEGRATION] Calls the correct methods after action is performed

### UI Layer: ViewModels

Each command in ViewModels should be tested for:

-   [UNIT] Defines the correct model state after Act
-   [INTEGRATION] Assert correct repositories were called
-   Note: Unit and Integration tests may be placed into one single function, since it is easy to assert function calls after the correct view model state is present

### UI Layer: Views

Each View (Screen) should be tested for:

-   [UNIT] Existance of essential elements (i.e. can find a button to do something)
-   [UNIT] Presence of business logic requirements (example: profile screen must display user info in text)
-   Note: do NOT test for things like navigation or "does this button work", that is for the exploratory test
