# 1.5.1
- Add explicit material and full screen material transition types
- Fix issue in transition logic
- Remove redundant `new`, `const`, etc qualifiers
- Tidy example
- Add font license info

# 1.5.0
- Native transitions will now use the Cupertino page route on iOS and Material page route on android. This will enable swipe gestures on iOS.
- Added cupertino specific transition types. 
- **You should not be using Cupertino types on non-iOS platforms. It's up to you, but it's bad design**.

# 1.4.0
- Added the ability to define a transition at the point of route definition. Route transitions are optional and any transition defined a "push" will override the route definition.

# 1.3.7
- Add `toString` for custom `RouteNotFoundException` type

# 1.3.6
- Small fix to error return type when no route match was made

# 1.3.5
- add `pop` convenience
- add `clearStack` flag so that you can clear the history when pushing a route

# 1.3.4
- Change lower dart version to cater to older flutter versions

# 1.3.3
- Fix analyzer issues
- Remove deprecations in example code
- Fix pubspec analysis issue

# 1.3.2
- Dart 2 package (pubspec) compliance changes ONLY
- **Note**: No functional changes

# 1.3.1
- Fixes an issue with the route generator (result cannot be Null)

# 1.3.0
- **BREAKING**: Parameters now return an array of results even if they have a single value.
- Support for parameter arrays. e.g: `/some/route?color=red&color=green&color=blue`.
- Results can now be passed via `Navigator.pop` via use of a `Future`.
- A few bug fixes

# 1.1.0

**BREAKING**: In order to support function handlers you will need to change all of your route 
handler definitions to use the new `Handler` class. The `RouteHandler` definition has now been 
removed.

Swapping out the handlers should be as simple as changing:

```dart
RouteHandler usersHandler = (Map<String, String> params) {}
```

to

```dart
var usersHandler = new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {});
```
