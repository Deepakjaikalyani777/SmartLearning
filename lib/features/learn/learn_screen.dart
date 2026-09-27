// LearnScreen — searchable, categorised list of concepts.
// ≈ a Fragment with a SearchView + RecyclerView with section headers.
import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import 'concepts_data.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  String _query = '';
  String? _category; // null = all

  List<Concept> get _filtered {
    final q = _query.toLowerCase();
    return concepts.where((c) {
      final matchesCat = _category == null || c.category == _category;
      final matchesQuery = q.isEmpty ||
          c.title.toLowerCase().contains(q) ||
          c.androidTerm.toLowerCase().contains(q) ||
          c.flutterTerm.toLowerCase().contains(q);
      return matchesCat && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SearchBar(
              hintText: 'Search e.g. "RecyclerView", "Intent"...',
              leading: const Icon(Icons.search),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _chip(null, 'All'),
                for (final cat in conceptCategories) _chip(cat, cat),
              ],
            ),
          ),
        ),
        if (items.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text('No concepts match 🤔')),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
          sliver: SliverList.builder(
            itemCount: items.length,
            itemBuilder: (context, i) => _ConceptTile(concept: items[i]),
          ),
        ),
      ],
    );
  }

  Widget _chip(String? value, String label) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ChoiceChip(
          label: Text(label),
          selected: _category == value,
          onSelected: (_) => setState(() => _category = value),
        ),
      );
}

class _ConceptTile extends StatelessWidget {
  const _ConceptTile({required this.concept});
  final Concept concept;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Hero(
          // Hero ≈ shared-element transition into the detail screen
          tag: 'concept-${concept.id}',
          child: CircleAvatar(
            backgroundColor: scheme.primaryContainer,
            child: Icon(concept.icon, color: scheme.onPrimaryContainer),
          ),
        ),
        title: Text(concept.title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text.rich(
            TextSpan(children: [
              const WidgetSpan(
                child: Icon(Icons.android, size: 14, color: Color(0xFF3DDC84)),
              ),
              TextSpan(text: ' ${concept.androidTerm}\n'),
              const WidgetSpan(
                child: Icon(Icons.flutter_dash, size: 14, color: Color(0xFF02569B)),
              ),
              TextSpan(text: ' ${concept.flutterTerm}'),
            ]),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.conceptDetail,
          arguments: concept, // ≈ intent.putExtra("concept", concept)
        ),
      ),
    );
  }
}
