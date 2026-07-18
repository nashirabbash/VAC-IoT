Review for commit `b65bd41c4f49c921d341c0221674b2ee3b78a500`:

## Standards

### `lib/screens/homeScreens.dart`
* **(a) Violation [Hard]:** `CLAUDE.md` — Rule 13 (Single Responsibility Principle). The UI widget assumes responsibility for string-parsing and formatting error messages instead of consuming a clean, UI-ready domain error.
* **(b) Smell: Message Chains** (with traces of Primitive Obsession)
  ```dart
  + SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
  ```

### `lib/services/api_service.dart`
* **(a) Violation [Hard]:** `CLAUDE.md` — Rule 13 (Don't Repeat Yourself). The fallback instantiation logic for the repository is unnecessarily repeated.
* **(b) Smell: Duplicated Code**
  ```dart
  +    : _authRepository = authRepository ?? AuthRepository(),
  +      _client = client ?? ApiInterceptor(authRepository: authRepository ?? AuthRepository());
  ```
  *(Judgement call: While likely an artifact of Dart's constructor initializer constraints, it evaluates `AuthRepository()` twice if null, incorrectly creating two separate instances).*

### `test/screens/homeScreens_test.dart`
* **(a) Violation [Hard]:** `CLAUDE.md` — Rule 9 (Tests verify intent). The test configures the mocked `apiService` to manually perform a side effect (`clearToken`), then asserts that side effect occurred. If the real `ApiService.logout()` implementation is broken and drops token clearance, this test will still pass.
  ```dart
  +    when(() => mockApiService.logout()).thenAnswer((_) async {
  +      await AuthRepository().clearToken();
  +    });
       ...
  +    expect(await AuthRepository().getToken(), null);
  ```

### `test/services/api_service_test.dart`
* **(a) Violation [Hard]:** `CLAUDE.md` — Rule 9 (Tests verify intent). The test stubs `mockAuthRepository.clearToken()` but only asserts that the method completes. It fails to add a `verify(...).called(1)` assertion to ensure `clearToken` was actually invoked. A test that can't fail when business logic breaks is wrong.
  ```dart
  +      when(() => mockAuthRepository.clearToken()).thenAnswer((_) async {});
         await expectLater(api.logout(), completes);
  ```

## Spec

**(a) Missing or partial requirements**
- **Spec:** *"Widget tests are added to verify this success path by mocking `ApiService.logout()`"*
  **Finding:** In `test/services/api_service_test.dart`, the test stubs the `clearToken()` method on `mockAuthRepository`, but it fails to actually assert that the method was invoked. It is missing a verification like `verify(() => mockAuthRepository.clearToken()).called(1);`.

**(b) Scope creep (behaviour not asked for)**
- **Spec:** *"Acceptance criteria [focuses strictly on the success path]"*
  **Finding:** The commit introduces complex JSON error body parsing in `ApiService.logout()`. While the commit message notes this addresses previous feedback, it technically falls outside the explicitly defined acceptance criteria of this specific ticket, which only dictates the success path. 

**(c) Implementation looks wrong**
- **Spec:** *"Widget tests are added to verify this success path by mocking `ApiService.logout()`"*
  **Finding:** In `test/screens/homeScreens_test.dart`, the widget test breaks mock isolation. The mocked `logout()` method manually instantiates and calls a real `AuthRepository().clearToken()`, and the test later asserts against the real state using `expect(await AuthRepository().getToken(), null)`. Widget tests should verify interactions with mocked dependencies rather than triggering and asserting side effects on real instances.
- **Spec:** *(Implicit from the note about addressing "UI unhandled exceptions")*
  **Finding:** In `lib/screens/homeScreens.dart`, cleaning the error message for the SnackBar using `e.toString().replaceAll('Exception: ', '')` is a brittle anti-pattern. The service layer should throw a custom domain exception (e.g., `AuthException(message)`) so the UI can catch it explicitly and display a clean message without relying on string manipulation.
- **Spec:** *"On a successful response, the local token is cleared via `AuthRepository`"* (and previous error handling feedback)
  **Finding:** In `lib/services/api_service.dart`, the code unconditionally casts the parsed JSON: `jsonDecode(res.body) as Map<String, dynamic>`. If the server returns a non-JSON response (like HTML) or a JSON array, this will throw a `TypeError`. The `catch` block only handles `FormatException`, meaning a `TypeError` will bypass the custom exception logic and be rethrown, potentially causing an unhandled crash in the UI.

---
**Summary:** Standards: 4 findings (Worst: incorrect manual side effects in tests violating Rule 9); Spec: 4 findings (Worst: widget test breaks mock isolation and manipulates real state).
