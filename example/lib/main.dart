import 'package:example/fluro.dart';
import 'package:example/routing/fluro_route.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Fluro 2',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routeInformationParser: FluroRouteInformationParser(),
      routerDelegate: FluroRouterDelegate(
        children: [
          /// `/`
          FluroRoute(
            '/',
            page: _stubPage('/'),
          ),

          /// `/foo`
          FluroRoute(
            '/foo',
            page: _stubPage('/foo'),
            children: [
              /// `/foo/nested`
              FluroRoute(
                '/nested',
                page: _stubPage('/nested'),
              ),
            ],
          ),

          /// `/bar`
          FluroRoute(
            '/bar',
            page: _stubPage('/bar'),
          ),
        ],
      ),
    );
  }
}

/// Just a super quick way to make a [MaterialPage]
Page _stubPage(String text) {
  return MaterialPage(
    child: Scaffold(
      body: Center(
        child: Text(text),
      ),
    ),
  );
}

/// A semantically odd way to make a [MaterialPage]
class MyPage extends MaterialPage {
  MyPage(String text)
      : super(
          child: Scaffold(
            body: Center(
              child: Text(text),
            ),
          ),
        );
}

/// A naiive way to make custom pages.
class MyPage2 extends Page<bool> {
  @override
  Route<bool> createRoute(BuildContext context) {
    return PageRouteBuilder(
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return Scaffold(
          body: Center(
            child: Text('MyPage2'),
          ),
        );
      },
    );
  }
}
