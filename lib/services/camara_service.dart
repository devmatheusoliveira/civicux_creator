import 'dart:convert';
import 'package:http/http.dart' as http;

class CamaraService {
  static final CamaraService _instance = CamaraService._internal();
  factory CamaraService() => _instance;
  CamaraService._internal();

  final String _baseUrl = 'https://dadosabertos.camara.leg.br/api/v2/proposicoes';

  Future<List<Map<String, dynamic>>> fetchProposals() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?ordem=DESC&ordenarPor=id&ano=2025&siglaTipo=PL'),
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
