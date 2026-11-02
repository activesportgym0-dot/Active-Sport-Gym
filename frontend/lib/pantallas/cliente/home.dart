import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/componentes/fondo.dart';
import 'package:frontend/componentes/cliente/home/menu_lateral.dart';
import 'package:frontend/componentes/cliente/home/barra_categorias_home.dart';
import 'package:frontend/componentes/cliente/home/lista_ejercicios_cliente.dart';
import 'package:frontend/componentes/cliente/home/carrusel_home.dart';
import 'package:frontend/componentes/cliente/home/mensajes_rotativos_home.dart';
import 'package:frontend/componentes/cliente/home/slides_gimnasio.dart';
import 'package:frontend/componentes/cliente/home/frase_del_dia_home.dart';
import 'package:frontend/models/ejercicio_model.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/ejercicio_service.dart';
import 'package:frontend/pantallas/cliente/asistente_ia_screen.dart';
import 'package:frontend/pantallas/cliente/compras/compras_screen.dart';
import 'package:frontend/pantallas/cliente/entrenar.dart';
import 'package:frontend/pantallas/cliente/menuLateral/entrenamiento_screen.dart';
import 'package:frontend/pantallas/cliente/menuLateral/historial_screen.dart';
import 'package:frontend/pantallas/cliente/menuLateral/reglas_y_horarios.dart';
import 'package:frontend/pantallas/cliente/mis_membresias.dart';
import 'package:frontend/pantallas/cliente/notificaciones_Cliente.dart';
import 'package:frontend/pantallas/cliente/rutina/diaria/crear_rutina_diaria_screen.dart';
import 'package:frontend/pantallas/perfil.dart';

class HomeClienteScreen extends StatefulWidget {
  const HomeClienteScreen({super.key});

  @override
  State<HomeClienteScreen> createState() => _HomeClienteScreenState();
}

class _HomeClienteScreenState extends State<HomeClienteScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Datos reales del catálogo de ejercicios (GET /ejercicios)
  List<EjercicioModel> _ejercicios = [];
  List<String> _categorias = []; // las 5 categorías con más ejercicios
  String _categoriaSeleccionada = '';
  bool _cargando = true;

  // Cuántos ejercicios se muestran por categoría para que el home no quede larguísimo
  static const int _ejerciciosPorCategoria = 3;

  // Recomendaciones que van pasando solas en el home
 // Recomendaciones que van pasando solas en el home
  static const List<MensajeHome> _recomendaciones = [
    MensajeHome(emoji: '💧', titulo: 'HIDRÁTATE', texto: 'Toma agua antes, durante y después de tu entrenamiento.'),
    MensajeHome(emoji: '🏃', titulo: 'CALIENTA', texto: 'Dedica 5 a 10 minutos de movilidad para prevenir lesiones.'),
    MensajeHome(emoji: '🥗', titulo: 'ALIMÉNTATE BIEN', texto: 'Incluye proteína de calidad en tu comida post-entreno.'),
    MensajeHome(emoji: '😴', titulo: 'DESCANSA', texto: 'Tus músculos crecen cuando duermes, no cuando entrenas.'),
    MensajeHome(emoji: '📈', titulo: 'PROGRESA POCO A POCO', texto: 'Cuando una carga sea fácil, sube el peso de forma controlada.'),
    MensajeHome(emoji: '🧘', titulo: 'ESTIRA AL FINAL', texto: 'Estira al terminar para mejorar tu flexibilidad y reducir la tensión.'),
    MensajeHome(emoji: '⚡', titulo: 'ENERGÍA CONSTANTE', texto: 'Consume un snack ligero 30 minutos antes de tu rutina.'),
    MensajeHome(emoji: '🎯', titulo: 'OBJETIVO CLARO', texto: 'Visualiza cada repetición antes de levantar la barra.'),
    MensajeHome(emoji: '🧠', titulo: 'MENTE Y MÚSCULO', texto: 'Concéntrate en el músculo que estás trabajando en cada serie.'),
    MensajeHome(emoji: '🔥', titulo: 'DA EL MÁXIMO', texto: 'Haz que cada serie cuente y no te guardes nada innecesario.'),
    MensajeHome(emoji: '👟', titulo: 'CALZADO ADECUADO', texto: 'Usa zapatos con suela plana para mayor estabilidad en piernas.'),
    MensajeHome(emoji: '⏱️', titulo: 'TIEMPO DE DESCANSO', texto: 'Descansa entre 60 y 90 segundos entre series de hipertrofia.'),
    MensajeHome(emoji: '🛡️', titulo: 'PROTEGE TUS ARTICULACIONES', texto: 'No bloquees por completo las rodillas o codos con peso pesado.'),
    MensajeHome(emoji: '🎵', titulo: 'MÚSICA MOTIVADORA', texto: 'Arma una playlist con tus canciones favoritas para entrenar con energía.'),
    MensajeHome(emoji: '🔄', titulo: 'VARÍA TUS EJERCICIOS', texto: 'Cambia ciertos ángulos cada pocas semanas para estimular el músculo.'),
    MensajeHome(emoji: '⚖️', titulo: 'TÉCNICA ANTES QUE PESO', texto: 'Una ejecución limpia vale más que levantar mucho peso mal.'),
    MensajeHome(emoji: '🛑', titulo: 'ESCUCHA A TU CUERPO', texto: 'Si sientes dolor punzante, detén el ejercicio de inmediato.'),
    MensajeHome(emoji: '🧊', titulo: 'RECUPERACIÓN ACTIVA', texto: 'Los días de descanso sal a caminar o haz movilidad suave.'),
    MensajeHome(emoji: '🏆', titulo: 'SUPÉRATE A TI MISMO', texto: 'Tu único rival es la persona que fuiste ayer en el espejo.'),
    MensajeHome(emoji: '📅', titulo: 'CONSTANCIA PURA', texto: 'Es mejor entrenar 4 días fijos que ir 7 días una sola semana.'),
    MensajeHome(emoji: '🎽', titulo: 'ROPA CÓMODA', texto: 'Usa prendas transpirables que te permitan moverte con libertad.'),
    MensajeHome(emoji: 'ph', titulo: 'RESPIRACIÓN CLAVE', texto: 'Inhala en la bajada, exhala con fuerza en el esfuerzo máximo.'),
    MensajeHome(emoji: '🤝', titulo: 'AYUDA EN EL GYM', texto: 'Pide un spotter (asistencia) cuando vayas a probar un récord personal.'),
    MensajeHome(emoji: '🔋', titulo: 'RECARGA DIARIA', texto: 'Mantén tus niveles de sueño estables para rendir al 100%.'),
    MensajeHome(emoji: '🌟', titulo: 'ACTITUD POSITIVA', texto: 'Entrar con buena actitud cambia por completo tu rendimiento.'),
    MensajeHome(emoji: '📊', titulo: 'REGISTRA TUS PESOS', texto: 'Anota tus marcas en la app para ver tu evolución semana a semana.'),
    MensajeHome(emoji: '🍎', titulo: 'FIBRA Y NUTRIENTES', texto: 'No olvides comer vegetales y frutas en tus porciones diarias.'),
    MensajeHome(emoji: '🚀', titulo: 'EMPIEZA HOY', texto: 'No esperes al lunes para retomar tus metas de entrenamiento.'),
    MensajeHome(emoji: '💪', titulo: 'FUERZA Y CONTROL', texto: 'Controla la fase excéntrica (la bajada) del movimiento.'),
    MensajeHome(emoji: '💡', titulo: 'FILOSOFÍA FITNESS', texto: 'Fuerza, corazón y mente en cada entrenamiento de Active Sport Gym.')
  ];

  // Primer nombre de quien inició sesión: "luisa maría" -> "Luisa"
  String get _nombreSaludo {
    final partes = SessionService.nombreUsuario.trim().split(RegExp(r'\s+'));
    final primero = partes.first;
    if (primero.isEmpty) return '';
    return primero[0].toUpperCase() + primero.substring(1).toLowerCase();
  }

  // "Buenos días", "Buenas tardes" o "Buenas noches" según la hora del teléfono
  String get _saludoHora {
    final hora = DateTime.now().hour;
    if (hora < 12) return 'Buenos días';
    if (hora < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final raw = await EjercicioService.obtenerEjerciciosCliente();
    final ejercicios = raw.map((e) => EjercicioModel.fromJson(e)).toList();

    // Las 5 categorías con más ejercicios (así ninguna sale vacía)
    final conteo = <String, int>{};
    for (final ejercicio in ejercicios) {
      for (final categoria in ejercicio.categorias) {
        if (categoria.nombre.isNotEmpty) {
          conteo[categoria.nombre] = (conteo[categoria.nombre] ?? 0) + 1;
        }
      }
    }
    final ordenadas = conteo.entries.toList()
      ..sort((a, b) {
        final porCantidad = b.value.compareTo(a.value);
        return porCantidad != 0 ? porCantidad : a.key.compareTo(b.key);
      });
    final categorias = ordenadas.take(5).map((e) => e.key).toList();

    if (!mounted) return;
    setState(() {
      _ejercicios = ejercicios;
      _categorias = categorias;
      _categoriaSeleccionada = categorias.isNotEmpty ? categorias.first : '';
      _cargando = false;
    });
  }

  bool _perteneceACategoria(EjercicioModel e, String categoria) {
    return e.categorias.any((c) => c.nombre.toLowerCase() == categoria.toLowerCase());
  }

  // Todos los ejercicios de la categoría seleccionada
  List<EjercicioModel> get _ejerciciosDeLaCategoria {
    return _ejercicios.where((e) => _perteneceACategoria(e, _categoriaSeleccionada)).toList();
  }

  // Solo los primeros 3, en el formato que usa la lista del home
  List<Map<String, String>> get _ejerciciosFiltrados {
    return _ejerciciosDeLaCategoria.take(_ejerciciosPorCategoria).map<Map<String, String>>((e) {
      return {
        'category': _categoriaSeleccionada,
        'title': e.nombre,
        'description': e.descripcion ?? '',
        'imagePath': e.imagen ?? '',
      };
    }).toList();
  }

  void _abrirEntrenar([String? categoria]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EntrenarClienteScreen(
          categoriaInicial: categoria ?? _categoriaSeleccionada,
        ),
      ),
    );
  }

  void _irA(Widget pantalla) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => pantalla));
  }

  @override
  Widget build(BuildContext context) {
    final ejerciciosMostrados = _ejerciciosFiltrados;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.fondoNegro,
      drawer: const MenuLateral(),
      appBar: AppBar(
        backgroundColor: AppColors.fondoNegro,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.verdePrimario, size: 28),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          'ACTIVE SPORT GYM',
          style: EstiloTexto.bienvenida.copyWith(
            fontSize: 14,
            color: AppColors.blancoPuro,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(icon: const Icon(Icons.person_outline, color: AppColors.blancoPuro, size: 22), onPressed: () {
                              Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PerfilScreen(                    
                                ),
                              ),
                            );
          }),
          IconButton(icon: const Icon(Icons.notifications_outlined, color: AppColors.blancoPuro, size: 22), onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NotificacionesClienteScreen(                    
                                ),
                              ),
                            );            
          }),
        ],
      ),
      body: FondoApp(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🔥 ', style: TextStyle(fontSize: 22)),
                    Text(
                      'Hola,\n$_nombreSaludo',
                      style: EstiloTexto.tituloPrincipalPrimerPantalla.copyWith(fontSize: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '$_saludoHora • ¿Listo para entrenar?',
                  style: const TextStyle(color: AppColors.grisClaro, fontSize: 13),
                ),
                const SizedBox(height: 16),

                // Carrusel con fotos del gimnasio (avanza solo). Se edita en slides_gimnasio.dart
                const CarruselHome(slides: slidesGimnasio, altura: 190),
                const SizedBox(height: 16),

                // Frase motivadora (cambia cada día)
                const FraseDelDiaHome(),
                const SizedBox(height: 16),

                // Recomendaciones que van pasando solas
                const MensajesRotativosHome(mensajes: _recomendaciones),
                const SizedBox(height: 25),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Text('🗂️ ', style: TextStyle(fontSize: 16)),
                        Text(
                          'CATEGORÍAS',
                          style: TextStyle(color: AppColors.blancoPuro, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                
                // Barra de categorías modular con actualización de estado
                BarraCategoriasHome(
                  categorias: _categorias,
                  categoriaSeleccionada: _categoriaSeleccionada,
                  onCategoriaSelected: (cat) {
                    setState(() {
                      _categoriaSeleccionada = cat;
                    });
                  },
                ),
                const SizedBox(height: 25),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'EJERCICIOS',
                      style: TextStyle(color: AppColors.blancoPuro, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      '${ejerciciosMostrados.length} de ${_ejerciciosDeLaCategoria.length}',
                      style: const TextStyle(color: AppColors.grisClaro, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                
                _cargando
                    ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: CircularProgressIndicator(color: AppColors.verdePrimario)),
                      )
                    : ejerciciosMostrados.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(20),
                        alignment: Alignment.center,
                        child: const Text('No hay ejercicios en esta categoría', style: TextStyle(color: AppColors.grisClaro, fontSize: 13)),
                      )
                    : ListaEjerciciosCliente(
                        ejercicios: ejerciciosMostrados,
                        // Al tocar un ejercicio se abre la pantalla de entrenar en esa categoría
                        onEjercicioTap: (_) => _abrirEntrenar(),
                      ),
                
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EntrenarClienteScreen(
                            categoriaInicial: _categoriaSeleccionada,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'ver mas ejercicios...',
                      style: TextStyle(color: AppColors.grisClaro, fontSize: 13, decoration: TextDecoration.underline),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: AppColors.fondoNegro,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home, color: AppColors.verdePrimario, size: 28),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.fitness_center, color: AppColors.grisMedio, size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EntrenarClienteScreen(
                      categoriaInicial: _categoriaSeleccionada,
                    ),
                  ),
                );
              },
            ),
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.fondoNegro,
              ),
              child: IconButton(
                icon: const Icon(Icons.add_box, color: AppColors.verdePrimario, size: 36),
                onPressed: () {
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CrearRutinaDiariaScreen(
                      
                    ),
                  ),
                );
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline, color: AppColors.grisMedio, size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AsistenteIAScreen(                    
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.grisMedio, size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ComprasScreen(                    
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        
      ),
    );
  }
}