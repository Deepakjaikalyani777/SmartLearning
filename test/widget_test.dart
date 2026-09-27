// Widget tests ≈ Espresso / Robolectric UI tests, but run on the JVM-less
// Dart VM in milliseconds. Run with: flutter test
import 'package:flutter/material.dart';
import 'package:flutter_learning_app/app.dart';
import 'package:flutter_learning_app/data/services/storage_service.dart';
import 'package:flutter_learning_app/features/learn/concepts_data.dart';
import 'package:flutter_learning_app/state/cart_provider.dart';
import 'package:flutter_learning_app/state/theme_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> pumpApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({}); // ≈ a fake/in-memory prefs
  final storage = await StorageService.create();
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storage),
        ChangeNotifierProvider(create: (_) => ThemeProvider(storage)),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const FlutterLearningApp(),
    ),
  );
  await tester.pumpAndSettle();
}

/// Pumps frames for a while. Unlike pumpAndSettle this doesn't hang on
/// never-ending animations (spinners, repeating controllers).
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('Home shows Learn tab with concepts', (tester) async {
    await pumpApp(tester);
    expect(find.text('Learn Flutter'), findsOneWidget);
    expect(find.text(concepts.first.title), findsOneWidget);
  });

  testWidgets('Bottom navigation switches to Components', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Components'));
    await tester.pumpAndSettle();
    expect(find.text('Components Playground'), findsOneWidget);
    expect(find.text('Layouts'), findsOneWidget);
  });

  testWidgets('Every concept detail screen and demo builds', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);
    await pumpApp(tester);

    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    for (final c in concepts) {
      nav.pushNamed('/concept', arguments: c);
      await settle(tester);
      expect(find.text(c.title), findsWidgets);

      // Open the "Animate" tab to build the demo, then "Compare".
      await tester.tap(find.text('Animate'));
      await settle(tester);
      await tester.tap(find.text('Compare'));
      await settle(tester);

      nav.pop();
      await settle(tester);
    }
  });

  testWidgets('Every component demo route builds', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);
    await pumpApp(tester);

    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    const routes = [
      '/components/layouts',
      '/components/lists',
      '/components/navigation',
      '/components/forms',
      '/components/dialogs',
      '/components/network',
      '/components/storage',
      '/components/streams',
      '/components/state',
      '/components/lifecycle',
      '/components/background',
      '/components/animations',
      '/components/platform-channel',
    ];
    for (final r in routes) {
      nav.pushNamed(r);
      await settle(tester);
      expect(tester.takeException(), isNull, reason: r);
      nav.pop();
      await settle(tester);
    }
  });

  test('CartProvider totals and notifies', () {
    final cart = CartProvider();
    var notified = 0;
    cart.addListener(() => notified++);
    cart.add(const CartItem('A', 2));
    cart.add(const CartItem('B', 3.5));
    expect(cart.count, 2);
    expect(cart.total, 5.5);
    expect(notified, 2);
  });

  testWidgets('Adding to cart updates the home badge', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byIcon(Icons.shopping_cart_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add_shopping_cart).first);
    await tester.pump();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('1'), findsWidgets);
  });
}
