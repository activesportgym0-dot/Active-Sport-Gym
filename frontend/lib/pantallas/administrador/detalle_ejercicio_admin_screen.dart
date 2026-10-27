import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/componentes/fondo.dart';
import 'package:frontend/componentes/cliente/entrenar/detalle_seccion_card.dart';
import 'package:frontend/services/ejercicio_service.dart';

class DetalleEjercicioAdminScreen extends StatefulWidget {
  final Map<String, dynamic> ejercicio;
  final VoidCallback? onEditar;
  final VoidCallback? onEliminar;

  const DetalleEjercicioAdminScreen({
    super.key,
    required this.ejercicio,
    this.onEditar,
    this.onEliminar,
  });

  @override
  State<DetalleEjercicioAdminScreen> createState() =>
      _DetalleEjercicioAdminScreenState();
}

class _DetalleEjercicioAdminScreenState
    extends State<DetalleEjercicioAdminScreen> {
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
    // Datos principales que vienen directamente del backend
    final String nombre = widget.ejercicio['nombre'] ?? '';
    final String imagen = widget.ejercicio['imagen'] ?? '';
    final String gifUrl = widget.ejercicio['gif_url'] ?? '';
    final String maquina = widget.ejercicio['maquina'] ?? '';

    // Extracción de categorías desde la relación del backend
    List<dynamic> relacionesCategorias = widget.ejercicio['ejercicio_categoria'] ?? [];
    List<String> nombresCategorias = [];
    for (var rel in relacionesCategorias) {
      if (rel['categoria_ejercicios'] != null &&
          rel['categoria_ejercicios']['nombre'] != null) {
        nombresCategorias.add(rel['categoria_ejercicios']['nombre']);
      }
    }
    final String categoriasTexto = nombresCategorias.join(' • ');

    // Campos detallados puros directamente de la base de datos (sin textos inventados)
    final String descripcion = widget.ejercicio['descripcion'] ?? '';
    final String comoSeHace = widget.ejercicio['instrucciones'] ?? '';
    final String beneficios = widget.ejercicio['beneficios'] ?? '';
    final String rangoMovimiento = widget.ejercicio['rango_movimiento'] ?? '';
    final String respiracion = widget.ejercicio['respiracion'] ?? '';
    final String ritmo = widget.ejercicio['ritmo_movimiento'] ?? '';

    final List<Map<String, String>> listaMidia = [
      if (imagen.isNotEmpty) {'tipo': 'Imagen Principal', 'url': imagen},
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
                    // 1. Visor de Multimedia (Solo si hay elementos)
                    if (listaMidia.isNotEmpty) ...[
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 280,
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

                          Positioned(
                            bottom: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: AppColors.verdePrimario.withOpacity(0.5)),
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
                    ],

                    // 2. Categorías y Máquina (Solo si contienen datos del backend)
                    Row(
                      children: [
                        if (categoriasTexto.isNotEmpty)
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
                        if (categoriasTexto.isNotEmpty && maquina.isNotEmpty)
                          const SizedBox(width: 10),
                        if (maquina.isNotEmpty)
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

                    if (categoriasTexto.isNotEmpty || maquina.isNotEmpty)
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

              // 4. Botones inferiores
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.fondoNegro,
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.redAccent, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            bool? confirmar = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: AppColors.grisOscuro,
                                title: const Text('Eliminar Ejercicio', style: TextStyle(color: Colors.white)),
                                content: const Text('¿Estás segura de que deseas eliminar este ejercicio?', style: TextStyle(color: Colors.white70)),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
                                  ),
                                ],
                              ),
                            );

                            if (confirmar == true) {
                              int id = widget.ejercicio['id_ejercicio'] ?? 0;
                              bool eliminado = await EjercicioService.eliminarEjercicio(id);
                              
                              if (eliminado && context.mounted) {
                                // 1. Primero cerramos la pantalla de detalles de forma segura
                                Navigator.pop(context); 
                                
                                // 2. Luego ejecutamos el callback para refrescar la lista en la pantalla anterior
                                if (widget.onEliminar != null) {
                                  widget.onEliminar!();
                                }
                              } else if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('No se pudo eliminar el ejercicio'), backgroundColor: Colors.redAccent),
                                );
                              }
                            }
                          },
                          child: const Text(
                            'ELIMINAR',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.verdePrimario,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: widget.onEditar ?? () {},
                          child: const Text(
                            'EDITAR',
                            style: TextStyle(
                              color: AppColors.fondoNegro,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}