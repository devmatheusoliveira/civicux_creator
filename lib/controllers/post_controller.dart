import 'package:flutter/material.dart';

import '../models/post_model.dart';
import '../services/post_service.dart';

class PostController extends ChangeNotifier {
  PostController({PostService? service}) : _service = service ?? PostService();

  final PostService _service;

  bool _loading = false;
  List<PostModel> _posts = const [];
  String? _error;

  bool get isLoading => _loading;
  List<PostModel> get posts => _posts;
  String? get error => _error;

  Future<void> loadPosts() async {
    if (_loading) return;
    _loading = true;
    notifyListeners();

    try {
      final data = await _service.fetchUserPosts();
      _posts = data.map((item) {
        return PostModel(
          id: item['id'].hashCode, // Temporary mapping for compatibility
          title: item['audience'] ?? 'Sem título',
          body: item['content'] ?? '',
        );
      }).toList();
      _error = null;
    } catch (e) {
      _error = 'Erro ao carregar dados: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
