import 'package:frontend/componentes/cliente/home/carrusel_home.dart';

/// Fotos y textos del carrusel del home.
///
/// POR AHORA son fotos gratuitas de Pexels (pexels.com), cargadas desde internet.
/// Cuando tengas las fotos de tu gimnasio:
///  1. Copia las imágenes a tu carpeta assets/images/ (por ejemplo gimnasio1.jpg).
///  2. Cambia cada `imagen` por su ruta: 'assets/images/gimnasio1.jpg'
///     (el carrusel acepta rutas de assets y direcciones de internet).
///  3. Cambia los textos por los de tu gimnasio.
const List<SlideHome> slidesGimnasio = [
  SlideHome(
    imagen: 'https://images.pexels.com/photos/17211446/pexels-photo-17211446/free-photo-of-an-empty-gym.jpeg?auto=compress&cs=tinysrgb&w=900',
    etiqueta: 'Active Sport Gym',
    titulo: 'Tu espacio para entrenar',
    subtitulo: 'Ven y da lo mejor de ti',
  ),
  SlideHome(
    imagen: 'https://images.pexels.com/photos/29149073/pexels-photo-29149073/free-photo-of-modern-gym-interior-with-fitness-equipment.jpeg?auto=compress&cs=tinysrgb&w=900',
    etiqueta: 'Instalaciones',
    titulo: 'Equipos modernos',
    subtitulo: 'Todo lo que necesitas para tu rutina',
  ),
  SlideHome(
    imagen: 'https://images.pexels.com/photos/4716816/pexels-photo-4716816.jpeg?auto=compress&cs=tinysrgb&w=900',
    etiqueta: 'Cardio',
    titulo: 'Corre, pedalea y quema energía',
    subtitulo: 'Zona amplia y bien iluminada',
  ),
  SlideHome(
    imagen: 'https://images.pexels.com/photos/4716814/pexels-photo-4716814.jpeg?auto=compress&cs=tinysrgb&w=900',
    etiqueta: 'Comodidad',
    titulo: 'Entrena sin preocupaciones',
    subtitulo: 'Espacios cómodos para ti',
  ),
  SlideHome(
    imagen: 'https://images.pexels.com/photos/29149082/pexels-photo-29149082/free-photo-of-modern-fitness-gym-in-dubai-with-treadmills.jpeg?auto=compress&cs=tinysrgb&w=900',
    etiqueta: 'Constancia',
    titulo: 'Construye tu mejor versión',
    subtitulo: 'Un entrenamiento a la vez',
  ),
];
