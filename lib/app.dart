// app.dart — root widget. ≈ <application> tag in AndroidManifest.xml:
// app theme, app label, and the list of "activities" (routes).
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'state/theme_provider.dart';

class FlutterLearningApp extends StatelessWidget {
  const FlutterLearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    // context.watch = observe LiveData; rebuilds when theme changes.
    final themeMode = context.watch<ThemeProvider>().themeMode;

    return MaterialApp(
      title: 'Flutter for Android Devs', // ≈ android:label
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light, //             ≈ res/values/themes.xml
      darkTheme: AppTheme.dark, //          ≈ res/values-night/themes.xml
      themeMode: themeMode,
      initialRoute: AppRoutes.home, //      ≈ MAIN/LAUNCHER intent-filter
      onGenerateRoute: AppRoutes.onGenerateRoute, // ≈ Activity registry
    );
  }
}
