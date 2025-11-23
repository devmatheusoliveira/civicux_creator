import 'dart:convert';
import 'package:http/http.dart' as http;

class CamaraService {
  static final CamaraService _instance = CamaraService._internal();
  factory CamaraService() => _instance;
  CamaraService._internal();

  final String _baseUrl =
      'https://dadosabertos.camara.leg.br/api/v2/proposicoes';

  Future<List<Map<String, dynamic>>> fetchProposals({String? query}) async {
    try {
      final queryParams = <String, String>{
        'ordem': 'DESC',
        'ordenarPor': 'id',
        'siglaTipo': 'PL',
      };

      if (query != null && query.isNotEmpty) {
        queryParams['keywords'] = query;
        // If searching, we might want to broaden the search, but let's keep 2025 for now
        // or maybe 2024/2025. The original code had 2025.
        // Let's keep 2025 to be consistent with the initial view.
        queryParams['ano'] = '2025';
      } else {
        queryParams['ano'] = '2025';
      }

      final response = await http.get(
        Uri.parse(_baseUrl).replace(queryParameters: queryParams),
        headers: {'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data['dados'] != null && data['dados'] is List) {
          return List<Map<String, dynamic>>.from(data['dados']);
        }
        return [];
      } else {
        print('Camara API error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching proposals: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchProposalDetails(int proposalId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$proposalId'),
        headers: {'accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data['dados'] != null) {
          return Map<String, dynamic>.from(data['dados']);
        }
        return null;
      } else {
        print('Camara API error fetching details: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching proposal details: $e');
      return null;
    }
  }
}
