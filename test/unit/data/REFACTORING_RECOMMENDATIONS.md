# Test Refactoring Recommendations

## Files Analyzed

### ✅ Already Refactored

-   `test/unit/data/documents/document_repository_test.dart`

### 🔍 Candidates for Similar Refactoring

#### 1. `profile_repository_test.dart`

**Current Issues:**

-   Duplicate `ProfileApiModel` creation across multiple tests
-   Verbose test names that could be simplified
-   Repetitive mock setup patterns
-   Each update test follows the same pattern but with lots of duplication

**Recommended Refactoring:**

```dart
group("getProfile", () {
  late ProfileApiModel fakeProfile;

  setUp(() {
    fakeProfile = ProfileApiModel(
      id: '12345',
      nome: 'João Silva',
      cpf: '123.456.789-00',
      email: 'joao.silva@example.com',
      telefone: '11999999999',
      dataNascimento: DateTime(1990, 1, 1),
      metodoAutenticacao: 'email',
    );
  });

  test("returns profile from API", () async {
    when(() => mockProfileApiClient.getProfile())
        .thenAnswer((_) async => Success(fakeProfile));

    final result = await profileRepository.getProfile();

    expect(result.isSuccess(), true);
    // ... assertions
  });

  test("caches profile and doesn't call API again", () async {
    // ... simplified test
  });
});

// Helper function for update tests
void testUpdateMethod<T>({
  required String methodName,
  required T testValue,
  required Future<Result<String, Exception>> Function(T) apiCall,
  required Future<Result<String, Exception>> Function(T) repoCall,
  required T Function(ProfileApiModel) getFieldValue,
}) {
  test("returns same result as API", () async {
    when(() => apiCall(any()))
        .thenAnswer((_) async => const Success('value'));

    final result = await repoCall(testValue);

    expect(result.isSuccess(), true);
  });

  test("updates cache with API response", () async {
    // ... shared logic
  });
}

group("updateName", () {
  testUpdateMethod(
    methodName: 'updateName',
    testValue: 'Maria Santos',
    apiCall: mockProfileApiClient.updateName,
    repoCall: profileRepository.updateName,
    getFieldValue: (profile) => profile.nome,
  );
});
```

**Potential Savings:**

-   ~150 lines reduced
-   Less duplication in update tests
-   Easier to add new update methods

#### 2. Other Repository Tests

Similar patterns can be applied to:

-   `auth_repository_test.dart`
-   `session_repository_test.dart`

## Common Refactoring Patterns to Apply

### 1. Group-Level Setup

Move repeated test data to `setUp()` blocks within groups:

```dart
group("Feature", () {
  late MockData mockData;

  setUp(() {
    mockData = MockData(...);
  });
});
```

### 2. Helper Functions

Create helper functions for repeated test patterns:

```dart
// For simple pass-through tests
void testApiPassthrough({
  required String description,
  required Future<Result> Function() apiCall,
  required Future<Result> Function() repoCall,
}) {
  test(description, () async {
    when(apiCall).thenAnswer((_) async => Success(...));
    final result = await repoCall();
    expect(result.isSuccess(), true);
  });
}
```

### 3. Simplify Test Names

Before: `"when updatePhone is ran, result is the same as the ApiClient"`
After: `"returns same result as API"`

### 4. Remove Redundant Comments

```dart
// ❌ Too verbose
// Mock apiclient to respond success
when(...).thenAnswer(...);

// Call repository
final result = await repository.method();

// Verify response matches
expect(result.isSuccess(), true);

// ✅ Self-documenting
when(...).thenAnswer(...);
final result = await repository.method();
expect(result.isSuccess(), true);
```

### 5. Break Large Tests

If a test verifies multiple behaviors:

-   Split into focused tests
-   Each test should have ONE clear assertion

## Priority Order

1. **High Priority**: `profile_repository_test.dart` (most duplication)
2. **Medium Priority**: `auth_repository_test.dart` (check for similar patterns)
3. **Low Priority**: `session_repository_test.dart` (check for similar patterns)

## Expected Benefits

-   📉 **-30-40% lines of code** across test files
-   🎯 **Better test isolation** - each test verifies one behavior
-   🔍 **Easier debugging** - clear failure messages
-   📝 **Self-documenting** - test names describe behavior
-   ♻️ **DRY principle** - no repeated setup code
-   🚀 **Faster to write new tests** - reuse helpers

## Next Steps

1. Review `profile_repository_test.dart` in detail
2. Apply similar refactoring patterns
3. Run tests to ensure no regressions
4. Document any new patterns discovered
