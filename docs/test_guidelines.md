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

1. Always ask "what does the caller of this method expect to happen?"
2. Modularize tests, aim for each test function testing a single functionality of your unit
3. Use models and mocks provided in the [testing](/testing/) folder.
4. Only check for function calls between layers (i.e. viewModels -> action or viewModels -> repository). This is the equivalent of asserting an HTTP request was made.
5. Name tests as briefly as you can, use `given, when, then` when deciding what the test should do but always presume the test name starts with `it...`

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
-   [UNIT] Form validation
-   [INTEGRATION] Correct repository methods are called when widget main functionality is performed
-   Note1: ViewModels should not be mocked as they are part of a widget's internal implementation.
-   Note2: do NOT test for secondary functionality, only the main one. For example, for a widget that provides a form for the user to fill and upload, assert the form is validated and the form is calling the viewModel, but do not write a test to see if the cancel button is working.
