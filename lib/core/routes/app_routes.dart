// app_routes.dart — every "screen" of the app is registered here.
//
// Android equivalent: the list of <activity> entries in AndroidManifest.xml
// plus the Intents used to start them. Route arguments ≈ Intent extras.
import 'package:flutter/material.dart';

import '../../features/components/animations_demo.dart';
import '../../features/components/background_demo.dart';
import '../../features/components/dialogs_demo.dart';
import '../../features/components/forms_demo.dart';
import '../../features/components/layouts_demo.dart';
import '../../features/components/lifecycle_demo.dart';
import '../../features/components/lists_demo.dart';
import '../../features/components/navigation_demo.dart';
import '../../features/components/network_demo.dart';
import '../../features/components/platform_channel_demo.dart';
import '../../features/components/state_demo.dart';
import '../../features/components/storage_demo.dart';
import '../../features/components/streams_demo.dart';
import '../../features/home/home_shell.dart';
import '../../features/learn/concept_detail_screen.dart';
import '../../features/learn/concepts_data.dart';

class AppRoutes {
  AppRoutes._();

  static const home = '/';
  static const conceptDetail = '/concept';
  static const layouts = '/components/layouts';
  static const lists = '/components/lists';
  static const navigation = '/components/navigation';
  static const navigationDetail = '/components/navigation/detail';
  static const forms = '/components/forms';
  static const dialogs = '/components/dialogs';
  static const network = '/components/network';
  static const storage = '/components/storage';
  static const state = '/components/state';
  static const streams = '/components/streams';
  static const lifecycle = '/components/lifecycle';
  static const background = '/components/background';
  static const animations = '/components/animations';
  static const platformChannel = '/components/platform-channel';

  /// Central route factory ≈ resolving an explicit Intent to an Activity.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Widget page = switch (settings.name) {
      home => const HomeShell(),
      conceptDetail => ConceptDetailScreen(
          concept: settings.arguments! as Concept, // ≈ intent.getParcelableExtra()
        ),
      layouts => const LayoutsDemo(),
      lists => const ListsDemo(),
      navigation => const NavigationDemo(),
      navigationDetail => NavigationDetailPage(
          message: settings.arguments as String? ?? '(no extras)',
        ),
      forms => const FormsDemo(),
      dialogs => const DialogsDemo(),
      network => const NetworkDemo(),
      storage => const StorageDemo(),
      state => const StateDemo(),
      streams => const StreamsDemo(),
      lifecycle => const LifecycleDemo(),
      background => const BackgroundDemo(),
      animations => const AnimationsDemo(),
      platformChannel => const PlatformChannelDemo(),
      _ => const _UnknownRoute(),
    };
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}

class _UnknownRoute extends StatelessWidget {
  const _UnknownRoute();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Not found')),
        body: const Center(child: Text('ActivityNotFoundException 😅')),
      );
}
