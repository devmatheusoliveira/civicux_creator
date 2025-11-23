import 'dart:convert';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class PostService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> savePost({
    required String title,
    required String content,
    required String? imageBase64,
    int? proposalId,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    String? imagePath;

    if (imageBase64 != null) {
      try {
        // Extract base64 data if it has a prefix
        final cleanBase64 = imageBase64.startsWith('data:') 
            ? imageBase64.split(',')[1] 
            : imageBase64;
        
        final Uint8List bytes = base64Decode(cleanBase64);
        final fileName = '${user.id}/${const Uuid().v4()}.png';
        
        await _supabase.storage.from('post_images').uploadBinary(
          fileName,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/png'),
        );
        
        imagePath = _supabase.storage.from('post_images').getPublicUrl(fileName);
      } catch (e) {
        print('Erro ao fazer upload da imagem: $e');
        // Continue saving the post even if image upload fails
      }
    }

    await _supabase.from('generated_posts').insert({
      'user_id': user.id,
      'proposal_id': proposalId,
      'audience': title,
      'content': content,
      'image_path': imagePath,
    });
  }

  Future<List<Map<String, dynamic>>> fetchUserPosts() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    final response = await _supabase
        .from('generated_posts')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);
        
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchPostsByProposal(int proposalId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    final response = await _supabase
        .from('generated_posts')
        .select()
        .eq('user_id', user.id)
        .eq('proposal_id', proposalId)
        .order('created_at', ascending: false);
        
    return List<Map<String, dynamic>>.from(response);
  }
}
