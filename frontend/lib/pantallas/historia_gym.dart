import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/componentes/fondo.dart';

class HistoriaGymScreen extends StatefulWidget {
  const HistoriaGymScreen({super.key});

  @override
  State<HistoriaGymScreen> createState() => _HistoriaGymScreenState();
}

class _HistoriaGymScreenState extends State<HistoriaGymScreen> {
  // ───────────── DATOS DEL GIMNASIO (edítalos aquí) ─────────────

  // Fotos del carrusel: assets/images/11.jpeg ... 21.jpeg
  // Si alguna no es del gimnasio, quítala o cambia el rango de esta lista.
  final List<String> _galeria = List.generate(11, (i) => 'assets/images/${i + 11}.jpeg');

  // Ubicación y contacto según la ficha del gimnasio en Google Maps
  static const LatLng _ubicacionGym = LatLng(2.193036, -75.638957);
  static const String _direccion = 'Cl. 7 Sur #16a-2 a 16a-104\nGarzón, Huila, Colombia';
  static const String _telefono = '316 532 3349';

  // ───────────── CARRUSEL ─────────────
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);

    // Auto-desplazamiento del carrusel cada 4 segundos
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_pageController.hasClients || _galeria.isEmpty) return;
      final siguiente = (_currentPage + 1) % _galeria.length;
      _pageController.animateToPage(
        siguiente,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // Abre una foto en pantalla completa; se puede hacer zoom con dos dedos
  void _verImagen(String ruta) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogContext) => Dialog.fullscreen(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.pop(dialogContext),
              ),
            ),
            Center(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                child: Image.asset(ruta, fit: BoxFit.contain),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: AppColors.blancoPuro, size: 28),
                  onPressed: () => Navigator.pop(dialogContext),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────── PIEZAS DE DISEÑO REUTILIZABLES ─────────────

  Widget _tituloSeccion(IconData icono, String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icono, color: AppColors.verdePrimario, size: 20),
          const SizedBox(width: 8),
          Text(
            texto,
            style: const TextStyle(
              fontFamily: 'Oswald',
              color: AppColors.verdePrimario,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.verdePrimario.withValues(alpha: 0.25),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarjeta({required Widget child, Color? borde}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.grisOscuro,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: (borde ?? AppColors.verdePrimario).withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  TextStyle get _estiloCuerpo => EstiloTexto.textoNormalRoboto.copyWith(
        color: AppColors.blancoPuro,
        fontSize: 13,
        height: 1.55,
      );

  TextSpan _verde(String texto) => TextSpan(
        text: texto,
        style: const TextStyle(color: AppColors.verdePrimario, fontWeight: FontWeight.bold),
      );

  Widget _pildora(String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.fondoNegro.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.verdePrimario.withValues(alpha: 0.7)),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontFamily: 'Oswald',
          color: AppColors.blancoPuro,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _dato(String grande, String pequeno) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.grisOscuro,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.verdePrimario.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              grande,
              style: const TextStyle(
                fontFamily: 'Oswald',
                color: AppColors.verdePrimario,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              pequeno,
              style: const TextStyle(
                color: AppColors.grisClaro,
                fontSize: 9,
                letterSpacing: 1,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Un paso de la línea de tiempo (punto + línea + texto)
  Widget _paso({
    required IconData icono,
    required String titulo,
    required Widget detalle,
    bool ultimo = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 36,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.fondoNegro,
                    border: Border.all(color: AppColors.verdePrimario, width: 1.5),
                  ),
                  child: Icon(icono, color: AppColors.verdePrimario, size: 16),
                ),
                if (!ultimo)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: AppColors.verdePrimario.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: ultimo ? 0 : 18, top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontFamily: 'Oswald',
                      color: AppColors.blancoPuro,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  detalle,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _valor(IconData icono, String texto) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.grisOscuro,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.verdePrimario.withValues(alpha: 0.35)),
        ),
        child: Column(
          children: [
            Icon(icono, color: AppColors.verdePrimario, size: 28),
            const SizedBox(height: 8),
            Text(
              texto,
              style: const TextStyle(
                fontFamily: 'Oswald',
                color: AppColors.blancoPuro,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────── SECCIONES ─────────────

  Widget _banner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.verdePrimario.withValues(alpha: 0.28),
            AppColors.grisOscuro,
          ],
        ),
        border: Border.all(color: AppColors.verdePrimario.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: AppColors.verdePrimario.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.fondoNegro,
              border: Border.all(color: AppColors.verdePrimario, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.verdePrimario.withValues(alpha: 0.45),
                  blurRadius: 18,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.fitness_center,
                  color: AppColors.verdePrimario,
                  size: 40,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'ACTIVE SPORT GYM',
            style: TextStyle(
              fontFamily: 'Oswald',
              color: AppColors.blancoPuro,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Garzón, Huila • Desde 2021',
            style: EstiloTexto.textoNormalRoboto.copyWith(
              color: AppColors.grisClaro,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _pildora('FUERZA'),
              _pildora('MENTE'),
              _pildora('CORAZÓN'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _carrusel() {
    if (_galeria.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tituloSeccion(Icons.collections_outlined, 'NUESTRAS INSTALACIONES'),
        SizedBox(
          height: 210,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _galeria.length,
            itemBuilder: (context, index) {
              final ruta = _galeria[index];
              return GestureDetector(
                onTap: () => _verImagen(ruta),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.verdePrimario.withValues(alpha: 0.45)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(17),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          ruta,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppColors.grisOscuro,
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: AppColors.verdePrimario,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                        // Degradado inferior + pista de zoom
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(12, 22, 12, 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(Icons.zoom_in, color: AppColors.blancoPuro, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Toca para ampliar',
                                  style: TextStyle(color: AppColors.blancoPuro, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // Indicadores de puntos
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _galeria.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == index ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentPage == index ? AppColors.verdePrimario : AppColors.grisMedio,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _historia() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tituloSeccion(Icons.history_edu_outlined, 'NUESTRA HISTORIA'),
        _tarjeta(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fecha de inauguración destacada
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.verdePrimario.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.verdePrimario.withValues(alpha: 0.6)),
                    ),
                    child: const Icon(Icons.calendar_month_outlined, color: AppColors.verdePrimario, size: 26),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '23 DE ENERO DE 2021',
                        style: TextStyle(
                          fontFamily: 'Oswald',
                          color: AppColors.blancoPuro,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Nuestro inicio...',
                        style: TextStyle(
                          color: AppColors.verdePrimario,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text.rich(
                TextSpan(
                  style: _estiloCuerpo,
                  children: [
                    _verde('ACTIVE SPORT GYM'),
                    const TextSpan(text: ' fue inaugurado el '),
                    _verde('23 de enero del año 2021'),
                    const TextSpan(text: ', en la Calle 5 Sur # 17-14, Barrio Nueva Colombia, Garzón, Huila, por la pareja de esposos '),
                    _verde('Alexander Granados'),
                    const TextSpan(text: ' y '),
                    _verde('Sandra Milena Madrigal'),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text.rich(
                TextSpan(
                  style: _estiloCuerpo,
                  children: [
                    const TextSpan(
                      text: 'Emprendimiento que surgió posterior al periodo de pandemia del año 2020 y que buscaba '
                          'generar un espacio para realizar actividad física, pero no de la forma tradicional, sino más '
                          'personalizado y sumando las clases de ',
                    ),
                    _verde('entrenamiento funcional'),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Divider(color: AppColors.verdePrimario.withValues(alpha: 0.25), height: 1),
              const SizedBox(height: 18),

              // Línea de tiempo
              _paso(
                icono: Icons.lightbulb_outline,
                titulo: 'AÑO 2020',
                detalle: Text(
                  'Surge el emprendimiento tras el periodo de pandemia.',
                  style: _estiloCuerpo.copyWith(color: AppColors.grisClaro, fontSize: 12),
                ),
              ),
              _paso(
                icono: Icons.flag_outlined,
                titulo: '23 DE ENERO DE 2021',
                detalle: Text(
                  'Inauguración en la Calle 5 Sur # 17-14, Barrio Nueva Colombia.',
                  style: _estiloCuerpo.copyWith(color: AppColors.grisClaro, fontSize: 12),
                ),
              ),
              _paso(
                icono: Icons.place_outlined,
                titulo: 'HOY',
                ultimo: true,
                detalle: Text(
                  'Debido a la gran acogida, nuestras instalaciones fueron trasladadas al sitio actual.',
                  style: _estiloCuerpo.copyWith(color: AppColors.grisClaro, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _mision() {
    return _tarjeta(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag_circle_outlined, color: AppColors.verdePrimario, size: 28),
              const SizedBox(width: 10),
              const Text(
                'NUESTRA ',
                style: TextStyle(
                  fontFamily: 'Oswald',
                  color: AppColors.blancoPuro,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const Text(
                'MISIÓN',
                style: TextStyle(
                  fontFamily: 'Oswald',
                  color: AppColors.verdePrimario,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Brindar un espacio de entrenamiento cercano, seguro y motivador, donde cada persona reciba '
            'acompañamiento y orientación para desarrollar hábitos saludables, fortalecer su cuerpo y su '
            'mente, y mejorar su calidad de vida.',
            style: _estiloCuerpo,
          ),
        ],
      ),
    );
  }

  Widget _vision() {
    return _tarjeta(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.visibility_outlined, color: AppColors.verdePrimario, size: 28),
              SizedBox(width: 10),
              Text(
                'VISIÓN',
                style: TextStyle(
                  fontFamily: 'Oswald',
                  color: AppColors.verdePrimario,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(
              style: _estiloCuerpo,
              children: [
                const TextSpan(text: 'Ser el gimnasio líder en nuestra comunidad, reconocido por brindar '),
                _verde('bienestar, salud y resultados'),
                const TextSpan(
                  text: ', a través de un entrenamiento de calidad, acompañamiento profesional y un '
                      'ambiente familiar.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _valores() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tituloSeccion(Icons.bolt_outlined, 'NUESTROS VALORES'),
        Row(
          children: [
            _valor(Icons.fitness_center, 'FUERZA'),
            const SizedBox(width: 10),
            _valor(Icons.psychology_outlined, 'MENTE'),
            const SizedBox(width: 10),
            _valor(Icons.favorite_border, 'CORAZÓN'),
          ],
        ),
      ],
    );
  }

  Widget _ubicacion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tituloSeccion(Icons.location_on_outlined, 'NUESTRA UBICACIÓN'),
        _tarjeta(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mapa interactivo (OpenStreetMap): se mueve y se hace zoom con los dedos
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: _ubicacionGym,
                      initialZoom: 16,
                      minZoom: 5,
                      maxZoom: 18,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.frontend', // 👈 pon el package de tu app
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _ubicacionGym,
                            width: 150,
                            height: 70,
                            alignment: Alignment.topCenter,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.fondoNegro,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.verdePrimario, width: 1.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.verdePrimario.withValues(alpha: 0.4),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.fitness_center, color: AppColors.verdePrimario, size: 13),
                                      SizedBox(width: 5),
                                      Text(
                                        'Active Sport Gym',
                                        style: TextStyle(
                                          color: AppColors.blancoPuro,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.location_on, color: AppColors.verdePrimario, size: 34),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const RichAttributionWidget(
                        alignment: AttributionAlignment.bottomLeft,
                        attributions: [
                          TextSourceAttribution('OpenStreetMap contributors'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.place_outlined, color: AppColors.verdePrimario, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _direccion,
                      style: _estiloCuerpo.copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.phone_android_outlined, color: AppColors.verdePrimario, size: 20),
                  const SizedBox(width: 8),
                  Text(_telefono, style: _estiloCuerpo),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ───────────── PANTALLA ─────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoNegro,
      appBar: AppBar(
        backgroundColor: AppColors.fondoNegro,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.verdePrimario,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'HISTORIA DE ACTIVE SPORT',
          style: EstiloTexto.bienvenida.copyWith(
            fontFamily: 'Oswald',
            fontSize: 16,
            color: AppColors.verdePrimario,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: FondoApp(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            children: [
              _banner(),
              const SizedBox(height: 14),
              Row(
                children: [
                  _dato('2021', 'INAUGURACIÓN'),
                  const SizedBox(width: 10),
                  _dato('FUNCIONAL', 'ENTRENAMIENTO'),
                  const SizedBox(width: 10),
                  _dato('GARZÓN', 'HUILA'),
                ],
              ),
              const SizedBox(height: 26),
              _carrusel(),
              const SizedBox(height: 26),
              _historia(),
              const SizedBox(height: 18),
              _mision(),
              const SizedBox(height: 14),
              _vision(),
              const SizedBox(height: 26),
              _valores(),
              const SizedBox(height: 26),
              _ubicacion(),
              const SizedBox(height: 26),
              const Center(
                child: Text(
                  'Gracias por ser parte de nuestra historia',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.verdePrimario,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text(
                  'FUERZA • MENTE • CORAZÓN',
                  style: TextStyle(
                    fontFamily: 'Oswald',
                    color: AppColors.grisClaro,
                    fontSize: 12,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}