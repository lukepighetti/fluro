import 'package:example/view/fluro_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  group('FluroView', () {
    testWidgets('mounts and builds a tree', (WidgetTester tester) async {
      final rootKey = GlobalKey<FluroViewState>();
      final branch1Key = GlobalKey<FluroViewState>();
      final branch2Key = GlobalKey<FluroViewState>();
      final leafKey = GlobalKey<FluroViewState>();

      /// Build `root` view
      await tester.pumpWidget(MaterialApp(
        home: FluroView(key: rootKey, name: 'root'),
      ));
      await tester.pumpAndSettle();
      final rootState = rootKey.currentState!;

      /// `root` descendents and pages are empty
      expect(rootState.descendents, isEmpty);
      expect(rootState.pages, isEmpty);

      /// Add pages
      rootState.updatePages([
        MaterialPage(child: FluroView(key: branch1Key, name: 'branch-one')),
        MaterialPage(child: FluroView(key: branch2Key, name: 'branch-two')),
      ]);

      await tester.pumpAndSettle();
      final branch1State = branch1Key.currentState!;
      final branch2State = branch2Key.currentState!;
      branch1State.updatePages([
        MaterialPage(child: FluroView(key: leafKey, name: 'leaf')),
      ]);

      await tester.pumpAndSettle();
      final leafState = leafKey.currentState!;

      /// All views are mounted
      expect(rootState.mounted, isTrue);
      expect(branch1State.mounted, isTrue);
      expect(branch2State.mounted, isTrue);
      expect(leafState.mounted, isTrue);

      /// Root contains both branches, branch 1 contains leaf
      expect(rootState.descendents, containsAll([branch1State, branch2State]));
      expect(branch1State.descendents, containsAll([leafState]));
      expect(branch2State.descendents, isEmpty);
      expect(leafState.descendents, isEmpty);

      /// Dispose of leaf
      branch1State.updatePages([]);
      await tester.pumpAndSettle();
      expect(leafState.mounted, isFalse);

      /// Prune branch 1
      expect(branch1State.descendents, containsAll([leafState]));
      branch1State.pruneDescendents();
      expect(branch1State.descendents, isEmpty);

      /// Dispose of branch 1, branch 2
      rootState.updatePages([]);
      await tester.pumpAndSettle();
      expect(branch1State.mounted, isFalse);
      expect(branch2State.mounted, isFalse);

      /// Prune root
      expect(rootState.descendents, containsAll([branch1State, branch2State]));
      rootState.pruneDescendents();
      expect(rootState.descendents, isEmpty);
    });
  });
}
