import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleBooksService {
  Future<List<Map<String, String>>> buscar(String query) async {
    if (query.length < 3) return [];
    final url = Uri.parse(
      'https://www.googleapis.com/books/v1/volumes?q=$query&maxResults=5&langRestrict=es',
    );
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final items = data['items'] as List?;
        if (items == null) return [];
        return items.map((item) {
          final info = item['volumeInfo'];

          String portadaUrl =
              info['imageLinks']?['thumbnail']?.toString() ?? '';

          if (portadaUrl.isNotEmpty) {
            portadaUrl = portadaUrl.replaceFirst('http:', 'https:');

            if (portadaUrl.contains('&')) {
              portadaUrl = portadaUrl.split('&').first;
            }
          }
          

          List<String> categorias = (info['categories'] as List?)?.cast<String>() ?? [];
          String generosString = categorias.take(3).join(', ');

          return {
            'titulo': info['title']?.toString() ?? 'Sin título',
            'autor': (info['authors'] as List?)?.join(', ') ?? 'Desconocido',
            'genero': generosString.isEmpty ? 'General' : generosString,
            'lanzamiento':
                info['publishedDate']?.toString().split('-')[0] ?? '----',
            'paginas': info['pageCount']?.toString() ?? '0',
            'portada': portadaUrl,
            'rating': info['averageRating']?.toString() ?? '0.0',
            'sinopsis':
                info['description']?.toString() ??
                'No hay descripción disponible para este libro',
          };
        }).toList();
      }
    } catch (e) {
      print(e);
    }
    return [];
  }
}
