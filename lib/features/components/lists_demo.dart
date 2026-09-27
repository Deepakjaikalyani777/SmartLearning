import 'package:flutter/material.dart';

class ListsDemo extends StatelessWidget {
  const ListsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // TabBar + TabBarView ≈ TabLayout + ViewPager2
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lists & Grids'),
          bottom: const TabBar(tabs: [
            Tab(text: 'ListView'),
            Tab(text: 'GridView'),
            Tab(text: 'Swipe'),
          ]),
        ),
        body: const TabBarView(children: [
          _SimpleList(),
          _Grid(),
          _SwipeList(),
        ]),
      ),
    );
  }
}

class _SimpleList extends StatelessWidget {
  const _SimpleList();

  @override
  Widget build(BuildContext context) {
    // ListView.separated ≈ RecyclerView + DividerItemDecoration
    return ListView.separated(
      itemCount: 1000,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) => ListTile(
        leading: CircleAvatar(child: Text('${i + 1}')),
        title: Text('Item ${i + 1}'),
        subtitle: const Text('Built lazily ≈ onBindViewHolder'),
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Clicked item ${i + 1}')),
        ),
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid();

  @override
  Widget build(BuildContext context) {
    // ≈ RecyclerView + GridLayoutManager(spanCount = 3)
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 60,
      itemBuilder: (context, i) => Container(
        decoration: BoxDecoration(
          color: Colors.primaries[i % Colors.primaries.length].shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text('$i', style: const TextStyle(fontSize: 22)),
      ),
    );
  }
}

class _SwipeList extends StatefulWidget {
  const _SwipeList();
  @override
  State<_SwipeList> createState() => _SwipeListState();
}

class _SwipeListState extends State<_SwipeList> {
  List<String> _items = List.generate(15, (i) => 'Email #${i + 1}');

  Future<void> _refresh() async {
    // ≈ SwipeRefreshLayout.OnRefreshListener
    await Future<void>.delayed(const Duration(seconds: 1));
    setState(() => _items = List.generate(15, (i) => 'Email #${i + 1}'));
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _items.length + 1,
        itemBuilder: (context, i) {
          if (i == 0) {
            return const Padding(
              padding: EdgeInsets.all(12),
              child: Text('Swipe a row to delete (≈ ItemTouchHelper). '
                  'Pull down to refresh (≈ SwipeRefreshLayout).'),
            );
          }
          final item = _items[i - 1];
          return Dismissible(
            // Key tells Flutter which element is which ≈ stable IDs/DiffUtil
            key: ValueKey(item),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) {
              setState(() => _items.remove(item));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('$item deleted'),
                action: SnackBarAction(
                  label: 'UNDO',
                  onPressed: () =>
                      setState(() => _items.insert(i - 1, item)),
                ),
              ));
            },
            child: ListTile(
              leading: const Icon(Icons.mail_outline),
              title: Text(item),
            ),
          );
        },
      ),
    );
  }
}
