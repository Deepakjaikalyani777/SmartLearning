// main.dart — the app's ENTRY POINT.
//
// Android equivalent: the Application class + the LAUNCHER activity declared
// in AndroidManifest.xml. Flutter has exactly ONE native Activity
// (MainActivity / FlutterActivity); every "screen" after that is a Widget.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/services/storage_service.dart';
import 'state/cart_provider.dart';
import 'state/theme_provider.dart';

Future<void> main() async {
  // Needed before using plugins (SharedPreferences etc.) prior to runApp().
  // ≈ making sure Application.onCreate() has a Context ready.
  WidgetsFlutterBinding.ensureInitialized();

  final storage = await StorageService.create();

  runApp(
    // MultiProvider ≈ a DI container (Hilt/Koin) that exposes app-wide
    // objects (ViewModels / singletons) to every screen below it.
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storage),
        ChangeNotifierProvider(create: (_) => ThemeProvider(storage)),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const FlutterLearningApp(),
    ),
  );
}
