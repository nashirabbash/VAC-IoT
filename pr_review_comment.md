## Standards

### Documented Standards Violations (Hard Violations)

- **AGENTS.md (Tips Navigasi - "Tambah fitur UI → mulai dari lib/component/"):** 
  `lib/utils/toast_helper.dart` violates the file structure standard. It returns UI widgets (Toastification builders) but was placed in `utils/` instead of `component/`.

- **CLAUDE.md (Rule 13 - Don't Repeat Yourself / DRY):**
  `lib/utils/toast_helper.dart` violates DRY. The UI rendering in `showError` and `showSuccess` is completely duplicated. The only differences are the background color and the icon.

### Baseline Smells (Judgement Calls)

- **Duplicated Code:** 
  In `lib/component/auth_bottom_sheet.dart`, the exact same error fallback logic shape appears in both `_handleLogin` and `_handleRegister`:
  ```dart
  final errorMsg = e.toString().replaceAll('Exception: ', '');
  ToastHelper.showError(context, AuthHelper.getUserFriendlyError(errorMsg));
  ```

- **Primitive Obsession:** 
  In `lib/utils/auth_helper.dart`, `getUserFriendlyError(String raw)` relies on matching string primitives to deduce error states rather than catching domain-specific types:
  ```dart
  if (lower.contains('authunauthorized') || lower.contains('unauthorized') || lower.contains('kredensial')) {
    return 'Username atau password yang Anda masukkan salah.';
  }
  ```
  This logic should ideally handle strongly-typed exceptions (like `AuthException`) instead of doing raw string inspection.

- **Middle Man:** 
  In `lib/repositories/auth_repository.dart`, the `logout()` method delegates almost entirely to `ApiService`. This creates a tangled circular dependency where `AuthRepository` takes `ApiService` via DI, while `ApiService` takes an `ApiInterceptor` which in turn requires `AuthRepository`.
  ```dart
  Future<void> logout() async {
    await _api.logout();
    await clearToken();
  }
  ```

## Spec

**(a) Missing or partial requirements**
All functional acceptance criteria are implemented, but the exact technical constraint for the widget test is missed due to a refactoring deviation (see section c).

**(b) Scope creep (behaviour in the diff that wasn't asked for)**
The PR contains multiple commits and changes entirely unrelated to the logout feature:
- Adding camera permissions, ML Kit barcode metadata to `AndroidManifest.xml`, and ProGuard rules to fix a scanner crash.
- Improving error UI with a custom minimalist top toast, extracting helper logic, and wiring up design system color tokens and `AppText` components.

These additions go beyond the defined scope. 
Spec reference:
> "This requires wiring up the UI to hit the `/auth/logout` endpoint, clearing the token on success, and returning to the Welcome screen."

**(c) Requirements that look implemented but where the implementation looks wrong / deviates**
The developer refactored the DI to orchestrate the logout process entirely within `AuthRepository`, leading to two deviations from the strict technical requirements:

1. Spec: 
> "- [ ] The "Log out" button in `HomeScreen`'s avatar menu calls `ApiService.logout()`"
Implementation: The `HomeScreen` button calls `_authRepository.logout()` instead of directly calling `ApiService.logout()`.

2. Spec: 
> "- [ ] Widget tests are added to verify this success path by mocking `ApiService.logout()`"
Implementation: The widget test (`homeScreens_test.dart`) mocks `mockAuthRepository.logout()` instead of `ApiService.logout()`. While it successfully tests the user path, it violates the literal technical instruction in the acceptance criteria.

---
**Summary:** Standards: 5 findings (Worst: duplicated UI rendering violating DRY in `toast_helper.dart`); Spec: 3 findings (Worst: scope creep containing unrelated camera/ML Kit fixes and toast components).
