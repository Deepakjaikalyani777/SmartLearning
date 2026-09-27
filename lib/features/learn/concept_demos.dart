// Maps each DemoKind to its animated explainer widget.
import 'package:flutter/material.dart';

import 'concepts_data.dart';
import 'demos/async_demos.dart';
import 'demos/basics_demos.dart';
import 'demos/tooling_demos.dart';
import 'demos/ui_demos.dart';

class ConceptDemo extends StatelessWidget {
  const ConceptDemo({super.key, required this.kind});

  final DemoKind kind;

  @override
  Widget build(BuildContext context) => switch (kind) {
        DemoKind.widgetTree => const WidgetTreeDemo(),
        DemoKind.statelessVsStateful => const StatefulRebuildDemo(),
        DemoKind.lifecycle => const LifecycleStepperDemo(),
        DemoKind.appLifecycle => const AppLifecycleStatesDemo(),
        DemoKind.layouts => const LayoutPlaygroundDemo(),
        DemoKind.lists => const RecyclingListDemo(),
        DemoKind.navigation => const BackStackDemo(),
        DemoKind.stateManagement => const NotifyListenersDemo(),
        DemoKind.async => const EventLoopDemo(),
        DemoKind.isolates => const IsolateJankDemo(),
        DemoKind.platformChannel => const ChannelMessageDemo(),
        DemoKind.animations => const ImplicitExplicitDemo(),
        DemoKind.theming => const ThemePreviewDemo(),
        DemoKind.hotReload => const HotReloadRaceDemo(),
        DemoKind.threeTrees => const ThreeTreesDemo(),
        DemoKind.buildModes => const BuildModesDemo(),
      };
}

/// Shared frame for demo panels.
class DemoPanel extends StatelessWidget {
  const DemoPanel({super.key, required this.child, this.caption});

  final Widget child;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Material (not a coloured Container) so ListTile ink ripples
        // inside demos stay visible.
        Material(
          color: theme.colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
        if (caption != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(caption!,
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontStyle: FontStyle.italic)),
          ),
      ],
    );
  }
}
