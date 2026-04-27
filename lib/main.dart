import 'package:flutter/material.dart'; // Libreria de estilos
import 'package:google_fonts/google_fonts.dart';
import 'screens/add_book_screen.dart';
import 'dart:convert'; // Convertir lista a JSON
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/book_details_screen.dart';
import 'screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const PantallaInicio(),
      },
    ),
  );
}

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  // Controlador para manejar lo que escribimos
  final TextEditingController _controladorBusqueda = TextEditingController();
  String _filtroPaginasSeleccionado = 'Todos';
  String _filtroEstadoSeleccionado = 'Todos';

  // La lista completa de libros
  List<Map<String, String>> _todosLosLibros = [
    {
      'titulo': 'Red Rising',
      'autor': 'Pierce Brown',
      'estado': 'En curso',
      'paginas': '691',
      'portada':
          'https://imgs.search.brave.com/I0TTusHl2le3UiyYEoTvqUIrreHgjGHXBGa6XfV5eYU/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9pbWFn/ZXM0LnBlbmd1aW5y/YW5kb21ob3VzZS5j/b20vY292ZXIvOTc4/MDM0NTUzOTgwOQ',
    },
    {
      'titulo': 'Mistborn',
      'autor': 'Brandon Sanderson',
      'estado': 'Finalizado',
      'paginas': '425',
      'portada':
          'https://imgs.search.brave.com/bv89cP1ICmHPR3i03OX-8-fVaLV6XulE73_B_QwENqo/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly93d3cu/bm9sbGVnaXUuY29t/L2VzL2ltYWdlbmVz/Lzk3ODg0MTMvOTc4/ODQxMzE0MzE5Lndl/YnA',
    },
    {
      'titulo': 'Nuncanoche',
      'autor': 'Jay Kristoff',
      'estado': 'En curso',
      'paginas': '540',
      'portada':
          'https://imgs.search.brave.com/1lQtdpANxEEtx8FduzeuInUnbYH0qXhFYWfOOMb1oBg/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly90aWVu/ZGEubm9jdHVybmFl/ZGljaW9uZXMuY29t/L2Nkbi9zaG9wL3By/b2R1Y3RzLzI2OF9h/bHRhXzEwMjR4MTAy/NEAyeC5qcGc_dj0x/NjE0NTkwNzg3',
    },
    {
      'titulo': 'El nombre del viento',
      'autor': 'Patric Rothfuss',
      'paginas': '5',
      'estado': 'Pendiente',
    },
  ];

  // La lista que se muestra
  List<Map<String, String>> _librosFiltrados = [] = <Map<String, String>>[];
  @override
  void initState() {
    super.initState();
    cargarLibros();
    _librosFiltrados = _todosLosLibros;
  }

  // Función para la lógica de los filtros
  void _aplicarFiltros() {
    setState(() {
      _librosFiltrados = _todosLosLibros.where((libro) {
        // 1. Lógica del Buscador
        final textoBusqueda = _controladorBusqueda.text.toLowerCase();
        final coincideBusqueda =
            libro['titulo']!.toLowerCase().contains(textoBusqueda) ||
            libro['autor']!.toLowerCase().contains(textoBusqueda);

        // 2. Filtro de páginas
        int numPaginas = int.tryParse(libro['paginas'] ?? '0') ?? 0;
        bool coincidePaginas = true;

        if (_filtroPaginasSeleccionado.contains('Cortos')) {
          coincidePaginas = numPaginas < 300;
        } else if (_filtroPaginasSeleccionado.contains('Medios')) {
          coincidePaginas = numPaginas >= 300 && numPaginas <= 600;
        } else if (_filtroPaginasSeleccionado.contains('Largos')) {
          coincidePaginas = numPaginas > 600;
        }

        // Filtro de estado
        bool coincideEstado = true;
        if (_filtroEstadoSeleccionado != 'Todos') {
          coincideEstado = libro['estado'] == _filtroEstadoSeleccionado;
        }

        return coincideBusqueda && coincidePaginas && coincideEstado;
      }).toList();
    });
  }

  Widget build(BuildContext context) {
    // Lógica para ordenar por defecto -- 'En curso': 0 || 'Pendiente': 1 || 'Finalizado': 2
    _librosFiltrados.sort((a, b) {
      Map<String, int> prioridades = {
        'En curso': 0,
        'Pendiente': 1,
        'Finalizado': 2,
      };

      // Obtenemos el peso de cada libro
      int pesoA = prioridades[a['estado']] ?? 3;
      int pesoB = prioridades[b['estado']] ?? 3;

      // Ordenamos los libros por el peso de cada estado
      if (pesoA != pesoB) {
        return pesoA.compareTo(pesoB);
        // Si el estado es el mismo, los ordenamos por titulo (orden alfabético)
      } else {
        return a['titulo']!.compareTo(b['titulo']!);
      }
    });

    List<Widget> tarjetas = _librosFiltrados.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, String> libro = entry.value;

      print("Pintando libro: ${libro['titulo']} - ${libro['autor']}");

      return GestureDetector(
        onLongPress: () {
          _confirmarBorrado(context, index);
        },
        onTap: () async {
          // 1. Navegamos y esperamos el resultado
          final resultadoEditado = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookDetailsScreen(
                libro: libro,
                onSave: (libroActualizado) {
                  setState(() {
                    int indiceReal = _todosLosLibros.indexOf(libro);
                    if (indiceReal != -1) {
                      _todosLosLibros[indiceReal] = Map<String, String>.from(
                        libroActualizado,
                      );
                      _librosFiltrados = List.from(_todosLosLibros);
                    }
                  });

                  guardarLibros();
                },
              ),
            ),
          );

          // 2. Si el usuario guardó cambios, actualizamos
          if (resultadoEditado != null &&
              resultadoEditado is Map<String, String>) {
            setState(() {
              // Buscamos la posición real del libro y lo reemplazamos
              int indiceReal = _todosLosLibros.indexOf(libro);
              if (indiceReal != -1) {
                _todosLosLibros[indiceReal] = Map<String, String>.from(
                  resultadoEditado,
                );
                _librosFiltrados = List.from(_todosLosLibros);
              }
            });

            // 3. Guardamos en el dispositivo
            guardarLibros();
          }
        },
        //----------------------------
        child: crearTarjetaLibro(
          libro['titulo'] ?? 'Sin título',
          libro['autor'] ?? 'Sin autor',
          libro['estado'] ?? 'Pendiente',
          libro['portada'] ?? 'https://via.placeholder.com/50x70',
          context,
        ),
      );
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFECE3D4),
      body: SafeArea(
        child: SingleChildScrollView(
          // overflow-y: scroll
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.start, // deberia ser el valor por defecto lol
            children: [
              // Titulo principal Decoración
              Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  40,
                  20,
                  40,
                ), // left, top, right, bottom
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Mis libros',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D241E),
                    ),
                  ),
                ),
              ),

              // El buscador Decoración
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 29,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    // BUSCADOR
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF302010,
                              ).withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _controladorBusqueda,
                          onChanged: (valor) {
                            _aplicarFiltros();
                          },
                          decoration: InputDecoration(
                            hintText: 'Buscar...',
                            hintStyle: GoogleFonts.inter(
                              color: Colors.grey[400],
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Color(0xFF70665E),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // BOTÓN DE FILTROS
                    GestureDetector(
                      onTap: () => _abrirFiltros(context),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D241E),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF302010,
                              ).withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.tune_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 1. Espacio después del buscador
              const SizedBox(height: 20),

              ...tarjetas,

              if (_librosFiltrados.isEmpty)
                Center(
                  child: Text(
                    'No hemos encontrado ese libro/autor...',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      color: Color(0xFF2D241E),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),

      // Barra de navegación inferior
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF4E3B31), // color de la barra
        selectedItemColor: const Color(0xFFD4A373), // color icono activo
        unselectedItemColor: Colors.white.withValues(
          alpha: 0.5,
        ), // color inconos no activos
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,

        // Evento para ir al formulario de añadir libro
        onTap: (index) async {
          if (index == 2) {
            final resultado = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddBookScreen()),
            );

            if (resultado != null) {
              setState(() {
                Map<String, String> nuevoLibro = {
                  'titulo': resultado['titulo'] ?? 'Sin título',
                  'autor': resultado['autor'] ?? 'Anónimo',
                  'estado': resultado['estado'] ?? 'Pendiente',
                  'portada':
                      resultado['portada'] ??
                      'https://via.placeholder.com/50x70',
                  'lanzamiento': resultado['lanzamiento'] ?? '----',
                  'rating': resultado['rating'] ?? '0.0',
                  'paginas': resultado['paginas'] ?? '0',
                  'sinopsis':
                      resultado['sinopsis'] ?? 'Sin sinopsis disponible',
                  'genero': resultado['genero'] ?? 'General',
                };

                _todosLosLibros.add(nuevoLibro);
                // Actualiamos tambien los filtrados
                _librosFiltrados = List.from(_todosLosLibros);
              });

              guardarLibros();
            }
          }
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_outline),
            label: 'Guardados',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Añadir',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }

  // Función para guardar la lista entera al añadir algo
  Future<void> guardarLibros() async {
    final prefs = await SharedPreferences.getInstance();

    final String datosCodificados = json.encode(_todosLosLibros);
    await prefs.setString('mis_libros_biblioteca', datosCodificados);
    print("Libros guardados en el dispositivo!");
  }

  // Función para leer el String de guardarLibros()
  Future<void> cargarLibros() async {
    final prefs = await SharedPreferences.getInstance();
    final String? datosObtenidos = prefs.getString('mis_libros_biblioteca');

    if (datosObtenidos != null) {
      setState(() {
        List<dynamic> listaDecodificada = json.decode(datosObtenidos);

        _todosLosLibros = listaDecodificada.map((item) {
          return Map<String, String>.from(item);
        }).toList();

        _librosFiltrados = List.from(_todosLosLibros);
      });

      print("Libros cargados correctamente");
    }
  }

  // Función para la ventana de confirmación de borrado
  void _confirmarBorrado(BuildContext context, int index) {
    final String tituloLibro =
        _librosFiltrados[index]['titulo'] ?? 'Sin titulo';
    final String autorLibro =
        _librosFiltrados[index]['autor'] ?? 'Autor desconocido';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFECE3D4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          // Título centrado
          title: Text(
            '¿Eliminar libro?',
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: const Color(0xFF2D241E),
            ),
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¿Estás seguro de que quieres borrar',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 15),
              ),
              const SizedBox(height: 5),
              Text(
                '"$tituloLibro"',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),

              Text(
                'de $autorLibro?',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 15),
              ),
            ],
          ),

          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: GoogleFonts.inter(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              onPressed: () {
                _ejecutarBorrado(index);
                Navigator.pop(context);
              },
              child: Text(
                'Eliminar',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // FUnción para abrir los filtros
  void _abrirFiltros(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFECE3D4),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        // 1. Envolvemos todo en un StatefulBuilder
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              maxChildSize: 0.9,
              minChildSize: 0.4,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Barra gris superior
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Filtrar por...",
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2D241E),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Filtro por Páginas
                      _seccionFiltro(
                        titulo: "Extensión",
                        opciones: [
                          "Todos",
                          "Cortos (<300)",
                          "Medios (300-600)",
                          "Largos (>600)",
                        ],
                        seleccionActual: _filtroPaginasSeleccionado,
                        alCambiar: (valor) {
                          setModalState(
                            () => _filtroPaginasSeleccionado = valor,
                          ); // Refresca el Modal
                          setState(
                            () => _filtroPaginasSeleccionado = valor,
                          ); // Refresca la Pantalla principal
                        },
                      ),
                      const SizedBox(height: 20),

                      // Filtro por Estado
                      _seccionFiltro(
                        titulo: "Estado",
                        opciones: [
                          "Todos",
                          "En curso",
                          "Finalizado",
                          "Pendiente",
                        ],
                        seleccionActual: _filtroEstadoSeleccionado,
                        alCambiar: (valor) {
                          setModalState(
                            () => _filtroEstadoSeleccionado = valor,
                          );
                          setState(() => _filtroEstadoSeleccionado = valor);
                        },
                      ),

                      const SizedBox(height: 30),

                      // Botón aplicar
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            _aplicarFiltros(); // Solo aplicamos al pulsar aquí
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2D241E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            "Ver resultados",
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _seccionFiltro({
    required String titulo,
    required List<String> opciones,
    required String seleccionActual,
    required Function(String) alCambiar,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: opciones.map((opcion) {
            bool esSeleccionado = seleccionActual == opcion;
            return ChoiceChip(
              label: Text(opcion),
              selected: esSeleccionado,
              selectedColor: const Color(0xFFD4A373),
              backgroundColor: Colors.white,
              onSelected: (bool seleccionado) {
                alCambiar(seleccionado ? opcion : 'Todos');
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // Función para ejecutar el borrado
  void _ejecutarBorrado(int index) {
    setState(() {
      // Libro a borrar
      final libroABorrar = _librosFiltrados[index];

      // Lo borramos de la lista principal
      _todosLosLibros.removeWhere(
        (libro) =>
            libro['titulo'] == libroABorrar['titulo'] &&
            libro['autor'] == libroABorrar['autor'],
      );

      // Lo borramos de la lista filtrada
      _librosFiltrados.removeAt(index);
    });

    guardarLibros();
  }
}

// Función crear tarjetas
//------------------------------------------------------------------------------------------------------------------
Widget crearTarjetaLibro(
  String titulo,
  String autor,
  String estado,
  String urlPortada,
  BuildContext context,
) {
  // Definir color de estado
  Color colorBadge;

  if (estado == 'Finalizado') {
    colorBadge = Colors.green;
  } else if (estado == 'En curso') {
    colorBadge = const Color(0xFF7FA9C4);
  } else if (estado == 'Pendiente') {
    colorBadge = const Color(0xFFD4A373);
  } else {
    colorBadge = Colors.grey;
  }

  return Container(
    margin: const EdgeInsets.only(bottom: 16, left: 29, right: 20),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Color(0xFF302010).withValues(alpha: 0.2),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        //Portada con gesture detector para ponerla en grande al pulsar en ella
        GestureDetector(
          onTap: () {
            if (urlPortada.isNotEmpty && !urlPortada.contains('placeholder')) {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  backgroundColor: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Imagen grandota
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(urlPortada),
                      ),
                      const SizedBox(height: 10),

                      // Botón para cerrar
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          '',
                          style: GoogleFonts.inter(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              urlPortada,
              width: 50,
              height: 70,
              fit: BoxFit.cover,

              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 50,
                  height: 70,
                  color: Colors.grey[300],
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 15),
        //Textos
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 5),
              Text(autor, style: GoogleFonts.inter(color: Colors.grey)),
            ],
          ),
        ),
        // Badge estados
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: colorBadge,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            estado,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}

//---------------------------------------------------------------------------------------------------------------------------------------------------
