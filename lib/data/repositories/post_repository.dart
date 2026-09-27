// Repository pattern — identical idea to Android Architecture Components:
// UI -> (ViewModel) -> Repository -> (API | cache)
import '../models/post.dart';
import '../services/api_service.dart';

class PostRepository {
  PostRepository({ApiService? api}) : _api = api ?? ApiService();

  final ApiService _api;
  List<Post>? _cache; // simple in-memory cache ≈ Room/LruCache in real apps

  Future<List<Post>> getPosts({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache != null) return _cache!;
    _cache = await _api.fetchPosts();
    return _cache!;
  }
}
