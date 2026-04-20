import 'dart:convert';
import 'package:http/http.dart' as http;

class BookApiService {
  static const String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  Future<List<dynamic>> buscarLibros(String query) async {
    if (query.isEmpty) return [];

    final url = Uri.parse('$_baseUrl?q=$query&maxResults=5&langRestrict=es');
    
    try {
      final respuesta = await http.get(url);

      if (respuesta.statusCode == 200) {
        final data = json.decode(respuesta.body);
        return data['items'] ?? [];
      } else {
        throw Exception('Error al conectar con Google Books');
      }
    } catch (e) {
      print("Error en la API: $e");
      return [];
    }
  }
}