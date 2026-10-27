import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/componentes/administrador/historiadelgym/historia_seccion_card.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/componentes/fondo.dart';

class HistoriaGymScreen extends StatefulWidget {
  const HistoriaGymScreen({super.key});

  @override
  State<HistoriaGymScreen> createState() => _HistoriaGymScreenState();
}

class _HistoriaGymScreenState extends State<HistoriaGymScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  // Galería con URLs de alta calidad de Pexels
  final List<String> _carruselImagenesPexels = [
    'https://images.pexels.com/photos/1552242/pexels-photo-1552242.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/841130/pexels-photo-841130.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/1954524/pexels-photo-1954524.jpeg?auto=compress&cs=tinysrgb&w=800',
  ];

  // URL de mapa centrado en Garzón, Huila (Calle 7 Sur)
  final String _mapaStaticUrl = 
      'https://static-maps.yandex.ru/1.x/?lang=es_ES&ll=-75.6280,2.1930&z=16&l=map&size=600,300&pt=-75.6280,2.1930,pm2gnm';

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    // Auto-desplazamiento del carrusel cada 4 segundos
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentPage < _carruselImagenesPexels.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoNegro,
      appBar: AppBar(
        backgroundColor: AppColors.fondoNegro,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.verdePrimario, size: 20),
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
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                children: [
                  // BANNER SUPERIOR INSTITUCIONAL CON LOGO
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.verdePrimario.withOpacity(0.25),
                          AppColors.grisOscuro,
                        ],
                      ),
                      border: Border.all(color: AppColors.verdePrimario.withOpacity(0.4)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 65,
                          height: 65,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.fondoNegro,
                            border: Border.all(color: AppColors.verdePrimario, width: 2),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.fitness_center,
                                color: AppColors.verdePrimario,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'ACTIVE SPORT GYM',
                          style: TextStyle(
                            fontFamily: 'Oswald',
                            color: AppColors.blancoPuro,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Garzón, Huila • Pasión y Rendimiento',
                          style: EstiloTexto.textoNormalRoboto.copyWith(
                            color: AppColors.grisClaro,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // CARRUSEL DE IMÁGENES DE PEXELS
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.collections_outlined, color: AppColors.verdePrimario, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'GALERÍA DE INSTALACIONES',
                            style: EstiloTexto.enlaceNegritaRoboto.copyWith(letterSpacing: 1.1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 190,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                            itemCount: _carruselImagenesPexels.length,
                            itemBuilder: (context, index) {
                              final imageUrl = _carruselImagenesPexels[index];
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.verdePrimario.withOpacity(0.3)),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: AppColors.grisOscuro,
                                      child: const Center(
                                        child: Icon(Icons.image_not_supported, color: AppColors.verdePrimario, size: 40),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Indicadores de puntos del carrusel
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _carruselImagenesPexels.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 20 : 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: _currentPage == index ? AppColors.verdePrimario : AppColors.grisMedio,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // SECCIONES INFORMATIVAS
                  const HistoriaSeccionCard(
                    titulo: 'Nuestros Inicios',
                    descripcion: 'Fundado en el corazón de Garzón, Huila, Active Sport Gym nació con la firme visión de revolucionar la cultura fitness local, ofreciendo un espacio diseñado para desafiar los límites y potenciar el rendimiento físico de cada deportista.',
                    icono: Icons.rocket_launch_outlined,
                  ),

                  const HistoriaSeccionCard(
                    titulo: 'Filosofía y Compromiso',
                    descripcion: 'Creemos firmemente que el entrenamiento va más allá de levantar peso; es disciplina, salud mental y constancia. Por ello, brindamos instalaciones de primer nivel, asesoría profesional constante y un ambiente motivador.',
                    icono: Icons.workspace_premium_outlined,
                  ),

                  const HistoriaSeccionCard(
                    titulo: 'Innovación Tecnológica',
                    descripcion: 'Dando un paso adelante hacia la modernidad, hoy integramos herramientas digitales avanzadas y sistemas administrativos en tiempo real para gestionar rutinas, control de tienda y accesos de manera eficiente y moderna.',
                    icono: Icons.devices_outlined,
                  ),

                  const SizedBox(height: 12),

                  // 🌟 SECCIÓN DE MAPA Y UBICACIÓN EXACTA DE GARZÓN, HUILA
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.grisOscuro,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.verdePrimario.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
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
                            const Icon(Icons.location_on, color: AppColors.verdePrimario, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              'NUESTRA UBICACIÓN',
                              style: EstiloTexto.tekoSubtituloSeccion.copyWith(
                                color: AppColors.verdePrimario,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Mapa interactivo visual con marcador personalizado
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 160,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              border: Border.all(color: AppColors.verdePrimario.withOpacity(0.5)),
                            ),
                            child: Stack(
                              children: [
                                // Imagen del mapa de las calles de Garzón
                                Positioned.fill(
                                  child: Image.network(
                                    _mapaStaticUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: AppColors.grisOscuro,
                                      child: const Center(
                                        child: Icon(Icons.map_outlined, color: AppColors.verdePrimario, size: 40),
                                      ),
                                    ),
                                  ),
                                ),

                                // Pin Neón Flotante con el nombre del Gimnasio
                                Center(
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
                                              color: AppColors.verdePrimario.withOpacity(0.4),
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(Icons.fitness_center, color: AppColors.verdePrimario, size: 14),
                                            SizedBox(width: 6),
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
                                      const SizedBox(height: 4),
                                      const Icon(
                                        Icons.location_on,
                                        color: AppColors.verdePrimario,
                                        size: 32,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Dirección exacta ingresada
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.place_outlined, color: AppColors.verdePrimario, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Cl. 7 Sur #16a-2 a 16a-104\nGarzón, Huila, Colombia',
                                style: EstiloTexto.textoNormalRoboto.copyWith(
                                  color: AppColors.blancoPuro,
                                  fontSize: 13,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.phone_android_outlined, color: AppColors.verdePrimario, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '+57 312 000 0000',
                                style: EstiloTexto.textoNormalRoboto.copyWith(
                                  color: AppColors.blancoPuro,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}