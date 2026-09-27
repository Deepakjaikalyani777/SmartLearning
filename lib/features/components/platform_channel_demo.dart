// Platform channel demo: calls REAL Kotlin code in
// android/app/src/main/kotlin/.../MainActivity.kt
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/code_block.dart';
import '../../widgets/demo_scaffold.dart';

class PlatformChannelDemo extends StatefulWidget {
  const PlatformChannelDemo({super.key});
  @override
  State<PlatformChannelDemo> createState() => _PlatformChannelDemoState();
}

class _PlatformChannelDemoState extends State<PlatformChannelDemo> {
  // Channel name must match the Kotlin side exactly.
  static const _channel = MethodChannel('learn.flutter/device');

  String _battery = 'Tap to ask Android';
  String _device = '-';

  Future<void> _getBattery() async {
    try {
      final level = await _channel.invokeMethod<int>('getBatteryLevel');
      setState(() => _battery = '$level %');
    } on PlatformException catch (e) {
      setState(() => _battery = 'Native error: ${e.message}');
    } on MissingPluginException {
      setState(() => _battery =
          'No native handler (running on a platform without the Kotlin code)');
    }
  }

  Future<void> _getDevice() async {
    try {
      final info =
          await _channel.invokeMapMethod<String, dynamic>('getDeviceInfo');
      setState(() => _device = info?.entries
              .map((e) => '${e.key}: ${e.value}')
              .join('\n') ??
          '-');
    } on MissingPluginException {
      setState(() => _device = 'No native handler on this platform');
    } on PlatformException catch (e) {
      setState(() => _device = 'Native error: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Platform Channel',
      android: 'Calling Android SDK APIs (BatteryManager, Build) from Kotlin',
      flutter: 'MethodChannel.invokeMethod → Kotlin setMethodCallHandler',
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.battery_charging_full),
            title: const Text('Battery level'),
            subtitle: Text(_battery),
            trailing: FilledButton(
                onPressed: _getBattery, child: const Text('Ask')),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.phone_android),
            title: const Text('Device info (android.os.Build)'),
            subtitle: Text(_device),
            trailing:
                FilledButton(onPressed: _getDevice, child: const Text('Ask')),
          ),
        ),
        const SectionTitle('Dart side'),
        const CodeBlock('''
const channel = MethodChannel('learn.flutter/device');
final level = await channel.invokeMethod<int>('getBatteryLevel');''',
            label: 'lib/features/components/platform_channel_demo.dart'),
        const SectionTitle('Kotlin side'),
        const CodeBlock('''
class MainActivity : FlutterActivity() {
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger,
                  "learn.flutter/device")
      .setMethodCallHandler { call, result ->
        when (call.method) {
          "getBatteryLevel" -> result.success(batteryLevel())
          "getDeviceInfo"   -> result.success(mapOf(
              "model" to Build.MODEL, "sdk" to Build.VERSION.SDK_INT))
          else -> result.notImplemented()
        }
      }
  }
}''', label: 'android/app/src/main/kotlin/.../MainActivity.kt'),
      ],
    );
  }
}
