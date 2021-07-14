[English](./README.md) | [Português](./translations/pt/README.md) | [简体中文](./translations/zh-CN/README.md)

<img src="https://storage.googleapis.com/product-logos/logo_fluro.png" width="220">
<br/><br/>

The brightest, hippest, coolest router for Flutter.


[![Version](https://img.shields.io/github/v/release/lukepighetti/fluro?label=version)](https://pub.dev/packages/fluro)
[![Build Status](https://github.com/lukepighetti/fluro/workflows/build/badge.svg)](https://github.com/lukepighetti/fluro/actions)

## 特性

- 易于使用的导航控制
- 函数处理器 （映射到函数而不是路由）
- 通配符参数匹配
- 查询字符串参数解析
- 内置常见的过渡效果
- 创建简单的自定义过度效果
- 跟随 `stable` Flutter 发布通道
- 空安全 (Null-safety)

## 示例项目

在 `example` 目录有一个非常好的示例项目可以参阅，或者看下面的介绍。

## 入门指南

首先，您应该通过如下方式初始化一个新的 `FluroRouter` 对象：

```dart
final router = FluroRouter();
```

您可以 全局/静态 地存储路由控制器，这样你就可以方便的在你的应用程序的其他区域访问路由。

在实例化路由控制器之后，你需要定义你的路由和路由处理程序：

```dart
var usersHandler = Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return UsersScreen(params["id"][0]);
});

void defineRoutes(FluroRouter router) {
  router.define("/users/:id", handler: usersHandler);

  // 可以选择定义需要使用的路由过渡
  // router.define("users/:id", handler: usersHandler, transitionType: TransitionType.inFromLeft);
}
```

在上面的例子中，路由控制器将拦截一个路由，如 `/users/1234` ，并将应用程序路由到 `UsersScreen` ，并将 `1234` 作为参数传给该屏幕。

## 导航 (Navigating)

你可以通过 `MaterialApp.onGenerateRoute` 参数来使用 `FluroRouter` ，通过 `FluroRouter.generator`。


你可以将 `FluroRouter` 传递给 `MaterialApp.onGenerateRoute` 参数，通过 `FluroRouter.generator`。
要做到这一点，将函数引用传递给 `onGenerate` 参数。如：`onGenerateRoute: router.generator`。

然后你可以使用`Navigator.push`，Flutter路由机制将为您匹配路由。

你也可以手动推送到一个路由，例如：

```dart
router.navigateTo(context, "/users/1234", transition: TransitionType.fadeIn);
```

## 类参数 (Class arguments)

如果你不想在参数中使用字符串，不用担心。

使用自定义 `RouteSettings` 推送路由后，您可以使用 `BuildContext.settings` 扩展来提取设置。 通常，这将在 `Handler.handlerFunc` 中完成，因此您可以将 `RouteSettings.arguments` 传递给您的 `Widget`。

```dart
/// 如果您不想使用路径参数，请使用自定义 RouteSettings 推送路由
FluroRouter.appRouter.navigateTo(
  context,
  'home',
  routeSettings: RouteSettings(
    arguments: MyArgumentsDataClass('foo!'),
  ),
);

/// 使用 [BuildContext.settings.arguments] 或 [BuildContext.arguments] 作为简称的提取参数
var homeHandler = Handler(
  handlerFunc: (context, params) {
    final args = context.settings.arguments as MyArgumentsDataClass;

    return HomeComponent(args);
  },
);
```
