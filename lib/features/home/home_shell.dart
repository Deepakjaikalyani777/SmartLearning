// HomeShell — the app's main frame: BottomNavigation + Drawer + tabs.
//
// Android equivalent: MainActivity hosting a BottomNavigationView +
// NavigationDrawer that swaps Fragments. In Flutter the "fragments" are just
// widgets kept alive inside an IndexedStack.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/cart_provider.dart';
import '../components/components_screen.dart';
import '../learn/learn_screen.dart';
import '../settings/settings_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _titles = ['Learn Flutter', 'Components Playground', 'Settings'];

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().count;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          // Badge on the toolbar ≈ menu item with a counter ActionView.
          IconButton(
            tooltip: 'Cart (shared state demo)',
            onPressed: () =>
                Navigator.pushNamed(context, '/components/state'),
            icon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
          ),
        ],
      ),
      drawer: _AppDrawer(
        selected: _index,
        onSelect: (i) {
          Navigator.pop(context); // close drawer ≈ drawerLayout.closeDrawers()
          setState(() => _index = i);
        },
      ),
      // IndexedStack keeps every tab alive ≈ FragmentTransaction.hide/show
      body: IndexedStack(
        index: _index,
        children: const [
          LearnScreen(),
          ComponentsScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.school_outlined),
              selectedIcon: Icon(Icons.school),
              label: 'Learn'),
          NavigationDestination(
              icon: Icon(Icons.widgets_outlined),
              selectedIcon: Icon(Icons.widgets),
              label: 'Components'),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings'),
        ],
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({required this.selected, required this.onSelect});

  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return NavigationDrawer(
      selectedIndex: selected,
      onDestinationSelected: onSelect,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [scheme.primary, scheme.tertiary],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.flutter_dash, size: 48, color: scheme.onPrimary),
              const SizedBox(height: 8),
              Text(
                'Flutter for Android Devs',
                style: TextStyle(
                  color: scheme.onPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const NavigationDrawerDestination(
            icon: Icon(Icons.school_outlined), label: Text('Learn concepts')),
        const NavigationDrawerDestination(
            icon: Icon(Icons.widgets_outlined), label: Text('Components')),
        const NavigationDrawerDestination(
            icon: Icon(Icons.settings_outlined), label: Text('Settings')),
      ],
    );
  }
}
