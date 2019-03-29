<img src="https://storage.googleapis.com/product-logos/logo_fluro.png" width="220">
<br/><br/>

The brightest, hippest, coolest router for Flutter.

[![Version](https://img.shields.io/badge/version-1.4.0-blue.svg)](https://pub.dartlang.org/packages/fluro)
[![Build Status](https://travis-ci.org/theyakka/fluro.svg?branch=master)](https://travis-ci.org/theyakka/fluro)
[![Coverage](https://codecov.io/gh/theyakka/fluro/branch/master/graph/badge.svg)](https://codecov.io/gh/theyakka/fluro)

## Features

- Simple route navigation
- Function handlers (map to a function instead of a route)
- Wildcard parameter matching
- Querystring parameter parsing
- Common transitions built-in
- Simple custom transition creation

## Version compatability

See CHANGELOG for all breaking (and non-breaking) changes.

## Getting started

You should ensure that you add the router as a dependency in your flutter project.
```yaml
dependencies:
 fluro: "^1.5.0"
```

You can also reference the git repo directly if you want:
```yaml
dependencies:
 fluro:
   git: git://github.com/theyakka/fluro.git
```


You should then run `flutter packages upgrade` or update your packages in IntelliJ.

## Example Project

There is a pretty sweet example project in the `example` folder. Check it out. Otherwise, keep reading to get up and running.

## Setting up

First, you should define a new `Router` object by initializing it as such:
```dart
final router = Router();
```
It may be convenient for you to store the router globally/statically so that
you can access the router in other areas in your application.

After instantiating the router, you will need to define your routes and your route handlers:
```dart
var usersHandler = Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params, Object arguments) {
  return UsersScreen(params["id"][0]);
});

void defineRoutes(Router router) {
  router.define("/users/:id", handler: usersHandler);

  // it is also possible to define the route transition to use
  // router.define("users/:id", handler: usersHandler, transitionType: TransitionType.inFromLeft);
}
```

In the above example, the router will intercept a route such as
`/users/1234` and route the application to the `UsersScreen` passing
the value `1234` as a parameter to that screen.

## Navigating

You can use the `Router` with the `MaterialApp.onGenerateRoute` parameter
via the `Router.generator` function. To do so, pass the function reference to
the `onGenerate` parameter like: `onGenerateRoute: router.generator`.

You can then use `Navigator.push` and the flutter routing mechanism will match the routes
for you.

You can also manually push to a route yourself. To do so:

```dart
router.navigateTo(context, "/users/1234", transition: TransitionType.fadeIn);
```

## Parameters vs. Arguments

The `params` is a convenient way to pass simple data (in a `Map`) just using the route.

In addition (`/* since 1.5.0 */`), you can pass any object instance as argument. This is useful if you need to pass more complex data.

```dart
// where `User` is defined class
var userModel = User(id: 1234, name: 'demo');

// using Fluro router
router.navigateTo(context, "/users/1234?action=edit", arguments: userModel);

// alternatively, you can still use the Navigator
Navigator.of(context).pushNamed("/users/1234?action=edit", arguments: userModel);
```


<hr/>
Fluro is a Yakka original.
<br/>
<a href="https://theyakka.com" target="_yakka">
<img src="https://storage.googleapis.com/yakka-logos/logo_wordmark.png"
  width="60"></a>
