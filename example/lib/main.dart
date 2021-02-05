import 'package:example/models/fluro_route.dart';
import 'package:example/view/fluro_provider.dart';
import 'package:example/view/fluro_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  // runApp(MyApp());
  runApp(TestMyApp());
}

class TestMyApp extends StatefulWidget {
  @override
  _TestMyAppState createState() => _TestMyAppState();
}

class _TestMyAppState extends State<TestMyApp> {
  final mainKey = GlobalKey<FluroViewState>();
  final subKey = GlobalKey<FluroViewState>();

  @override
  void initState() {
    asyncInitState();
    super.initState();
  }

  void asyncInitState() async {
    final pauseDuration = Duration(milliseconds: 500);

    await Future.delayed(pauseDuration);

    mainKey.currentState!.updatePages([
      MaterialPage(
        child: FluroView(
          key: subKey,
          name: 'Sub',
        ),
      ),
    ]);

    await Future.delayed(Duration(milliseconds: 100));

    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      subKey.currentState!.updatePages([stubPage('Weeee')]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FluroView(
        key: mainKey,
        name: 'Main',
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FluroProvider(
      fallbackPage: (context, params) => stubPage('Fallback page'),
      routes: [
        /// `/`
        FluroRoute(
          '/',
          page: (_, params) => stubPage('/'),
        ),

        /// `/foo`
        FluroRoute(
          '/foo',
          page: (_, params) => stubPage('/foo'),
          children: [
            /// `/foo/nested`
            FluroRoute(
              '/nested',
              page: (_, params) => stubPage('/nested'),
            ),
          ],
        ),

        /// `/bar`
        FluroRoute(
          '/bar',
          page: (_, params) => stubPage('/bar'),
        ),
      ],
      builder: (context, routeInformationParser, routerDelegate) {
        return MaterialApp.router(
          title: 'Fluro 2',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          routeInformationParser: routeInformationParser,
          routerDelegate: routerDelegate,
        );
      },
    );
  }
}

/// Just a super quick way to make a [MaterialPage]
Page stubPage(String text) {
  return MaterialPage(
    child: Scaffold(
      body: Center(
        child: Text(text),
      ),
    ),
  );
}
