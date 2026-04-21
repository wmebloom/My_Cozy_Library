import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BookDetailsScreen extends StatefulWidget {
  final Map<String, String> libro;
  final Function(Map<String, String>) onSave;

  const BookDetailsScreen({
    super.key,
    required this.libro,
    required this.onSave,
  });

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  late TextEditingController _tituloController;
  late TextEditingController _autorController;
  late String _estadoSeleccionado;
  late TextEditingController _yearController;
  TextEditingController _notasController = TextEditingController();
  bool _editando = false;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.libro['titulo']);
    _autorController = TextEditingController(text: widget.libro['autor']);
    _estadoSeleccionado = widget.libro['estado'] ?? 'Pendiente';
    _notasController = TextEditingController(text: widget.libro['notas'] ?? '');
    _yearController = TextEditingController(
      text: widget.libro['lanzamiento'] ?? '----',
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _autorController.dispose();
    _yearController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  void _confirmarCambios({bool cerrarPantalla = true}) {
    widget.libro['titulo'] = _tituloController.text;
    widget.libro['autor'] = _autorController.text;
    widget.libro['estado'] = _estadoSeleccionado;
    widget.libro['lanzamiento'] = _yearController.text;
    widget.libro['notas'] = _notasController.text;

    if (cerrarPantalla) {
      Navigator.pop(context, widget.libro);
    } else {
      setState(() {
        _editando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nota guardada"),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Definimos el color según el estado
    Color colorBadge;
    if (_estadoSeleccionado == 'Finalizado') {
      colorBadge = Colors.green;
    } else if (_estadoSeleccionado == 'En curso') {
      colorBadge = const Color(0xFF7FA9C4);
    } else {
      colorBadge = const Color(0xFFD4A373);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFECE3D4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D241E)),

        // Flecha de atrás: Solo cierra la pantalla, no guarda nada
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),

        actions: [
          IconButton(
            // Cambia el icono según si estamos editando o no
            icon: Icon(_editando ? Icons.close_rounded : Icons.edit_rounded),
            onPressed: () {
              setState(() {
                _editando = !_editando; // Activa/Desactiva el modo edición
              });
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            // 1. CABECERA: Portada y Datos Rápidos
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Portada con sombra
                Container(
                  height: 180,
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      widget.libro['portada'] ?? '',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Info rápida
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _editando
                          ? TextField(
                              controller: _tituloController,
                              decoration: const InputDecoration(
                                labelText: 'Título',
                              ),
                            )
                          : Text(
                              _tituloController.text,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      const SizedBox(height: 8),
                      _editando
                          ? TextField(
                              controller: _autorController,
                              decoration: const InputDecoration(
                                labelText: 'Autor',
                              ),
                            )
                          : Text(
                              _autorController.text,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                      const SizedBox(height: 15),

                      // Indicadores rápidos (Placeholder)
                      Row(
                        children: [
                          // Rating
                          const Icon(
                            Icons.star,
                            color: Colors.orange,
                            size: 18,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            widget.libro['rating'] ?? "0.0",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                            ),
                          ), // Páginas
                          const SizedBox(width: 15),
                          const Icon(
                            Icons.menu_book,
                            color: Colors.grey,
                            size: 18,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "${widget.libro['paginas'] ?? '0'} pag.",
                            style: GoogleFonts.inter(fontSize: 12),
                          ),
                          const SizedBox(width: 10),
                          // Lanzamiento
                          const Icon(
                            Icons.date_range_rounded,
                            color: Colors.grey,
                            size: 18,
                          ),
                          const SizedBox(width: 5),
                          _editando
                              ? SizedBox(
                                  width: 60,
                                  child: TextField(
                                    controller: _yearController,
                                    style: const TextStyle(fontSize: 12),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                )
                              : Text(
                                  _yearController.text,
                                  style: GoogleFonts.inter(fontSize: 12),
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // 2. SECCIÓN DE ESTADO Y ETIQUETAS
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  // Badge de estado actual
                  Chip(
                    label: Text(_estadoSeleccionado),
                    backgroundColor: colorBadge,
                    labelStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide.none,
                  ),
                  // Ejemplo de Etiquetas automáticas de la API
                  ...(widget.libro['genero'] == null ||
                              widget.libro['genero']!.isEmpty
                          ? 'General'
                          : widget.libro['genero']!)
                      .split(', ')
                      .map((nombreGenero) {
                        return Chip(
                          label: Text(nombreGenero),
                          backgroundColor: Colors.white70,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: const BorderSide(color: Colors.black12),
                        );
                      }).toList(),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const SizedBox(height: 20),

            // 3. TARJETA DE SINOPSIS
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white, // Fondo blanco como en la imagen
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.import_contacts,
                        color: Color(0xFF2D241E),
                      ), // Icono de libro abierto
                      const SizedBox(width: 10),
                      Text(
                        "Sinopsis",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: const Color(0xFF2D241E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    widget.libro['sinopsis'] ??
                        'No hay descripción disponible para este libro',
                    textAlign: TextAlign.justify,
                    style: GoogleFonts.inter(
                      height: 1.5,
                      color: const Color(0xFF4A4A4A),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
            const Divider(),
            const SizedBox(height: 25),

            // 4. TARJETA DE NOTAS PERSONALES
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: _editando ? 1.0 : 0.5),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: _editando ? const Color(0xFFD4A373) : Colors.black12,
                  width: _editando ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.edit_note, color: Color(0xFF2D241E)),
                      const SizedBox(width: 10),
                      Text(
                        "Mis Notas",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (_editando)
                    Column(
                      children: [
                        TextField(
                          controller: _notasController,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          decoration: const InputDecoration(
                            hintText: "Escribe tus pensamientos...",
                            border: InputBorder.none,
                          ),
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                        const SizedBox(height: 15),
                        // --- BOTÓN DE GUARDADO RÁPIDO ---
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // 1. Guardamos localmente el texto
                              widget.libro['notas'] = _notasController.text;

                              // 2. Quitamos el modo edición para congelar el texto
                              setState(() {
                                _editando = false;
                              });

                              // 3. ¡LLAMADA AL MAIN! Guardamos en el disco permanentemente
                              widget.onSave(widget.libro);

                              // 4. Feedback visual
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Nota guardada permanentemente",
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.check,
                              size: 18,
                              color: Colors.white,
                            ),
                            label: const Text(
                              "Confirmar nota",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2D241E),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      _notasController.text.isEmpty
                          ? "Toca el icono de editar arriba para escribir."
                          : _notasController.text,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontStyle: _notasController.text.isEmpty
                            ? FontStyle.italic
                            : FontStyle.normal,
                        color: _notasController.text.isEmpty
                            ? Colors.black38
                            : Colors.black87,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
