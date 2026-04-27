class Book {
  final String id;
  String titulo;
  String autor;
  String portada;
  String estado;

  Book({
    required this.id,
    required this.titulo,
    required this.autor,
    required this.portada,
    required this.estado,
  });

  factory Book.fromFirestore(String id, Map<String, dynamic> data) {
    return Book(
      id: id,
      titulo: data['titulo'] ?? '',
      autor: data['autor'] ?? '',
      portada: data['portada'] ?? '',
      estado: data['estado'] ?? 'pendiente',
    );
  }
}
