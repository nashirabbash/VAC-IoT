Review for commit `9412ebf5179c5bbc824750f683eb44469c82071e`:

## Standards

### `lib/services/api_service.dart`

**Standard Violation (Hard Violation)**
- **Rule:** `AGENTS.md` (and `CLAUDE.md`) — **Rule 3 — Surgical Changes**
- **Details:** The commit's explicit goal is to remove the Middle Man pattern in `AuthRepository`. However, this hunk deletes the detailed JSON error parsing logic and replaces it with a generic exception. This modifies unrelated, adjacent code and refactors something that wasn't broken.
- **Hunk:**
```dart
-      final body = jsonDecode(res.body) as Map<String, dynamic>;
-      final errObj = body['error'] ?? body;
-      final errMsg = _parseErrorMessage(errObj['summary'] ?? errObj['message']);
-      throw Exception(errMsg ?? 'Failed to logout');
+      throw Exception('Failed to logout');
```

---

### `lib/screens/homeScreens.dart`

**Standard Violation (Judgement Call)**
- **Rule:** `AGENTS.md` (and `CLAUDE.md`) — **Rule 13 — Always Apply Clean Code Principles (SRP)**
- **Details:** By removing the `logout()` orchestration from `AuthRepository`, the UI is now forced to handle the coordination of the API logout and token clearing. This gives the presentation layer domain logic responsibilities, violating the Single Responsibility Principle.

**Baseline Smell (Judgement Call)**
- **Smell:** **Shotgun Surgery** (and creeping **Data Clumps**)
- **Details:** While the commit fulfills the PR review's request to remove the Middle Man, it creates a more brittle design. Since the UI now coordinates the multi-step logout flow, any future changes to this process will require scattered edits across every widget that triggers a logout (Shotgun Surgery). Additionally, it forces `apiService` and `authRepository` to be passed around together, forming a nascent Data Clump.

## Spec

**(a) Missing or partial requirements**
None. The commit successfully addresses the deviations identified in the previous review. 
- It satisfies _"The "Log out" button in `HomeScreen`'s avatar menu calls `ApiService.logout()`"_ by wiring `_apiService.logout()` directly to the UI button instead of delegating to `_authRepository`. 
- It satisfies _"Widget tests are added to verify this success path by mocking `ApiService.logout()`"_ by introducing `MockApiService` and verifying it in the test suite.

**(b) Scope creep (behaviour in the diff that wasn't asked for)**
In `lib/services/api_service.dart`, the commit deletes the detailed JSON error parsing logic (`jsonDecode`, `_parseErrorMessage`, etc.) and replaces it with a generic, hardcoded `throw Exception('Failed to logout');`. This degrades the quality of error handling and is unrelated to fixing the UI and testing deviations.
- **Spec line:** _"`ApiService.logout()` sends a POST request to `/auth/logout`"_ (The scope was to make the API call and wire up the UI, not to remove or degrade the service's existing error parsing logic).

**(c) Implemented but looks wrong**
The success path logic is implemented, but the UI implementation is fragile. In `HomeScreen.dart`, the API call is awaited without a `try/catch` block. If the server returns an error, `_apiService.logout()` will throw an exception. Because it is unhandled, it will halt the async callback without providing any error feedback to the user.
- **Spec lines:** _"On a successful response, the local token is cleared via `AuthRepository`"_ and _"On a successful response, the app navigates to `WelcomeScreens`"_. While the current code correctly skips these steps on failure, a robust implementation should catch the exception and ideally present an error message to the user.

---
**Summary:** Standards: 3 findings (Worst: degrading error parsing in `api_service.dart` violating Surgical Changes); Spec: 2 findings (Worst: fragile UI implementation with unhandled exceptions in `HomeScreen.dart`).
