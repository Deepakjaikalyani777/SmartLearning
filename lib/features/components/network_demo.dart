// Networking: Repository → ApiService (http) → JSON → model → list UI.
// ≈ Retrofit + Repository + ViewModel + RecyclerView with loading/error states.
import 'package:flutter/material.dart';

import '../../data/models/post.dart';
import '../../data/repositories/post_repository.dart';
import '../../widgets/android_compare_card.dart';

class NetworkDemo extends StatefulWidget {
  const NetworkDemo({super.key});
  @override
  State<NetworkDemo> createState() => _NetworkDemoState();
}

class _NetworkDemoState extends State<NetworkDemo> {
  final _repo = PostRepository();
  late Future<List<Post>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.getPosts(); // start loading once ≈ ViewModel init {}
  }

  Future<void> _refresh() async {
    final f = _repo.getPosts(forceRefresh: true);
    setState(() => _future = f);
    await f;
  }

  void _showPost(Post p) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(p.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(p.body),
            const SizedBox(height: 12),
            Text('userId=${p.userId} · id=${p.id}',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Networking')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        // FutureBuilder ≈ observing a LiveData<Resource<T>> with
        // Loading / Success / Error states.
        child: FutureBuilder<List<Post>>(
          future: _future,
          builder: (context, snapshot) {
            final header = const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: AndroidCompareCard(
                android: 'Retrofit @GET + Gson + suspend fun + '
                    'LiveData<Resource>',
                flutter: 'http.get + jsonDecode + Post.fromJson + '
                    'FutureBuilder',
                note: 'GET https://jsonplaceholder.typicode.com/posts. '
                    'Pull to refresh. Needs INTERNET permission in the '
                    'release AndroidManifest.',
              ),
            );

            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView(children: [
                header,
                const SizedBox(height: 80),
                const Center(child: CircularProgressIndicator()),
              ]);
            }
            if (snapshot.hasError) {
              return ListView(children: [
                header,
                const SizedBox(height: 40),
                const Icon(Icons.wifi_off, size: 56),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error: ${snapshot.error}',
                      textAlign: TextAlign.center),
                ),
                Center(
                  child: FilledButton(
                      onPressed: _refresh, child: const Text('Retry')),
                ),
              ]);
            }
            final posts = snapshot.data!;
            return ListView.builder(
              itemCount: posts.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) return header;
                final p = posts[i - 1];
                return ListTile(
                  leading: CircleAvatar(child: Text('${p.id}')),
                  title: Text(p.title,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(p.body,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  onTap: () => _showPost(p),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
