import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/google_books_service.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _urlController = TextEditingController();
  final _yearController = TextEditingController();
  final _googleService = GoogleBooksService();
  List<Map<String, String>> _sugerencias = [];
  bool _buscando = false;

  Map<String, String>? _libroSeleccionado;

  String _selectedStatus = 'Pendiente';

  // Esto es para que la imagen se actualice mientras se escribe la URL
  String _tempUrl = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE3D4), // Mismo fondo que el inicio
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2D241E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Nuevo Libro',
          style: GoogleFonts.playfairDisplay(
            color: const Color(0xFF2D241E),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Previsualización de la Portada
              Center(
                child: Container(
                  width: 120,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: _tempUrl.isNotEmpty
                        ? Image.network(
                            _tempUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) => const Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          )
                        : const Icon(
                            Icons.book,
                            size: 50,
                            color: Color(0xFFD4A373),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Campo Título
              _buildLabel('Título del libro'),
              TextFormField(
                controller: _titleController,
                onChanged: (value) async {
                  if (value.length > 2) {
                    setState(() => _buscando = true);
                    final resultados = await _googleService.buscar(value);
                    setState(() {
                      _sugerencias = resultados;
                      _buscando = false;
                    });
                  } else {
                    setState(() => _sugerencias = []);
                  }
                },

                style: GoogleFonts.inter(
                  color: const Color(0xFF2D241E),
                  fontSize: 13,
                ),
                decoration: _inputStyle(
                  'Ej: El nombre del viento',
                  _titleController,
                  _buscando,
                ),
              ),
              // Lista de sugerencias
              if (_sugerencias.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 5),
                    ],
                  ),
                  child: Column(
                    // Usamos .map para convertir cada libro en un ListTile
                    children: _sugerencias.map((libro) {
                      // Extraemos los datos con valores por defecto por si Google falla
                      final String titulo = libro['titulo'] ?? 'Sin título';
                      final String autor =
                          libro['autor'] ?? 'Autor desconocido';
                      final String portada = libro['portada'] ?? '';

                      return ListTile(
                        leading: portada.isNotEmpty
                            ? Image.network(
                                portada,
                                width: 40,
                                // Si la URL de la imagen falla al cargar, ponemos un icono
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image, size: 30),
                              )
                            : const Icon(Icons.book),
                        title: Text(
                          titulo,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          autor,
                          style: const TextStyle(fontSize: 11),
                        ),
                        onTap: () {
                          setState(() {
                            _titleController.text = titulo;
                            _authorController.text = autor;
                            _urlController.text = libro['portada'] ?? '';
                            _tempUrl = libro['portada'] ?? '';
                            _yearController.text = libro['lanzamiento'] ?? '';

                            // Guardamos el libro actual para los datos extra (páginas, fecha)
                            _libroSeleccionado = Map<String, String>.from(libro);

                            // Vaciamos la lista para que desaparezca el desplegable
                            _sugerencias = [];
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),

              const SizedBox(height: 20),

              // Campo Autor
              _buildLabel('Autor/a'),
              _buildTextField(_authorController, 'Ej: Patrick Rothfuss'),

              const SizedBox(height: 20),

              _buildLabel('Año de publicación'),
              _buildTextField(_yearController, 'Ej: 2012'),
              const SizedBox(height: 20),

              // Campo URL con listener para la imagen
              _buildLabel('URL de la portada'),
              TextFormField(
                controller: _urlController,
                onChanged: (val) => setState(() => _tempUrl = val),
                decoration: _inputStyle(
                  'Pega el enlace de la imagen...',
                  _urlController,
                ),
              ),

              const SizedBox(height: 20),

              // Selector de Estado (Dropdown)
              _buildLabel('Estado de lectura'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedStatus,
                    isExpanded: true,
                    items: ['Pendiente', 'En curso', 'Finalizado'].map((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() => _selectedStatus = newValue!);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Botón Guardar
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _saveBook,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4E3B31),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Guardar en mi biblioteca',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //  WIDGETS DE APOYO PARA NO REPETIR CÓDIGO

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2D241E),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextFormField(
      controller: controller,
      onChanged: (value) => setState(() {}),
      // Estilo texto escribe user
      style: GoogleFonts.inter(color: const Color(0xFF2D241E), fontSize: 13),
      decoration: _inputStyle(hint, controller),
      validator: (val) =>
          val == null || val.isEmpty ? 'Campo obligatorio' : null,
    );
  }

  InputDecoration _inputStyle(
    String hint,
    TextEditingController controller, [
    bool buscando = false,
  ]) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        color: const Color(0xFF2D241E).withOpacity(0.4),
        fontSize: 13,
      ),

      // UN SOLO suffixIcon con toda la lógica combinada
      suffixIcon: buscando
          ? const Padding(
              padding: EdgeInsets.all(12.0),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFD4A373),
                ),
              ),
            )
          : (controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.cancel,
                      size: 18,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      controller.clear();
                      setState(() {
                        // Limpiamos la previsualización si es el controlador de la URL
                        if (controller == _urlController) _tempUrl = '';
                        // Limpiamos sugerencias si borramos el título
                        if (controller == _titleController) _sugerencias = [];
                      });
                    },
                  )
                : null),

      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  void _saveBook() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'titulo': _titleController.text,
        'autor': _authorController.text,
        'portada': _urlController.text,
        'estado': _selectedStatus,
        'lanzamiento': _yearController.text,
        'paginas': _libroSeleccionado?['paginas'] ?? '0',
        'rating': _libroSeleccionado?['rating'] ?? '0.0',
        'sinopsis': _libroSeleccionado?['sinopsis'] ?? 'Sin sinopsis.',
        'genero' : _libroSeleccionado?['genero'] ?? 'General',
      });
    }
  }
}
