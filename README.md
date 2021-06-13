[English](./README.md) | [Português](./translations/pt/README.md)

<img src="https://storage.googleapis.com/product-logos/logo_fluro.png" width="220">
<br/><br/>

The brightest, hippest, coolest router for Flutter.

[![Version](https://img.shields.io/github/v/release/lukepighetti/fluro?label=version)](https://pub.dev/packages/fluro)
[![Build Status](https://github.com/lukepighetti/fluro/workflows/build/badge.svg)](https://github.com/lukepighetti/fluro/actions)

## Features

- Simple route navigation
- Function handlers (map to a function instead of a route)
- Wildcard parameter matching
- Querystring parameter parsing
- Common transitions built-in
- Simple custom transition creation
- Follows `stable` Flutter channel
- Null-safety

## Example Project

There is a pretty sweet example project in the `example` folder. Check it out. Otherwise, keep reading to get up and running.

## Getting started

First, you should define a new `FluroRouter` object by initializing it as such:

```dart
final router = FluroRouter();
```

It may be convenient for you to store the router globally/statically so that
you can access the router in other areas in your application.

After instantiating the router, you will need to define your routes and your route handlers:

```dart
var usersHandler = Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return UsersScreen(params["id"][0]);
});

void defineRoutes(FluroRouter router) {
  router.define("/users/:id", handler: usersHandler);

  // it is also possible to define the route transition to use
  // router.define("users/:id", handler: usersHandler, transitionType: TransitionType.inFromLeft);
}
```

In the above example, the router will intercept a route such as
`/users/1234` and route the application to the `UsersScreen` passing
the value `1234` as a parameter to that screen.

## Navigating

You can use `FluroRouter` with the `MaterialApp.onGenerateRoute` parameter
via `FluroRouter.generator`. To do so, pass the function reference to
the `onGenerate` parameter like: `onGenerateRoute: router.generator`.

You can then use `Navigator.push` and the flutter routing mechanism will match the routes
for you.

You can also manually push to a route yourself. To do so:

```dart
router.navigateTo(context, "/users/1234", transition: TransitionType.fadeIn);
```

## Class arguments

Don't want to use strings for params? No worries.

After pushing a route with a custom `RouteSettings` you can use the `BuildContext.settings` extension to extract the settings. Typically this would be done in `Handler.handlerFunc` so you can pass `RouteSettings.arguments` to your screen widgets.

```dart
/// Push a route with custom RouteSettings if you don't want to use path params
FluroRouter.appRouter.navigateTo(
  context,
  'home',
  routeSettings: RouteSettings(
    arguments: MyArgumentsDataClass('foo!'),
  ),
);

/// Extract the arguments using [BuildContext.settings.arguments] or [BuildContext.arguments] for short
var homeHandler = Handler(
  handlerFunc: (context, params) {
    final args = context.settings.arguments as MyArgumentsDataClass;

    return HomeComponent(args);
  },
);
```
