import 'package:supabase_flutter/supabase_flutter.dart';

class ConfigService {
  static final ConfigService _instance = ConfigService._internal();
  factory ConfigService() => _instance;
  ConfigService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  // Cache para evitar múltiplas requisições
  String? _cachedGeminiApiKey;
  DateTime? _cacheTime;
  static const Duration _cacheDuration = Duration(minutes: 30);

  /// Busca a chave da API do Gemini do Supabase
  Future<String?> getGeminiApiKey() async {
    try {
      // Verifica se o cache ainda é válido
      if (_cachedGeminiApiKey != null && _cacheTime != null) {
        if (DateTime.now().difference(_cacheTime!) < _cacheDuration) {
          return _cachedGeminiApiKey;
        }
      }

      // Busca do Supabase
      final response = await _supabase
          .from('app_config')
          .select('config_value')
          .eq('config_key', 'gemini_api_key')
          .single();

      if (response['config_value'] != null) {
        _cachedGeminiApiKey = response['config_value'] as String;
        _cacheTime = DateTime.now();
        return _cachedGeminiApiKey;
      }

      return null;
    } catch (e) {
      print('Erro ao buscar chave do Gemini: $e');
      return null;
    }
  }

  /// Atualiza a chave da API do Gemini no Supabase
  Future<bool> updateGeminiApiKey(String apiKey) async {
    try {
      await _supabase.from('app_config').upsert({
        'config_key': 'gemini_api_key',
        'config_value': apiKey,
        'description': 'Chave de API do Google Gemini',
      });

      // Atualiza o cache
      _cachedGeminiApiKey = apiKey;
      _cacheTime = DateTime.now();

      return true;
    } catch (e) {
      print('Erro ao atualizar chave do Gemini: $e');
      return false;
    }
  }

  /// Busca uma configuração genérica
  Future<String?> getConfig(String key) async {
    try {
      final response = await _supabase
          .from('app_config')
          .select('config_value')
          .eq('config_key', key)
          .single();

      if (response['config_value'] != null) {
        return response['config_value'] as String;
      }

      return null;
    } catch (e) {
      print('Erro ao buscar configuração $key: $e');
      return null;
    }
  }

  /// Atualiza uma configuração genérica
  Future<bool> updateConfig(
    String key,
    String value, {
    String? description,
  }) async {
    try {
      final data = {'config_key': key, 'config_value': value};

      if (description != null) {
        data['description'] = description;
      }

      await _supabase.from('app_config').upsert(data);

      return true;
    } catch (e) {
      print('Erro ao atualizar configuração $key: $e');
      return false;
    }
  }

  /// Limpa o cache
  void clearCache() {
    _cachedGeminiApiKey = null;
    _cacheTime = null;
  }
}
