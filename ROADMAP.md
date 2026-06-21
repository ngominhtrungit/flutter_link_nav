# Flutter Link Nav Roadmap

This document outlines the planned features and improvements for `flutter_link_nav`.

## Planned Features

### Phase 1: Core Enhancement & DX
- [x] **Path Parameters Support**: Support routes like `/user/:id` instead of just query parameters.
- [x] **Smart popUntil Support**: Introduce `AppRoutes.withName` to resolve and pop back to dynamic path parameter routes.
- [x] **Deep Link Guards**: Add a middleware guard/interceptor system for deep link checks (Auth, redirection).
- [x] **Tab Deep Link Mixin**: Provide `TabDeepLinkMixin` to easily synchronize tab switches from links.
- [ ] **Navigation Observer**: Provide a `DeepLinkObserver` to track deep link navigation events and analytics.
- [ ] **Improved Route Matching**: Support Regex or pattern matching for more flexible URI mapping.
- [ ] **Global Error Screens**: Provide a customizable default UI for unknown routes.

### Phase 2: Ecosystem & Integration
- [ ] **Integration Guides**: Detailed documentation for Bloc, Riverpod, and Provider.
- [ ] **Automation Scripts**: CLI tools to help configure Android App Links and iOS Universal Links.

### Phase 3: Code Generation
- [ ] **Code Generation (`build_runner`)**: Automatically generate route constants and type-safe parameter classes.

---

## Decisions & Notes

### Web Support
- **Status**: Deferred / Not Planned.
- **Reason**: The current focus is on mobile (Android, iOS) and desktop (macOS). Web support is not a priority at this time and will not be implemented in the immediate future.
