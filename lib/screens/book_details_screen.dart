import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BookDetailsScreen extends StatefulWidget {
  final Map<String, String> libro;

  const BookDetailsScreen({super.key, required this.libro});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  // Controladores para editar los textos
  late TextEditingController _tituloController;
  late TextEditingController _autorController;
  late String _estadoSeleccionado;
  bool _editando = false;

  @override
  void initState() {
    super.initState();
    // Inicializamos con los datos actuales del libro
    _tituloController = TextEditingController(text: widget.libro['titulo']);
    _autorController = TextEditingController(text: widget.libro['autor']);
    _estadoSeleccionado = widget.libro['estado'] ?? 'Pendiente';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE3D4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D241E)),
        title: Text(_editando ? 'Editando...' : 'Detalles', 
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: const Color(0xFF2D241E))),
        actions: [
          IconButton(
            icon: Icon(_editando ? Icons.check_circle : Icons.edit, color: _editando ? Colors.green : const Color(0xFF2D241E)),
            onPressed: () {
              if (_editando) {
                // Al guardar, salimos enviando los nuevos datos
                Map<String, String> libroEditado = {
                  ...widget.libro,
                  'titulo': _tituloController.text,
                  'autor': _autorController.text,
                  'estado': _estadoSeleccionado,
                };
                Navigator.pop(context, libroEditado);
              } else {
                setState(() => _editando = true);
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            // Portada (esta no la editamos por ahora)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(widget.libro['portada'] ?? '', height: 250, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 30),

            // Campo de Título
            _editando 
              ? TextField(
                  controller: _tituloController,
                  decoration: const InputDecoration(labelText: 'Título del libro'),
                  style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold),
                )
              : Text(_tituloController.text, 
                  textAlign: TextAlign.center, 
                  style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold)),

            const SizedBox(height: 10),

            // Campo de Autor
            _editando 
              ? TextField(
                  controller: _autorController,
                  decoration: const InputDecoration(labelText: 'Autor'),
                  style: GoogleFonts.inter(fontSize: 18),
                )
              : Text(_autorController.text, 
                  style: GoogleFonts.inter(fontSize: 18, color: Colors.grey[700], fontStyle: FontStyle.italic)),

            const SizedBox(height: 25),

            // Selector de Estado (Dropdown si editamos, Badge si no)
            _editando
              ? DropdownButton<String>(
                  value: _estadoSeleccionado,
                  items: ['Pendiente', 'En curso', 'Finalizado'].map((String valor) {
                    return DropdownMenuItem<String>(value: valor, child: Text(valor));
                  }).toList(),
                  onChanged: (nuevo) => setState(() => _estadoSeleccionado = nuevo!),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: const Color(0xFFD4A373), borderRadius: BorderRadius.circular(20)),
                  child: Text(_estadoSeleccionado, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
          ],
        ),
      ),
    );
  }
}