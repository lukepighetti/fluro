# Router

## Getting started
 
 You should ensure that you add the router as a dependency in your flutter project. 
 Currently, you will need to add the git repo directly. A submitted pub package will
 be available soon.
 
 To add the dependency directly:
 
 ```yaml
dependencies:
  router:
    git: git://github.com/goposse/flutter-router.git
```
You should then run `pub update` or update your packages in IntelliJ.

## Setting up

First, you should define a new `Router` object by initializing it as such:  
```dart
final Router router = new Router();
```
It may be convenient for you to store the router globally/statically so that
you can access the router in other areas in your application.

After instantiating the router, you will need to define your routes and your route handlers:
```dart
RouteHandler usersHandler = (Map<String, String> params) {
  return new UsersScreen(params["id"]);
};

void defineRoutes(Router router) {
  router.define("/users/:id", handler: usersHandler);
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
router.navigateTo(context, "/users/1234");
```