// Settings: theme mode persisted to SharedPreferences through ThemeProvider.
// ≈ PreferenceFragmentCompat + AppCompatDelegate.setDefaultNightMode().
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final size = MediaQuery.sizeOf(context);
    final dpr = MediaQuery.devicePixelRatioOf(context);

    return ListView(
      children: [
        const ListTile(
          title: Text('Appearance'),
          subtitle: Text('≈ AppCompatDelegate.setDefaultNightMode()'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.brightness_auto),
                  label: Text('System')),
              ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode),
                  label: Text('Light')),
              ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode),
                  label: Text('Dark')),
            ],
            selected: {theme.themeMode},
            onSelectionChanged: (s) =>
                context.read<ThemeProvider>().setMode(s.first),
          ),
        ),
        const Divider(height: 32),
        const ListTile(title: Text('Device & build info')),
        ListTile(
          leading: const Icon(Icons.aspect_ratio),
          title: const Text('Screen size (logical px ≈ dp)'),
          subtitle: Text('${size.width.toStringAsFixed(0)} × '
              '${size.height.toStringAsFixed(0)}  ·  density $dpr'),
        ),
        const ListTile(
          leading: Icon(Icons.build_outlined),
          title: Text('Build mode (≈ BuildConfig.DEBUG)'),
          subtitle: Text(kReleaseMode
              ? 'release'
              : kProfileMode
                  ? 'profile'
                  : 'debug'),
        ),
        ListTile(
          leading: const Icon(Icons.devices),
          title: const Text('Platform'),
          subtitle: Text(defaultTargetPlatform.name),
        ),
        const Divider(height: 32),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('About & open-source licenses'),
          subtitle: const Text('≈ OssLicensesMenuActivity'),
          onTap: () => showAboutDialog(
            context: context,
            applicationName: 'Flutter for Android Devs',
            applicationVersion: '1.0.0 (1)',
            applicationIcon: const FlutterLogo(size: 40),
            children: const [
              Text('A learn-by-example app. See the docs/ folder for the '
                  'PDF guides.'),
            ],
          ),
        ),
      ],
    );
  }
}
