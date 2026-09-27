// Animations playground: implicit, cross-fade, switcher, staggered,
// Hero (shared element) and a custom page transition.
import 'package:flutter/material.dart';

import '../../widgets/demo_scaffold.dart';

class AnimationsDemo extends StatefulWidget {
  const AnimationsDemo({super.key});
  @override
  State<AnimationsDemo> createState() => _AnimationsDemoState();
}

class _AnimationsDemoState extends State<AnimationsDemo>
    with SingleTickerProviderStateMixin {
  bool _visible = true;
  bool _first = true;
  int _count = 0;
  double _turns = 0;

  late final AnimationController _stagger = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  @override
  void dispose() {
    _stagger.dispose();
    super.dispose();
  }

  void _openHero() {
    // PageRouteBuilder ≈ overridePendingTransition / custom Activity anims
    Navigator.of(context).push(PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (_, __, ___) => const _HeroDetail(),
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DemoScaffold(
      title: 'Animations',
      android: 'ViewPropertyAnimator · ObjectAnimator · TransitionManager · '
          'shared element transitions',
      flutter: 'AnimatedOpacity · AnimatedCrossFade · AnimatedSwitcher · '
          'AnimationController · Hero',
      children: [
        const SectionTitle('AnimatedOpacity (≈ view.animate().alpha())'),
        Row(
          children: [
            AnimatedOpacity(
              opacity: _visible ? 1 : 0,
              duration: const Duration(milliseconds: 500),
              child: const FlutterLogo(size: 60),
            ),
            const Spacer(),
            FilledButton.tonal(
              onPressed: () => setState(() => _visible = !_visible),
              child: const Text('Fade'),
            ),
          ],
        ),
        const SectionTitle('AnimatedRotation'),
        Row(
          children: [
            AnimatedRotation(
              turns: _turns,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutBack,
              child: Icon(Icons.settings, size: 60, color: scheme.primary),
            ),
            const Spacer(),
            FilledButton.tonal(
              onPressed: () => setState(() => _turns += 0.25),
              child: const Text('Rotate 90°'),
            ),
          ],
        ),
        const SectionTitle('AnimatedCrossFade (≈ TransitionManager)'),
        GestureDetector(
          onTap: () => setState(() => _first = !_first),
          child: AnimatedCrossFade(
            duration: const Duration(milliseconds: 400),
            crossFadeState:
                _first ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Container(
              height: 80,
              color: Colors.orange.shade300,
              alignment: Alignment.center,
              child: const Text('Tap me (collapsed)'),
            ),
            secondChild: Container(
              height: 140,
              color: Colors.teal.shade300,
              alignment: Alignment.center,
              child: const Text('Expanded! Tap again'),
            ),
          ),
        ),
        const SectionTitle('AnimatedSwitcher (≈ TextSwitcher)'),
        Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => SlideTransition(
                position: Tween(
                        begin: const Offset(0, 1), end: Offset.zero)
                    .animate(anim),
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Text('$_count',
                  key: ValueKey(_count),
                  style: Theme.of(context).textTheme.displaySmall),
            ),
            const Spacer(),
            FilledButton.tonal(
              onPressed: () => setState(() => _count++),
              child: const Text('+1'),
            ),
          ],
        ),
        const SectionTitle('Staggered (Interval curves ≈ AnimatorSet)'),
        AnimatedBuilder(
          animation: _stagger,
          builder: (context, _) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var i = 0; i < 5; i++)
                Builder(builder: (context) {
                  final t = CurvedAnimation(
                    parent: _stagger,
                    curve: Interval(i * 0.12, 0.5 + i * 0.1,
                        curve: Curves.elasticOut),
                  ).value;
                  return Transform.scale(
                    scale: t,
                    child: CircleAvatar(
                      backgroundColor: Colors.primaries[i * 3],
                      child: Text('${i + 1}'),
                    ),
                  );
                }),
            ],
          ),
        ),
        const SizedBox(height: 8),
        FilledButton.tonal(
          onPressed: () => _stagger.forward(from: 0),
          child: const Text('Play staggered'),
        ),
        const SectionTitle('Hero (≈ shared element transition)'),
        GestureDetector(
          onTap: _openHero,
          child: Row(
            children: [
              Hero(
                tag: 'hero-photo',
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    gradient: const LinearGradient(
                      colors: [Colors.purple, Colors.blue],
                    ),
                  ),
                  child: const Icon(Icons.landscape,
                      color: Colors.white, size: 40),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(child: Text('Tap the circle to fly into a new '
                  'screen')),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroDetail extends StatelessWidget {
  const _HeroDetail();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hero detail')),
      body: Column(
        children: [
          Hero(
            tag: 'hero-photo', // same tag = same "transitionName"
            child: Container(
              height: 260,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Colors.purple, Colors.blue]),
              ),
              child: const Icon(Icons.landscape, color: Colors.white, size: 120),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('Same Hero tag on both screens ≈ '
                'android:transitionName + '
                'ActivityOptions.makeSceneTransitionAnimation()'),
          ),
        ],
      ),
    );
  }
}
