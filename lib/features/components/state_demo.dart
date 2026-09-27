// State management with Provider: a shared cart.
// The cart badge in the home AppBar observes the SAME CartProvider.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/cart_provider.dart';
import '../../widgets/android_compare_card.dart';

const _products = [
  CartItem('Kotlin Mug', 12.5),
  CartItem('Dart Hoodie', 39.0),
  CartItem('Flutter Sticker Pack', 4.99),
  CartItem('Android Plushie', 19.0),
];

class StateDemo extends StatelessWidget {
  const StateDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('State (Provider)'),
        actions: [
          // Consumer ≈ observe() scoped to just this widget → only the
          // badge rebuilds, not the whole screen.
          Consumer<CartProvider>(
            builder: (context, cart, _) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Badge(
                label: Text('${cart.count}'),
                child: const Icon(Icons.shopping_cart),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const AndroidCompareCard(
            android: 'Shared ViewModel (activityViewModels) + LiveData',
            flutter: 'ChangeNotifierProvider + context.watch / Consumer',
            note: 'Add items, go back: the badge on the home screen shows the '
                'same count. One source of truth.',
          ),
          const SizedBox(height: 12),
          Text('Products', style: Theme.of(context).textTheme.titleMedium),
          for (final p in _products)
            Card(
              child: ListTile(
                title: Text(p.name),
                subtitle: Text('\$${p.price.toStringAsFixed(2)}'),
                trailing: IconButton.filledTonal(
                  icon: const Icon(Icons.add_shopping_cart),
                  // read = call a method, don't subscribe
                  onPressed: () => context.read<CartProvider>().add(p),
                ),
              ),
            ),
          const SizedBox(height: 16),
          const _CartSection(),
        ],
      ),
    );
  }
}

class _CartSection extends StatelessWidget {
  const _CartSection();

  @override
  Widget build(BuildContext context) {
    // watch = subscribe; this widget rebuilds when the cart changes.
    final cart = context.watch<CartProvider>();
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Cart (${cart.count})',
                style: Theme.of(context).textTheme.titleMedium),
            if (cart.items.isEmpty) const Text('Empty - add something!'),
            for (final (i, item) in cart.items.indexed)
              ListTile(
                dense: true,
                title: Text(item.name),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => context.read<CartProvider>().removeAt(i),
                ),
              ),
            const Divider(),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
              child: Text(
                'Total: \$${cart.total.toStringAsFixed(2)}',
                key: ValueKey(cart.total),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            if (cart.items.isNotEmpty)
              TextButton(
                onPressed: () => context.read<CartProvider>().clear(),
                child: const Text('Clear cart'),
              ),
          ],
        ),
      ),
    );
  }
}
