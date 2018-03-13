# 1.2.2
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
