import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/componentes/fondo.dart';
import 'package:frontend/componentes/cliente/entrenar/detalle_seccion_card.dart';
import 'package:frontend/pantallas/cliente/rutina/diaria/crear_rutina_diaria_screen.dart';
import 'package:frontend/componentes/cliente/asistente/burbuja_mini_chat_modal.dart';

class DetalleEjercicioClienteScreen extends StatefulWidget {
  final Map<String, dynamic> ejercicio;

  const DetalleEjercicioClienteScreen({
    super.key,
    required this.ejercicio,
  });

  @override
  State<DetalleEjercicioClienteScreen> createState() =>
      _DetalleEjercicioClienteScreenState();
}

class _DetalleEjercicioClienteScreenState
    extends State<DetalleEjercicioClienteScreen> {
  final PageController _pageController = PageController();
  int _paginaActual = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _construirMidia(String ruta) {
    if (ruta.isEmpty) {
      return const Center(
        child: Icon(Icons.fitness_center, color: Colors.white54, size: 60),
      );
    }
    if (ruta.startsWith('assets/')) {
      return Image.asset(
        ruta,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (c, e, s) => const Center(
          child: Icon(Icons.fitness_center, color: Colors.white54, size: 60),
        ),
      );
    } else {
      return Image.network(
        ruta,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (c, e, s) => const Center(
          child: Icon(Icons.fitness_center, color: Colors.white54, size: 60),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String nombre = widget.ejercicio['nombre'] ?? 'EJERCICIO';
    final String imagen =
        widget.ejercicio['imagen'] ?? 'assets/images/3.jpg';
    final String gifUrl = widget.ejercicio['gif_url'] ?? '';
    final String maquina =
        widget.ejercicio['maquina'] ?? 'Peso libre / Sin máquina específica';

    // Extracción de categorías
    List<dynamic> relacionesCategorias =
        widget.ejercicio['ejercicio_categoria'] ?? [];
    List<String> nombresCategorias = [];
    for (var rel in relacionesCategorias) {
      if (rel['categoria_ejercicios'] != null &&
          rel['categoria_ejercicios']['nombre'] != null) {
        nombresCategorias.add(rel['categoria_ejercicios']['nombre']);
      }
    }
    final String categoriasTexto = nombresCategorias.isNotEmpty
        ? nombresCategorias.join(' • ')
        : 'SIN CATEGORÍA';

    final String descripcion =
        widget.ejercicio['descripcion'] ?? 'Sin descripción disponible.';
    final String comoSeHace = widget.ejercicio['instrucciones'] ??
        'Sigue las indicaciones del entrenador.';
    final String beneficios =
        widget.ejercicio['beneficios'] ?? 'Mejora la condición física general.';
    final String rangoMovimiento = widget.ejercicio['rango_movimiento'] ??
        'Mantén el control durante todo el recorrido.';
    final String respiracion = widget.ejercicio['respiracion'] ??
        'Inhala al bajar, exhala al hacer el esfuerzo.';
    final String ritmo = widget.ejercicio['ritmo_movimiento'] ??
        'Ejecuta el movimiento de forma fluida y controlada.';

    final List<Map<String, String>> listaMidia = [
      {'tipo': 'Imagen Principal', 'url': imagen},
      if (gifUrl.isNotEmpty) {'tipo': 'Demostración (Video/GIF)', 'url': gifUrl},
    ];

    return Scaffold(
      backgroundColor: AppColors.fondoNegro,
      appBar: AppBar(
        backgroundColor: AppColors.fondoNegro,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.verdePrimario, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          nombre.toUpperCase(),
          style: EstiloTexto.tekoTituloSeccion.copyWith(fontSize: 18),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: FondoApp(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // 1. Visor de Imagen / Demostración en Video con Desplazamiento
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 220,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.grisOscuro.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppColors.verdePrimario.withOpacity(0.3)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: listaMidia.length,
                              onPageChanged: (index) {
                                setState(() {
                                  _paginaActual = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                return _construirMidia(
                                    listaMidia[index]['url']!);
                              },
                            ),
                          ),
                        ),

                        // Flecha Izquierda
                        if (_paginaActual > 0)
                          Positioned(
                            left: 8,
                            child: CircleAvatar(
                              backgroundColor: Colors.black.withOpacity(0.6),
                              radius: 18,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.arrow_back_ios_new,
                                    color: AppColors.verdePrimario, size: 16),
                                onPressed: () {
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                              ),
                            ),
                          ),

                        // Flecha Derecha
                        if (_paginaActual < listaMidia.length - 1)
                          Positioned(
                            right: 8,
                            child: CircleAvatar(
                              backgroundColor: Colors.black.withOpacity(0.6),
                              radius: 18,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.arrow_forward_ios,
                                    color: AppColors.verdePrimario, size: 16),
                                onPressed: () {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                              ),
                            ),
                          ),

                        // Etiqueta indicadora del tipo de media
                        Positioned(
                          bottom: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color:
                                      AppColors.verdePrimario.withOpacity(0.5)),
                            ),
                            child: Text(
                              listaMidia[_paginaActual]['tipo']!,
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 2. Categorías y Máquina requerida estilo Badges
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.grisOscuro,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.grey.withOpacity(0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'CATEGORÍAS',
                                  style: TextStyle(
                                    color: AppColors.verdePrimario,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  categoriasTexto,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.grisOscuro,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.grey.withOpacity(0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'MÁQUINA / EQUIPO',
                                  style: TextStyle(
                                    color: AppColors.verdePrimario,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  maquina,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 3. Secciones Informativas
                    DetalleSeccionCard(
                      titulo: 'Descripción',
                      contenido: descripcion,
                      icono: Icons.home_repair_service_outlined,
                    ),

                    DetalleSeccionCard(
                      titulo: '¿Cómo se hace?',
                      contenido: comoSeHace,
                      icono: Icons.help_outline,
                    ),

                    DetalleSeccionCard(
                      titulo: 'Beneficios',
                      contenido: beneficios,
                      icono: Icons.star_border,
                    ),

                    DetalleSeccionCard(
                      titulo: 'Rango de Movimiento Ideal',
                      contenido: rangoMovimiento,
                      icono: Icons.swap_vert,
                    ),

                    DetalleSeccionCard(
                      titulo: 'El Papel de la Respiración',
                      contenido: respiracion,
                      icono: Icons.air,
                    ),

                    DetalleSeccionCard(
                      titulo: 'Ritmo de Movimiento',
                      contenido: ritmo,
                      icono: Icons.timer_outlined,
                    ),
                  ],
                ),
              ),

              // 4. Botón Inferior
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.fondoNegro,
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.verdePrimario,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CrearRutinaDiariaScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'CREAR RUTINA',
                      style: TextStyle(
                        color: AppColors.fondoNegro,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: const BurbujaMiniChatModal(),
    );
  }
}