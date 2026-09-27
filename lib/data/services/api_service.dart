// api_service.dart — raw HTTP calls.
// ≈ a Retrofit interface + OkHttpClient.
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/post.dart';

class ApiException implements Exception {
  ApiException(this.message);
  final String message;
  @override
  String toString() => 'ApiException: $message';
}

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  // Always HTTPS. (Android: usesCleartextTraffic="false")
  static const _baseUrl = 'https://jsonplaceholder.typicode.com';
  final http.Client _client;

  /// ≈ `@GET("posts") suspend fun getPosts(): List<Post>`
  Future<List<Post>> fetchPosts() async {
    final response = await _client
        .get(Uri.parse('$_baseUrl/posts'))
        .timeout(const Duration(seconds: 15)); // ≈ OkHttp readTimeout

    if (response.statusCode != 200) {
      throw ApiException('HTTP ${response.statusCode}');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => Post.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }
}
