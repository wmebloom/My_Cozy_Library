import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>(); // Para validación

  // Controladores para captura de texto
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _urlController = TextEditingController();

  String _selectedStatus = 'Pendiente'; // Valor por defecto

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Añadir nuevo libro")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Input Titulo
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título del libro',
                ),
                validator: (value) => value!.isEmpty ? 'Pon un título' : null,
              ),
              const SizedBox(height: 15),

              // Input Autor
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: 'Autor'),
                validator: (value) =>
                    value!.isEmpty ? '¿Quién lo escribió?' : null,
              ),
              const SizedBox(height: 15),

              // Input URL
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'URL de la portada',
                ),
              ),
              const SizedBox(height: 20),

              // Selector de estado
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Estado actual'),
                items: ['Pendiente', 'En curso', 'Finalizado'].map((
                  String value,
                ) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedStatus = newValue!;
                  });
                },
              ),

              // Botón de guardar
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveBook,
                child: const Text("Guardar libro"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveBook() {
    if (_formKey.currentState!.validate()) {

      // Pasamos el nuevo libro como resultado
      Navigator.pop(context, {
        'titulo': _titleController.text,
        'autor': _authorController.text,
        'url': _urlController.text,
        'estado': _selectedStatus,
      });
    }
  }
}
