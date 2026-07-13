# Context & Domain Language

## Authentication
* **AuthBottomSheet**: The unified, single-component entry point for all authentication flows in the app (Login, Register, and Forgot Password). State transitions between these flows happen in-place without stacking new screens.
* **AuthMode**: The current state of the AuthBottomSheet. Can be `login`, `signUp`, or `forgotPassword`. 
  * The `forgotPassword` mode allows direct password resets and contains fields for: Username, New Password, and Confirm New Password.
  * When in `forgotPassword` mode, the Bottom Sheet header will show a "Back" arrow on the top left to return to the `login` mode.
