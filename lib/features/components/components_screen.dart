// ComponentsScreen — grid of hands-on demos.
// ≈ a Fragment with a RecyclerView + GridLayoutManager.
import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';

class _Item {
  const _Item(this.title, this.android, this.icon, this.route);
  final String title;
  final String android;
  final IconData icon;
  final String route;
}

const _items = [
  _Item('Layouts', 'LinearLayout, FrameLayout', Icons.dashboard_outlined,
      AppRoutes.layouts),
  _Item('Lists & Grids', 'RecyclerView', Icons.list_alt, AppRoutes.lists),
  _Item('Navigation', 'Activities & Intents', Icons.alt_route,
      AppRoutes.navigation),
  _Item('Forms & Inputs', 'EditText, CheckBox…', Icons.edit_note,
      AppRoutes.forms),
  _Item('Dialogs & Feedback', 'AlertDialog, Toast', Icons.chat_bubble_outline,
      AppRoutes.dialogs),
  _Item('Networking', 'Retrofit + OkHttp', Icons.cloud_download_outlined,
      AppRoutes.network),
  _Item('Local Storage', 'SharedPreferences', Icons.save_outlined,
      AppRoutes.storage),
  _Item('State (Provider)', 'ViewModel + LiveData', Icons.hub_outlined,
      AppRoutes.state),
  _Item('Streams', 'Flow / LiveData', Icons.waves, AppRoutes.streams),
  _Item('Lifecycle', 'Activity lifecycle', Icons.autorenew,
      AppRoutes.lifecycle),
  _Item('Background Work', 'Threads / Services', Icons.memory,
      AppRoutes.background),
  _Item('Animations', 'Animators, transitions', Icons.animation,
      AppRoutes.animations),
  _Item('Platform Channel', 'Native Kotlin APIs', Icons.settings_input_component,
      AppRoutes.platformChannel),
];

class ComponentsScreen extends StatelessWidget {
  const ComponentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      // ≈ GridLayoutManager with a span based on screen width
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.05,
      ),
      itemCount: _items.length,
      itemBuilder: (context, i) {
        final item = _items[i];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            // InkWell = ripple ≈ ?attr/selectableItemBackground
            onTap: () => Navigator.pushNamed(context, item.route),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: scheme.secondaryContainer,
                    child: Icon(item.icon, color: scheme.onSecondaryContainer),
                  ),
                  const Spacer(),
                  Text(item.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.android,
                          size: 14, color: Color(0xFF3DDC84)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(item.android,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
