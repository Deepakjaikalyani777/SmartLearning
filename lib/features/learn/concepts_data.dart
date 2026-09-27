// concepts_data.dart — the teaching content of the "Learn" tab.
//
// Plain Dart objects kept in a const list ≈ a static JSON/strings resource.
import 'package:flutter/material.dart';

/// Which animated explainer to show on the concept detail screen.
enum DemoKind {
  widgetTree,
  statelessVsStateful,
  lifecycle,
  appLifecycle,
  layouts,
  lists,
  navigation,
  stateManagement,
  async,
  isolates,
  platformChannel,
  animations,
  theming,
  hotReload,
  threeTrees,
  buildModes,
}

class Concept {
  const Concept({
    required this.id,
    required this.title,
    required this.icon,
    required this.category,
    required this.androidTerm,
    required this.flutterTerm,
    required this.oneLiner,
    required this.explanation,
    required this.comparison,
    required this.flutterCode,
    required this.androidCode,
    required this.demo,
    required this.brainPower,
    required this.takeaways,
  });

  final String id;
  final String title;
  final IconData icon;
  final String category;
  final String androidTerm;
  final String flutterTerm;
  final String oneLiner;
  final List<String> explanation;

  /// Rows of (Android, Flutter) for the comparison table.
  final List<(String, String)> comparison;
  final String flutterCode;
  final String androidCode;
  final DemoKind demo;
  final String brainPower;
  final List<String> takeaways;
}

const conceptCategories = [
  'Basics',
  'UI',
  'Architecture',
  'Async & Platform',
  'Tooling',
];

const concepts = <Concept>[
  // ───────────────────────────── BASICS ─────────────────────────────
  Concept(
    id: 'widgets',
    title: 'Everything is a Widget',
    icon: Icons.account_tree_outlined,
    category: 'Basics',
    androidTerm: 'View / ViewGroup / XML layout',
    flutterTerm: 'Widget',
    oneLiner: "A Widget is an immutable DESCRIPTION of part of the UI - "
        "not the UI itself.",
    explanation: [
      "In Android you inflate XML into a tree of mutable View objects and then "
          "change them: textView.setText(...).",
      "In Flutter you never mutate the UI. You describe what the UI should "
          "look like for the current state, and Flutter figures out what "
          "changed. Widgets are cheap, immutable, throw-away objects.",
      "Padding, centering, gestures, themes, even the app itself - all are "
          "widgets. There is no separate XML: layout IS code.",
    ],
    comparison: [
      ('activity_main.xml', 'build() method'),
      ('TextView', 'Text'),
      ('ImageView', 'Image'),
      ('Button / MaterialButton', 'ElevatedButton / FilledButton'),
      ('EditText', 'TextField'),
      ('android:padding', 'Padding widget'),
      ('View.GONE', "if (show) Widget  (just don't build it)"),
      ('findViewById / ViewBinding', 'Not needed - no view lookups'),
    ],
    flutterCode: r'''
class Greeting extends StatelessWidget {
  const Greeting({super.key, required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text('Hello $name'),
    );
  }
}''',
    androidCode: r'''
<!-- res/layout/greeting.xml -->
<TextView
    android:id="@+id/greeting"
    android:padding="16dp"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"/>

// Activity
binding.greeting.text = "Hello $name"''',
    demo: DemoKind.widgetTree,
    brainPower: "If widgets are immutable, how does the screen ever change? "
        "(Hint: who creates a NEW widget when data changes?)",
    takeaways: [
      'Widgets are blueprints, not views.',
      'Composition over inheritance: wrap widgets in widgets.',
      'No XML, no findViewById.',
    ],
  ),
  Concept(
    id: 'stateless_stateful',
    title: 'Stateless vs Stateful',
    icon: Icons.toggle_on_outlined,
    category: 'Basics',
    androidTerm: 'Static layout vs View with mutable fields',
    flutterTerm: 'StatelessWidget / StatefulWidget + setState()',
    oneLiner: "StatelessWidget = pure function of its inputs. StatefulWidget = "
        "has a State object that survives rebuilds.",
    explanation: [
      "StatelessWidget: everything it needs comes from its constructor. "
          "Think of a TextView that only ever shows a label.",
      "StatefulWidget: split into two classes. The widget (immutable config) "
          "and a State<T> object (mutable, long-lived). The State object is "
          "kept by the framework across rebuilds.",
      "Calling setState(() { ... }) marks the widget dirty; on the next frame "
          "build() runs again and the UI updates. It's like calling "
          "invalidate() - but for the whole subtree description.",
    ],
    comparison: [
      ('textView.setText(); view.invalidate()', 'setState(() => count++)'),
      ('Fields in Activity', 'Fields in State<T>'),
      ('onSaveInstanceState', 'RestorationMixin (optional)'),
      ('Custom View with attrs', 'StatelessWidget with constructor params'),
    ],
    flutterCode: r'''
class Counter extends StatefulWidget {
  const Counter({super.key});
  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int _count = 0;

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: () => setState(() => _count++),
        child: Text('Tapped $_count times'),
      );
}''',
    androidCode: r'''
private var count = 0

button.setOnClickListener {
    count++
    button.text = "Tapped $count times"
}''',
    demo: DemoKind.statelessVsStateful,
    brainPower: "Why does Flutter keep the State object separate from the "
        "Widget, instead of putting 'count' in the widget itself?",
    takeaways: [
      'Default to StatelessWidget.',
      'setState() only for local, ephemeral UI state.',
      'Shared/business state belongs in a provider (ViewModel).',
    ],
  ),
  Concept(
    id: 'widget_lifecycle',
    title: 'Widget (State) Lifecycle',
    icon: Icons.autorenew,
    category: 'Basics',
    androidTerm: 'Activity / Fragment lifecycle',
    flutterTerm: 'State<T> lifecycle methods',
    oneLiner: "initState ≈ onCreate, build ≈ onCreateView (called MANY times), "
        "dispose ≈ onDestroy.",
    explanation: [
      "createState() - framework creates the State object.",
      "initState() - called ONCE. Subscribe to streams, create controllers. "
          "≈ onCreate().",
      "didChangeDependencies() - an InheritedWidget you depend on "
          "(Theme, MediaQuery, Provider) changed.",
      "build() - called whenever something changes. Must be fast and "
          "side-effect free.",
      "didUpdateWidget(old) - parent rebuilt you with new constructor args.",
      "deactivate() / dispose() - removed from tree; cancel timers, close "
          "streams, dispose controllers. ≈ onDestroy().",
    ],
    comparison: [
      ('onCreate()', 'initState()'),
      ('onCreateView()', 'build()'),
      ('onConfigurationChanged()', 'didChangeDependencies()'),
      ('Fragment.setArguments() change', 'didUpdateWidget()'),
      ('onDestroyView() / onDestroy()', 'deactivate() / dispose()'),
    ],
    flutterCode: r'''
class _MyState extends State<MyWidget> {
  late final StreamSubscription _sub;

  @override
  void initState() {            // ≈ onCreate
    super.initState();
    _sub = ticker.listen((_) => setState(() {}));
  }

  @override
  void dispose() {              // ≈ onDestroy
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const Placeholder();
}''',
    androidCode: r'''
override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    job = lifecycleScope.launch { ticker.collect { render() } }
}

override fun onDestroy() {
    job.cancel()
    super.onDestroy()
}''',
    demo: DemoKind.lifecycle,
    brainPower: "Rotation destroys an Android Activity. What happens to a "
        "Flutter State object on rotation?",
    takeaways: [
      'initState once, build many, dispose once.',
      'Never do heavy work in build().',
      'Always dispose controllers & subscriptions.',
    ],
  ),
  Concept(
    id: 'app_lifecycle',
    title: 'App Lifecycle',
    icon: Icons.phone_android,
    category: 'Basics',
    androidTerm: 'onResume / onPause / onStop / ProcessLifecycleOwner',
    flutterTerm: 'AppLifecycleListener / WidgetsBindingObserver',
    oneLiner: "Flutter reports the host Activity's lifecycle as "
        "AppLifecycleState values.",
    explanation: [
      "Since the whole Flutter app lives inside ONE FlutterActivity, app "
          "lifecycle = that Activity's lifecycle.",
      "resumed ≈ onResume (visible & focused). inactive ≈ losing focus "
          "(e.g. multi-window, incoming call overlay). hidden / paused ≈ "
          "onPause/onStop (in background). detached ≈ engine running without "
          "a view.",
      "Use AppLifecycleListener (or WidgetsBindingObserver) to pause video, "
          "save drafts, or lock sensitive screens when the app goes to background.",
    ],
    comparison: [
      ('onResume()', 'AppLifecycleState.resumed'),
      ('onPause() (loses focus)', 'AppLifecycleState.inactive'),
      ('onStop()', 'AppLifecycleState.hidden → paused'),
      ('onDestroy()', 'AppLifecycleState.detached'),
      ('ProcessLifecycleOwner', 'AppLifecycleListener'),
    ],
    flutterCode: r'''
late final AppLifecycleListener _listener;

@override
void initState() {
  super.initState();
  _listener = AppLifecycleListener(
    onResume: () => log('resumed'),
    onPause:  () => log('paused'),
    onStateChange: (s) => log('state: $s'),
  );
}

@override
void dispose() {
  _listener.dispose();
  super.dispose();
}''',
    androidCode: r'''
ProcessLifecycleOwner.get().lifecycle.addObserver(
  object : DefaultLifecycleObserver {
    override fun onResume(owner: LifecycleOwner) = log("resumed")
    override fun onPause(owner: LifecycleOwner)  = log("paused")
  })''',
    demo: DemoKind.appLifecycle,
    brainPower: "Your banking app must blur the screen in the Recents list. "
        "Which lifecycle state would you react to?",
    takeaways: [
      'One Activity hosts the whole Flutter app.',
      'Listen to AppLifecycleState for background/foreground.',
      'Try the Lifecycle demo in the Components tab!',
    ],
  ),
  // ───────────────────────────── UI ─────────────────────────────
  Concept(
    id: 'layouts',
    title: 'Layouts',
    icon: Icons.view_quilt_outlined,
    category: 'UI',
    androidTerm: 'LinearLayout / FrameLayout / ConstraintLayout',
    flutterTerm: 'Row / Column / Stack / Expanded / Wrap',
    oneLiner: "Constraints go DOWN, sizes go UP, parent sets position.",
    explanation: [
      "Row = horizontal LinearLayout. Column = vertical LinearLayout. "
          "Stack = FrameLayout (children drawn on top of each other).",
      "Expanded(flex: n) = layout_weight. SizedBox = fixed width/height. "
          "Padding = padding. Align/Center = gravity.",
      "mainAxisAlignment ≈ gravity along the orientation; "
          "crossAxisAlignment ≈ gravity across it.",
      "The golden rule: a parent passes constraints (min/max width/height) to "
          "its child, the child picks a size within them, and the parent "
          "decides where to place it.",
    ],
    comparison: [
      ('LinearLayout (horizontal)', 'Row'),
      ('LinearLayout (vertical)', 'Column'),
      ('FrameLayout', 'Stack + Positioned'),
      ('layout_weight', 'Expanded / Flexible'),
      ('ConstraintLayout', 'Stack / LayoutBuilder / CustomMultiChildLayout'),
      ('FlexboxLayout', 'Wrap'),
      ('ScrollView', 'SingleChildScrollView'),
      ('match_parent', 'double.infinity / Expanded'),
      ('wrap_content', 'default for most widgets (MainAxisSize.min)'),
    ],
    flutterCode: r'''
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    const Icon(Icons.star),
    Expanded(flex: 2, child: Text('Title')),
    Expanded(flex: 1, child: Text('Price')),
  ],
)''',
    androidCode: r'''
<LinearLayout android:orientation="horizontal"
    android:layout_width="match_parent"
    android:layout_height="wrap_content">
  <ImageView android:src="@drawable/star" .../>
  <TextView android:layout_width="0dp" android:layout_weight="2" .../>
  <TextView android:layout_width="0dp" android:layout_weight="1" .../>
</LinearLayout>''',
    demo: DemoKind.layouts,
    brainPower: "Why does putting a ListView inside a Column throw "
        "'Vertical viewport was given unbounded height'?",
    takeaways: [
      'Row/Column/Stack cover 90% of layouts.',
      'Expanded = layout_weight.',
      'Constraints down, sizes up.',
    ],
  ),
  Concept(
    id: 'lists',
    title: 'Lists & Grids',
    icon: Icons.view_list_outlined,
    category: 'UI',
    androidTerm: 'RecyclerView + Adapter + ViewHolder',
    flutterTerm: 'ListView.builder / GridView.builder',
    oneLiner: "ListView.builder IS a RecyclerView - without the Adapter "
        "boilerplate.",
    explanation: [
      "ListView.builder(itemCount, itemBuilder) lazily builds only the visible "
          "rows - exactly like RecyclerView recycling ViewHolders.",
      "itemBuilder ≈ onCreateViewHolder + onBindViewHolder merged into one "
          "function.",
      "No notifyDataSetChanged(): change the list, call setState (or notify "
          "your provider) and the list rebuilds efficiently.",
      "GridView ≈ GridLayoutManager. ListView.separated ≈ ItemDecoration. "
          "RefreshIndicator ≈ SwipeRefreshLayout. Dismissible ≈ ItemTouchHelper.",
    ],
    comparison: [
      ('RecyclerView', 'ListView.builder'),
      ('Adapter.onBindViewHolder', 'itemBuilder: (ctx, i) => ...'),
      ('GridLayoutManager', 'GridView.builder'),
      ('ItemDecoration (divider)', 'ListView.separated'),
      ('SwipeRefreshLayout', 'RefreshIndicator'),
      ('ItemTouchHelper swipe', 'Dismissible'),
      ('DiffUtil', 'Keys + efficient element diffing (automatic)'),
    ],
    flutterCode: r'''
ListView.builder(
  itemCount: posts.length,
  itemBuilder: (context, index) {
    final post = posts[index];
    return ListTile(
      title: Text(post.title),
      onTap: () => open(post),
    );
  },
)''',
    androidCode: r'''
class PostAdapter(val posts: List<Post>) :
    RecyclerView.Adapter<PostAdapter.VH>() {
  class VH(val b: ItemPostBinding) : RecyclerView.ViewHolder(b.root)
  override fun onCreateViewHolder(p: ViewGroup, t: Int) =
      VH(ItemPostBinding.inflate(LayoutInflater.from(p.context), p, false))
  override fun onBindViewHolder(h: VH, i: Int) {
      h.b.title.text = posts[i].title
  }
  override fun getItemCount() = posts.size
}''',
    demo: DemoKind.lists,
    brainPower: "What's the Flutter equivalent of a RecyclerView with multiple "
        "view types? (Hint: itemBuilder can return ANY widget.)",
    takeaways: [
      'Use .builder for long/infinite lists.',
      'No Adapter, no ViewHolder.',
      'Use Keys when items move/reorder.',
    ],
  ),
  Concept(
    id: 'navigation',
    title: 'Navigation (Screens)',
    icon: Icons.alt_route,
    category: 'UI',
    androidTerm: 'Activities + Intents / Navigation Component',
    flutterTerm: 'Navigator + Routes (or go_router)',
    oneLiner: "Navigator is a back stack of Routes. push = startActivity, "
        "pop = finish().",
    explanation: [
      "A Route is a 'screen'. Navigator.push adds it to the stack; "
          "Navigator.pop removes it - the system back button pops automatically.",
      "Passing data: constructor args or route arguments ≈ Intent extras.",
      "Returning data: 'await Navigator.push(...)' returns whatever the next "
          "screen passes to pop(result) ≈ startActivityForResult / "
          "ActivityResultLauncher.",
      "Named routes (MaterialApp.onGenerateRoute) ≈ the Activity registry in "
          "the manifest. For deep links and web URLs, use the go_router package "
          "(≈ Navigation Component + NavGraph).",
    ],
    comparison: [
      ('startActivity(intent)', 'Navigator.push(context, route)'),
      ('finish()', 'Navigator.pop(context)'),
      ('intent.putExtra()', 'constructor argument / arguments:'),
      ('startActivityForResult', 'final r = await Navigator.push(...)'),
      ('setResult(RESULT_OK, data)', 'Navigator.pop(context, data)'),
      ('FLAG_ACTIVITY_CLEAR_TOP', 'Navigator.pushNamedAndRemoveUntil'),
      ('NavGraph / Deep links', 'go_router'),
      ('onBackPressedDispatcher', 'PopScope'),
    ],
    flutterCode: r'''
// Open a screen and wait for a result
final String? picked = await Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const ColorPicker()),
);

// In ColorPicker:
Navigator.pop(context, 'blue');''',
    androidCode: r'''
val launcher = registerForActivityResult(StartActivityForResult()) {
    val picked = it.data?.getStringExtra("color")
}
launcher.launch(Intent(this, ColorPickerActivity::class.java))

// In ColorPickerActivity:
setResult(RESULT_OK, Intent().putExtra("color", "blue")); finish()''',
    demo: DemoKind.navigation,
    brainPower: "How many Android Activities does this entire learning app "
        "use? (Answer: exactly one!)",
    takeaways: [
      'push/pop a stack of routes.',
      'await push() to get a result.',
      'go_router for deep links.',
    ],
  ),
  Concept(
    id: 'animations',
    title: 'Animations',
    icon: Icons.animation,
    category: 'UI',
    androidTerm: 'ObjectAnimator / ValueAnimator / MotionLayout / transitions',
    flutterTerm: 'Implicit (AnimatedX) & Explicit (AnimationController)',
    oneLiner: "Implicit: change a value, it animates. Explicit: you drive an "
        "AnimationController.",
    explanation: [
      "Implicit animations - AnimatedContainer, AnimatedOpacity, AnimatedAlign, "
          "AnimatedSwitcher... Change a property in setState and the widget "
          "animates to it. ≈ view.animate().alpha(0f).",
      "Explicit animations - AnimationController (≈ ValueAnimator) + Tween + "
          "Curve (≈ Interpolator). You control start/stop/repeat/reverse.",
      "Hero ≈ shared element transition between Activities.",
      "Everything runs at 60/120 fps on the UI thread, drawn by Flutter's own "
          "renderer (Impeller/Skia).",
    ],
    comparison: [
      ('view.animate().alpha()', 'AnimatedOpacity'),
      ('ValueAnimator', 'AnimationController'),
      ('Interpolator', 'Curve (Curves.easeInOut)'),
      ('TypeEvaluator', 'Tween<T>'),
      ('Shared element transition', 'Hero'),
      ('AnimatedVectorDrawable / Lottie', 'Lottie / Rive packages'),
      ('MotionLayout', 'Explicit animations / AnimatedBuilder'),
    ],
    flutterCode: r'''
AnimatedContainer(
  duration: const Duration(milliseconds: 400),
  curve: Curves.easeInOut,
  width: _big ? 200 : 100,
  color: _big ? Colors.blue : Colors.red,
)
// later: setState(() => _big = !_big);''',
    androidCode: r'''
ValueAnimator.ofInt(100, 200).apply {
    duration = 400
    interpolator = AccelerateDecelerateInterpolator()
    addUpdateListener {
        view.layoutParams.width = it.animatedValue as Int
        view.requestLayout()
    }
}.start()''',
    demo: DemoKind.animations,
    brainPower: "When would you choose an explicit animation over an implicit "
        "one?",
    takeaways: [
      'Start with implicit AnimatedX widgets.',
      'AnimationController needs a TickerProvider & dispose().',
      'Hero for shared element transitions.',
    ],
  ),
  Concept(
    id: 'theming',
    title: 'Theming & Resources',
    icon: Icons.palette_outlined,
    category: 'UI',
    androidTerm: 'themes.xml / colors.xml / dimens.xml / strings.xml',
    flutterTerm: 'ThemeData / ColorScheme / Theme.of(context) / ARB files',
    oneLiner: "Resources are Dart objects. Theme.of(context) ≈ "
        "?attr/colorPrimary.",
    explanation: [
      "MaterialApp(theme:, darkTheme:, themeMode:) ≈ Theme.MaterialComponents "
          "+ values-night.",
      "Theme.of(context).colorScheme.primary ≈ ?attr/colorPrimary.",
      "Strings/localisation: flutter_localizations + .arb files ≈ "
          "values-xx/strings.xml.",
      "Images: declare in pubspec.yaml assets ≈ res/drawable. Use "
          "2.0x/3.0x folders ≈ drawable-xhdpi/xxhdpi.",
    ],
    comparison: [
      ('res/values/themes.xml', 'ThemeData'),
      ('values-night/', 'darkTheme + ThemeMode'),
      ('?attr/colorPrimary', 'Theme.of(context).colorScheme.primary'),
      ('strings.xml / values-fr', 'ARB files + intl'),
      ('drawable-xxhdpi', 'assets/images/3.0x/'),
      ('dimens.xml', 'const double values / a Spacing class'),
      ('dp', 'logical pixels (default unit)'),
      ('sp', 'fontSize scaled by MediaQuery.textScaler'),
    ],
    flutterCode: r'''
MaterialApp(
  theme: ThemeData(colorSchemeSeed: Colors.indigo),
  darkTheme: ThemeData(
    colorSchemeSeed: Colors.indigo,
    brightness: Brightness.dark,
  ),
  themeMode: ThemeMode.system,
);

// Anywhere below:
color: Theme.of(context).colorScheme.primary''',
    androidCode: r'''
<style name="Theme.App" parent="Theme.Material3.DayNight">
    <item name="colorPrimary">@color/indigo</item>
</style>

android:textColor="?attr/colorPrimary"''',
    demo: DemoKind.theming,
    brainPower: "Flutter units are 'logical pixels'. Are they closer to px, dp "
        "or sp?",
    takeaways: [
      'One ThemeData, read via Theme.of(context).',
      'Logical pixels ≈ dp.',
      'Toggle dark mode in Settings tab!',
    ],
  ),
  // ───────────────────────────── ARCHITECTURE ─────────────────────────────
  Concept(
    id: 'state_management',
    title: 'State Management',
    icon: Icons.hub_outlined,
    category: 'Architecture',
    androidTerm: 'ViewModel + LiveData / StateFlow',
    flutterTerm: 'Provider (ChangeNotifier) / Riverpod / Bloc',
    oneLiner: "ChangeNotifier ≈ ViewModel. notifyListeners() ≈ "
        "liveData.postValue(). context.watch ≈ observe().",
    explanation: [
      "Ephemeral state (is this checkbox ticked?) → setState is fine.",
      "App state (cart, logged-in user, settings) → lift it up into a provider "
          "so many screens can read and change it.",
      "Provider injects objects down the tree (≈ Hilt). ChangeNotifier holds "
          "data and calls notifyListeners() (≈ LiveData.setValue).",
      "context.watch<T>() rebuilds on change (≈ observe). context.read<T>() "
          "just gets it once, for callbacks (≈ calling a ViewModel method).",
      "Other popular choices: Riverpod (≈ Hilt+Flow), Bloc (≈ MVI with "
          "StateFlow). All share the same idea: UI = f(state).",
    ],
    comparison: [
      ('ViewModel', 'ChangeNotifier / Cubit / Notifier'),
      ('LiveData / StateFlow', 'ChangeNotifier / Stream / ValueNotifier'),
      ('observe(owner) {..}', 'context.watch<T>() / Consumer<T>'),
      ('viewModel.doSomething()', 'context.read<T>().doSomething()'),
      ('Hilt / Koin', 'Provider / Riverpod / get_it'),
      ('activityViewModels()', 'Provider placed above both screens'),
    ],
    flutterCode: r'''
class CartProvider extends ChangeNotifier {
  final _items = <Item>[];
  int get count => _items.length;
  void add(Item i) { _items.add(i); notifyListeners(); }
}

// UI
final count = context.watch<CartProvider>().count;       // observe
context.read<CartProvider>().add(item);                  // call''',
    androidCode: r'''
class CartViewModel : ViewModel() {
  private val _count = MutableLiveData(0)
  val count: LiveData<Int> = _count
  fun add(item: Item) { items += item; _count.value = items.size }
}

viewModel.count.observe(this) { badge.text = "$it" }''',
    demo: DemoKind.stateManagement,
    brainPower: "The cart badge in the AppBar and the cart screen both update "
        "instantly. Where does the single source of truth live?",
    takeaways: [
      'UI = f(state).',
      'watch to observe, read to call.',
      'See CartProvider in lib/state/.',
    ],
  ),
  Concept(
    id: 'build_context',
    title: 'BuildContext & InheritedWidget',
    icon: Icons.location_searching,
    category: 'Architecture',
    androidTerm: 'Context',
    flutterTerm: 'BuildContext',
    oneLiner: "BuildContext = 'where am I in the widget tree?'. Use it to "
        "look UP the tree for Theme, Navigator, providers.",
    explanation: [
      "Every build(BuildContext context) receives a handle to its position in "
          "the tree.",
      "Theme.of(context), MediaQuery.of(context), Navigator.of(context) all "
          "walk UP the tree to the nearest ancestor of that type. That ancestor "
          "is usually an InheritedWidget.",
      "Like Android's Context it is used to access 'the environment' - but "
          "it's tied to a tree position, not an Activity. Don't store it and "
          "don't use it after an await without checking 'mounted'.",
    ],
    comparison: [
      ('Context', 'BuildContext'),
      ('context.getString / getColor', 'Theme.of(context) / Localizations'),
      ('resources.displayMetrics', 'MediaQuery.sizeOf(context)'),
      ('Leaking Activity context', 'using context after dispose (check mounted)'),
    ],
    flutterCode: r'''
Future<void> save() async {
  await repo.save();
  if (!context.mounted) return;   // screen may be gone!
  ScaffoldMessenger.of(context)
      .showSnackBar(const SnackBar(content: Text('Saved')));
}''',
    androidCode: r'''
lifecycleScope.launch {
    repo.save()
    // lifecycleScope auto-cancels if Activity destroyed
    Toast.makeText(this@MainActivity, "Saved", LENGTH_SHORT).show()
}''',
    demo: DemoKind.threeTrees,
    brainPower: "Why does Theme.of(context) fail to find a Theme when called "
        "with the context of the widget that CREATES the MaterialApp?",
    takeaways: [
      'Context = position in tree.',
      '.of(context) looks upward.',
      'Check context.mounted after await.',
    ],
  ),
  Concept(
    id: 'three_trees',
    title: 'Widget, Element & Render Trees',
    icon: Icons.park_outlined,
    category: 'Architecture',
    androidTerm: 'View hierarchy (measure / layout / draw)',
    flutterTerm: 'Widget → Element → RenderObject',
    oneLiner: "Widgets are blueprints, Elements are the living instances, "
        "RenderObjects do layout & paint.",
    explanation: [
      "Widget tree: your cheap immutable config, rebuilt often.",
      "Element tree: long-lived; holds State; decides whether an old widget "
          "can be UPDATED (same type + key) or must be replaced.",
      "RenderObject tree: expensive objects that do measure/layout/paint - "
          "the real 'Views'.",
      "Rebuilding widgets is cheap because Elements and RenderObjects are "
          "reused whenever possible. This is why Keys matter in lists.",
    ],
    comparison: [
      ('XML definition', 'Widget'),
      ('View instance', 'Element (+ State)'),
      ('onMeasure / onLayout / onDraw', 'RenderObject.performLayout / paint'),
      ('View.setTag / stable IDs', 'Key / ValueKey / GlobalKey'),
    ],
    flutterCode: r'''
// Keys help Elements match widgets when order changes:
ListView(
  children: [
    for (final todo in todos)
      TodoTile(key: ValueKey(todo.id), todo: todo),
  ],
)''',
    androidCode: r'''
// RecyclerView equivalent: stable ids
adapter.setHasStableIds(true)
override fun getItemId(position: Int) = items[position].id''',
    demo: DemoKind.threeTrees,
    brainPower: "If build() creates brand-new widgets each frame, why isn't "
        "Flutter slow?",
    takeaways: [
      'Widget = config, Element = instance, RenderObject = painter.',
      'Same type + same key ⇒ element is reused.',
    ],
  ),
  // ───────────────────────────── ASYNC & PLATFORM ─────────────────────────────
  Concept(
    id: 'async',
    title: 'Async: Future & Stream',
    icon: Icons.hourglass_bottom,
    category: 'Async & Platform',
    androidTerm: 'Coroutines (suspend) / Flow / RxJava',
    flutterTerm: 'Future + async/await / Stream',
    oneLiner: "Future ≈ suspend fun result (one value). Stream ≈ Flow "
        "(many values).",
    explanation: [
      "Dart is single-threaded with an event loop - like Android's main "
          "Looper. async/await does NOT create a thread; it just yields "
          "until the result arrives (like a coroutine on Dispatchers.Main).",
      "I/O (network, disk) is already non-blocking, so await it directly - no "
          "Dispatchers.IO needed.",
      "FutureBuilder ≈ observing a one-shot LiveData; StreamBuilder ≈ "
          "collectAsState/observe on a Flow.",
      "CPU-heavy work (parsing a huge JSON, image processing) must go to an "
          "Isolate - see the Isolates concept.",
    ],
    comparison: [
      ('suspend fun load(): T', 'Future<T> load() async'),
      ('Flow<T>', 'Stream<T>'),
      ('launch { }', 'unawaited(foo()) / just call it'),
      ('withContext(IO)', 'not needed for I/O'),
      ('try/catch in coroutine', 'try/catch around await'),
      ('flow.collect', 'await for (x in stream) / listen'),
      ('StateFlow', 'ValueNotifier / BehaviorSubject (rxdart)'),
    ],
    flutterCode: r'''
Future<List<Post>> loadPosts() async {
  try {
    final res = await http.get(uri);
    return parse(res.body);
  } catch (e) {
    rethrow;
  }
}

Stream<int> ticker() =>
    Stream.periodic(const Duration(seconds: 1), (i) => i);''',
    androidCode: r'''
suspend fun loadPosts(): List<Post> = withContext(Dispatchers.IO) {
    api.getPosts()
}

fun ticker(): Flow<Int> = flow {
    var i = 0
    while (true) { emit(i++); delay(1000) }
}''',
    demo: DemoKind.async,
    brainPower: "If Dart has only one thread, how can the UI stay smooth while "
        "waiting 3 seconds for a network call?",
    takeaways: [
      'await = suspend, Stream = Flow.',
      'I/O does not block the event loop.',
      'Use FutureBuilder / StreamBuilder in UI.',
    ],
  ),
  Concept(
    id: 'isolates',
    title: 'Isolates & Background Work',
    icon: Icons.memory,
    category: 'Async & Platform',
    androidTerm: 'Threads / Executors / Service / WorkManager',
    flutterTerm: 'Isolate.run / compute() / workmanager plugin',
    oneLiner: "An Isolate is a thread with its OWN memory - they communicate "
        "only by messages.",
    explanation: [
      "Heavy CPU work on the main isolate freezes the UI (jank), exactly like "
          "blocking the Android main thread (ANR).",
      "Isolate.run(() => heavyWork()) runs it on another isolate and returns a "
          "Future. No shared memory ⇒ no locks, no race conditions.",
      "Long-running background tasks when the app is closed (sync, uploads) "
          "still need the native OS: use the workmanager plugin (≈ WorkManager) "
          "or a foreground-service plugin.",
    ],
    comparison: [
      ('Thread / Executor', 'Isolate'),
      ('Dispatchers.Default', 'Isolate.run() / compute()'),
      ('Handler / Message', 'SendPort / ReceivePort'),
      ('WorkManager', 'workmanager plugin'),
      ('Foreground Service', 'flutter_foreground_task plugin'),
      ('JobScheduler / Alarms', 'android_alarm_manager_plus'),
    ],
    flutterCode: r'''
final primes = await Isolate.run(() => countPrimes(5000000));
setState(() => _result = primes);''',
    androidCode: r'''
val primes = withContext(Dispatchers.Default) {
    countPrimes(5_000_000)
}
result.text = primes.toString()''',
    demo: DemoKind.isolates,
    brainPower: "Why can't two isolates share a List object directly?",
    takeaways: [
      'UI isolate = main thread.',
      'Isolate.run for CPU-bound work.',
      'OS-level background work needs plugins.',
    ],
  ),
  Concept(
    id: 'platform_channels',
    title: 'Platform Channels',
    icon: Icons.settings_input_component,
    category: 'Async & Platform',
    androidTerm: 'Native Kotlin/Java APIs, JNI',
    flutterTerm: 'MethodChannel / EventChannel / Pigeon / plugins',
    oneLiner: "When Dart needs Android APIs, it sends a message over a "
        "channel to Kotlin code in MainActivity.",
    explanation: [
      "Flutter can't call Android SDK APIs directly. A MethodChannel is a "
          "named, async message pipe between Dart and Kotlin/Swift.",
      "Dart: channel.invokeMethod('getBattery'). Kotlin: "
          "setMethodCallHandler { call, result -> result.success(85) }.",
      "EventChannel streams continuous native events (sensors) ≈ a callbackFlow.",
      "Plugins (camera, location, shared_preferences...) are just packaged "
          "channels. Pigeon generates type-safe channel code.",
    ],
    comparison: [
      ('Direct SDK call', 'MethodChannel.invokeMethod'),
      ('BroadcastReceiver / sensor listener', 'EventChannel'),
      ('AIDL / generated binder', 'Pigeon'),
      ('Gradle library dependency', 'Flutter plugin in pubspec.yaml'),
    ],
    flutterCode: r'''
const channel = MethodChannel('learn.flutter/battery');
final level = await channel.invokeMethod<int>('getBatteryLevel');''',
    androidCode: r'''
// android/app/src/main/kotlin/.../MainActivity.kt
class MainActivity : FlutterActivity() {
  override fun configureFlutterEngine(engine: FlutterEngine) {
    super.configureFlutterEngine(engine)
    MethodChannel(engine.dartExecutor.binaryMessenger,
        "learn.flutter/battery").setMethodCallHandler { call, result ->
      if (call.method == "getBatteryLevel") {
        val bm = getSystemService(BATTERY_SERVICE) as BatteryManager
        result.success(bm.getIntProperty(
            BatteryManager.BATTERY_PROPERTY_CAPACITY))
      } else result.notImplemented()
    }
  }
}''',
    demo: DemoKind.platformChannel,
    brainPower: "Your existing Android app has a custom SDK. How would you use "
        "it from Flutter?",
    takeaways: [
      'Channels = async messages Dart ⇄ native.',
      'Check pub.dev for a plugin first.',
      'Pigeon for type safety.',
    ],
  ),
  // ───────────────────────────── TOOLING ─────────────────────────────
  Concept(
    id: 'hot_reload',
    title: 'Hot Reload & Hot Restart',
    icon: Icons.local_fire_department_outlined,
    category: 'Tooling',
    androidTerm: 'Apply Changes / full rebuild & reinstall',
    flutterTerm: 'Hot reload (r) / Hot restart (R)',
    oneLiner: "Hot reload injects changed code into the running app in "
        "under a second - and KEEPS state.",
    explanation: [
      "Debug builds run Dart in a VM with JIT compilation, so new code can be "
          "injected live.",
      "Hot reload (r / ⚡ in IDE): re-runs build() with new code, keeps State. "
          "Great for UI tweaks.",
      "Hot restart (R): restarts the Dart app from main(), loses state, but "
          "much faster than reinstalling.",
      "Full rebuild needed when: native code changes (Kotlin, manifest, "
          "gradle), new plugin added, or changes to main()/initState logic "
          "you want re-run.",
    ],
    comparison: [
      ('Apply Code Changes', 'Hot reload'),
      ('Apply Changes and Restart Activity', 'Hot restart'),
      ('Run ▶ (rebuild APK)', 'flutter run (after native changes)'),
    ],
    flutterCode: r'''
$ flutter run
Flutter run key commands.
r Hot reload. 🔥🔥🔥
R Hot restart.
q Quit''',
    androidCode: r'''
./gradlew installDebug
adb shell am start -n com.example/.MainActivity''',
    demo: DemoKind.hotReload,
    brainPower: "Why can't release builds support hot reload? (Hint: JIT vs AOT)",
    takeaways: [
      'r = reload (keeps state).',
      'R = restart (resets state).',
      'Native changes need full rebuild.',
    ],
  ),
  Concept(
    id: 'build_modes',
    title: 'Build Modes & Compilation',
    icon: Icons.build_circle_outlined,
    category: 'Tooling',
    androidTerm: 'debug / release buildTypes, R8',
    flutterTerm: 'debug / profile / release',
    oneLiner: "Debug = JIT + hot reload + asserts. Release = AOT native "
        "ARM code, tree-shaken, fast.",
    explanation: [
      "debug: JIT, assertions on, debug banner, service extensions, slow-ish.",
      "profile: AOT like release but keeps profiling hooks - use it with "
          "DevTools for performance work. Run on a real device.",
      "release: AOT-compiled to native ARM machine code (libapp.so), "
          "tree-shaken, no debugging. This is what you ship.",
      "Obfuscation: flutter build appbundle --obfuscate "
          "--split-debug-info=build/symbols (≈ R8 minifyEnabled + mapping.txt).",
    ],
    comparison: [
      ('buildTypes.debug', 'flutter run (debug)'),
      ('(no equivalent)', 'flutter run --profile'),
      ('buildTypes.release', 'flutter build appbundle --release'),
      ('minifyEnabled + R8', '--obfuscate --split-debug-info'),
      ('productFlavors', '--flavor + --dart-define'),
      ('BuildConfig.DEBUG', 'kDebugMode / kReleaseMode'),
    ],
    flutterCode: r'''
import 'package:flutter/foundation.dart';

if (kDebugMode) {
  debugPrint('Only in debug builds');
}''',
    androidCode: r'''
if (BuildConfig.DEBUG) {
    Log.d(TAG, "Only in debug builds")
}''',
    demo: DemoKind.buildModes,
    brainPower: "Why should you never measure performance in debug mode?",
    takeaways: [
      'Debug is slow on purpose.',
      'Profile mode for perf.',
      'Release = AOT, obfuscate it.',
    ],
  ),
];
