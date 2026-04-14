import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  String _selectedStatus = 'Pendiente';

  // Esto es para que la imagen se actualice mientras escribes la URL
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
                            errorBuilder: (context, error, stack) => 
                              const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                          )
                        : const Icon(Icons.book, size: 50, color: Color(0xFFD4A373)),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Campo Título
              _buildLabel('Título del libro'),
              _buildTextField(_titleController, 'Ej: El nombre del viento'),
              
              const SizedBox(height: 20),

              // Campo Autor
              _buildLabel('Autor/a'),
              _buildTextField(_authorController, 'Ej: Patrick Rothfuss'),

              const SizedBox(height: 20),

              // Campo URL con listener para la imagen
              _buildLabel('URL de la portada'),
              TextFormField(
                controller: _urlController,
                onChanged: (val) => setState(() => _tempUrl = val),
                decoration: _inputStyle('Pega el enlace de la imagen...'),
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
                    items: ['Pendiente', 'En curso', 'Finalizado'].map((String value) {
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

  // --- WIDGETS DE APOYO PARA NO REPETIR CÓDIGO ---

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
      decoration: _inputStyle(hint),
      validator: (val) => val == null || val.isEmpty ? 'Campo obligatorio' : null,
    );
  }

  InputDecoration _inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
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
        'url': _urlController.text,
        'estado': _selectedStatus,
      });
    }
  }
}