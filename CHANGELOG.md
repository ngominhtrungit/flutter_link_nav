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