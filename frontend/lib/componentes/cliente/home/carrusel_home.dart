import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

/// Una diapositiva del carrusel del home.
class SlideHome {
  final String imagen; // URL de Cloudinary (o ruta de un asset local)
  final String etiqueta; // pastilla verde, ej. la categoría
  final String titulo;
  final String subtitulo;
  final VoidCallback? onTap;

  const SlideHome({
    required this.imagen,
    this.etiqueta = '',
    required this.titulo,
    this.subtitulo = '',
    this.onTap,
  });
}

/// Carrusel de imágenes del home: avanza solo cada pocos segundos y tiene puntos
/// indicadores. Si no hay diapositivas muestra un banner de motivación.
class CarruselHome extends StatefulWidget {
  final List<SlideHome> slides;
  final bool cargando;
  final double altura;
  final Duration cada;

  const CarruselHome({
    super.key,
    required this.slides,
    this.cargando = false,
    this.altura = 175,
    this.cada = const Duration(seconds: 4),
  });

  @override
  State<CarruselHome> createState() => _CarruselHomeState();
}

class _CarruselHomeState extends State<CarruselHome> {
  final PageController _controller = PageController(viewportFraction: 0.92);
  Timer? _timer;
  int _pagina = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.cada, (_) {
      if (!mounted || widget.slides.length < 2 || !_controller.hasClients) return;
      final siguiente = (_pagina + 1) % widget.slides.length;
      _controller.animateToPage(
        siguiente,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Widget _marco({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: child,
      ),
    );
  }

  Widget _imagen(String ruta) {
    // Fondo de reserva: se ve mientras carga la foto o si no se pudo cargar
    final vacio = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.verdePrimario.withOpacity(0.35), AppColors.grisOscuro],
        ),
      ),
      child: Center(
        child: Icon(Icons.fitness_center, color: AppColors.blancoPuro.withOpacity(0.25), size: 48),
      ),
    );

    if (ruta.isEmpty) return vacio;
    if (ruta.startsWith('assets/')) {
      return Image.asset(ruta, fit: BoxFit.cover, errorBuilder: (c, e, s) => vacio);
    }
    return Image.network(
      ruta,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progreso) => progreso == null ? child : vacio,
      errorBuilder: (c, e, s) => vacio,
    );
  }

  Widget _construirSlide(SlideHome slide) {
    return GestureDetector(
      onTap: slide.onTap,
      child: _marco(
        child: Stack(
          fit: StackFit.expand,
          children: [
            _imagen(slide.imagen),
            // Degradado para que el texto se lea sobre cualquier imagen
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
                  stops: const [0.35, 1.0],
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (slide.etiqueta.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.verdePrimario,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        slide.etiqueta.toUpperCase(),
                        style: const TextStyle(color: AppColors.fondoNegro, fontSize: 9.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    slide.titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.blancoPuro, fontSize: 17, fontWeight: FontWeight.bold, height: 1.15),
                  ),
                  if (slide.subtitulo.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      slide.subtitulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.grisClaro, fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Cuando todavía no hay ejercicios con imagen
  Widget _bannerMotivacion() {
    return _marco(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.verdePrimario.withOpacity(0.9), AppColors.grisOscuro],
          ),
        ),
        padding: const EdgeInsets.all(18),
        alignment: Alignment.bottomLeft,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TU MEJOR VERSIÓN\nEMPIEZA HOY',
              style: TextStyle(color: AppColors.fondoNegro, fontSize: 20, fontWeight: FontWeight.w900, height: 1.1),
            ),
            SizedBox(height: 4),
            Text(
              'Cada entrenamiento cuenta.',
              style: TextStyle(color: AppColors.fondoNegro, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cargando) {
      return SizedBox(
        height: widget.altura,
        child: _marco(
          child: Container(
            color: AppColors.grisOscuro,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.verdePrimario, strokeWidth: 2.5),
            ),
          ),
        ),
      );
    }

    if (widget.slides.isEmpty) {
      return SizedBox(height: widget.altura, child: _bannerMotivacion());
    }

    return Column(
      children: [
        SizedBox(
          height: widget.altura,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.slides.length,
            onPageChanged: (i) => setState(() => _pagina = i),
            itemBuilder: (context, index) => _construirSlide(widget.slides[index]),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.slides.length, (i) {
            final activo = i == _pagina;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: activo ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: activo ? AppColors.verdePrimario : AppColors.grisMedio,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}
