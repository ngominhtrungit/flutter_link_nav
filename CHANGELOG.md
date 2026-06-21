## 3.3.0
- **NEW**: Added `AppRoutes.withName` smart RoutePredicate to support `Navigator.popUntil` with Path Parameters.
- **NEW**: Added Path Parameters support (`:id`) in route matching and parameter parsing.
- **TEST**: Added comprehensive unit tests for `AppRoutes.withName` and path parameters routing.
- **DOCS**: Updated README with detailed Path Parameters examples and test verification guide.

## 3.2.0
- **NEW**: Added `DeepLinkGuard` system for navigation interception (Auth, redirection, etc.).
- **NEW**: Added `TabDeepLinkMixin` to simplify tab-based navigation setup in `StatefulWidget`.
- **NEW**: Added `DeepLinkObjectX.toParams` extension for safe casting of dynamic/Object parameters to `Map<String, String>`.
- **NEW**: Added `onUnknownRoute` and `onError` callbacks to `DeepLinkHandler.init`.
- **IMPROVED**: `RouteAction` now supports asynchronous execution (`FutureOr<void>`).
- **IMPROVED**: `DeepLinkHandler` now supports re-initialization with new context and updated handlers.
- **BREAKING CHANGE**: `handleNavigationOnTab` now returns `Future<bool>` instead of `bool` to support async guards.
- **BREAKING CHANGE**: `RouteHandler` signature updated from `dynamic` to `Object?` for better type safety.
- **FIX**: Corrected `AppRoutes.registerRoutes` to properly register guards in the global `RouteRegistry`.
- **TEST**: Added comprehensive unit and widget tests for the guard system and core logic.
- **DOCS**: Added `MIGRATION_GUIDE.md` and updated `README.md` with new features.

## 3.1.2+1
- Update example app with better tab navigation.
- Update UI for README.md.

## 3.1.1
- Refactored `NavigationExtension` to use unified URI parsing from `UriParser` extension.
- Optimized deep link handling logic in `DeepLinkHandler`.
- Internal code cleanup and improvements.

## 3.1.0
- Upgrade `app_links` to `^7.0.0`.
- Update Flutter environment compatibility for latest versions (Dart 3.5+).
- Internal optimizations for deep link handling.

## 3.0.1
- Added Tab Screen (multiple tabs) deep link handling example.
- Highlighted required Input parameters (`getTabIndex`, `currentTabIndex`, `updateTabIndex`).
- Clarified URI host vs path parsing for schemes like `example.vn://main_screen`.

## 3.0.0
- **BREAKING CHANGE**: Simplified `RouteHandler` signature by removing `fromSource` parameter.
  - **Migration**: Update your route handlers from `(queryParams, fromSource) => Widget()` to `(queryParams) => Widget()`.
  - The `fromSource` parameter was redundant as all information can be passed through `queryParams`.
- **NEW FEATURE**: Added `actionRegister` support for executing actions without navigation.
  - Routes can now have both `widgetRegister` (for UI) and `actionRegister` (for actions like showBottomSheet, showDialog, etc.).
  - Deep links with only `actionRegister` will execute the action directly without attempting navigation.

## 2.0.0
- **BREAKING CHANGE**: Changed `builder` parameter to `widgetRegister` in `RouteConfig`.
  - **Migration**: Replace `builder: (queryParams, fromSource) => YourWidget()` with `widgetRegister: (queryParams, fromSource) => YourWidget()` in your route configurations.
  - This change provides better naming consistency and clarity for widget registration in routes.
- Describe the functions of the relevant function and class.
- Upgrade library dependencies app_links.

## 1.0.4
- Add example in platform macOS.
- optimize code.
- Update README.md.
## 1.0.3
- Add example, how to use `DeepLinkHandler` in README.md.
## 1.0.2

- Update exactly support flatforms: Android, iOS.
- Optimize code.

## 1.0.1+1

- Add example how to use `DeepLinkHandler` in README.md.

## 1.0.1

- Add description and guidelines for android, iOS setup in README.md.

## 1.0.0+1

- Initial Open Source release.
