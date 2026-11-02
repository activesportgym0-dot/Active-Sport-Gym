import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

/// Muestra la demostración de un ejercicio (la URL de Cloudinary que sube el admin).
///  - GIF o imagen: Image.network (los GIF se animan y se repiten solos).
///  - Video (mp4, webm, mov, m4v, avi): NO usa ningún paquete de video. Cloudinary
///    puede entregar cualquier video como GIF animado si se pide la extensión .gif, así que
///    la URL se convierte (ancho 480 y 12 cuadros por segundo para que pese poco) y se
///    muestra igual que un GIF: se repite en bucle hasta que se pase al siguiente ejercicio.
/// Si la URL está vacía o no carga, se muestra un icono de ejercicio.
class MediaEjercicio extends StatelessWidget {
  final String url;
  final BoxFit fit;

  const MediaEjercicio({
    super.key,
    required this.url,
    this.fit = BoxFit.contain,
  });

  static const List<String> _extensionesVideo = ['.mp4', '.webm', '.mov', '.m4v', '.avi'];

  static bool esVideo(String url) {
    final sinParametros = url.split('?').first.toLowerCase();
    return _extensionesVideo.any(sinParametros.endsWith);
  }

  /// .../video/upload/v123/carpeta/demo.mp4  ->  .../video/upload/w_480,fps_12/v123/carpeta/demo.gif
  /// Si el video no está en Cloudinary no se puede convertir y se devuelve igual.
  static String urlMostrable(String url) {
    if (url.isEmpty || !esVideo(url)) return url;

    final sinParametros = url.split('?').first;
    if (!sinParametros.contains('res.cloudinary.com') || !sinParametros.contains('/video/upload/')) {
      return url;
    }

    final punto = sinParametros.lastIndexOf('.');
    final base = punto > sinParametros.lastIndexOf('/') ? sinParametros.substring(0, punto) : sinParametros;
    return '${base.replaceFirst('/video/upload/', '/video/upload/w_480,fps_12/')}.gif';
  }

  Widget _iconoVacio() {
    return const Center(
      child: Icon(Icons.fitness_center, color: Colors.black45, size: 80),
    );
  }

  Widget _cargando() {
    return const Center(
      child: SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(color: AppColors.verdePrimario, strokeWidth: 2.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _iconoVacio();

    return Image.network(
      urlMostrable(url),
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, progreso) => progreso == null ? child : _cargando(),
      errorBuilder: (context, error, stackTrace) => _iconoVacio(),
    );
  }
}