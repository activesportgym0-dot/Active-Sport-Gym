import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/componentes/fondo.dart';
import 'package:frontend/models/notificacion_model.dart';
import 'package:frontend/services/notificacion_service.dart';

class NotificacionesClienteScreen extends StatefulWidget {
  const NotificacionesClienteScreen({super.key});

  @override
  State<NotificacionesClienteScreen> createState() => _NotificacionesClienteScreenState();
}

class _NotificacionesClienteScreenState extends State<NotificacionesClienteScreen> {
  // Notificaciones reales del cliente (GET /notificaciones/mis-notificaciones)
  List<NotificacionModel> _notificaciones = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarNotificaciones();
  }

  void _mostrarMensaje(String mensaje, {required bool exito}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: exito ? Colors.green : Colors.redAccent,
      ),
    );
  }

  Future<void> _cargarNotificaciones() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final notificaciones = await NotificacionService.obtenerMisNotificaciones();
      if (!mounted) return;
      setState(() {
        _notificaciones = notificaciones;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _mostrarMensaje(
        'Error al cargar tus notificaciones: ${e.toString().replaceFirst('Exception: ', '')}',
        exito: false,
      );
    }
  }

  // Marca una notificación como leída (PUT /marcar-leida/:id). El cambio se ve al instante
  // y se deshace si el servidor no lo acepta.
  Future<void> _marcarComoLeida(NotificacionModel noti) async {
    if (noti.leida) return;

    final indice = _notificaciones.indexWhere((n) => n.idNotificacion == noti.idNotificacion);
    if (indice == -1) return;
    setState(() => _notificaciones[indice] = noti.copyWith(leida: true));

    final resultado = await NotificacionService.marcarComoLeida(noti.idNotificacion);
    if (!mounted) return;

    if (resultado['success'] != true) {
      final actual = _notificaciones.indexWhere((n) => n.idNotificacion == noti.idNotificacion);
      if (actual != -1) setState(() => _notificaciones[actual] = noti);
      _mostrarMensaje(resultado['message'].toString(), exito: false);
    }
  }

  // Marca todas como leídas (PUT /marcar-todas-leidas)
  Future<void> _marcarTodasLeidas() async {
    final resultado = await NotificacionService.marcarTodasComoLeidas();
    if (!mounted) return;

    if (resultado['success'] == true) {
      setState(() {
        _notificaciones = _notificaciones.map((n) => n.copyWith(leida: true)).toList();
      });
    } else {
      _mostrarMensaje(resultado['message'].toString(), exito: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hayPendientes = _notificaciones.any((n) => !n.leida);

    return DefaultTextStyle(
      style: const TextStyle(decoration: TextDecoration.none),
      child: Scaffold(
        backgroundColor: AppColors.fondoNegro,
        body: Stack(
          children: [
            // Componente de Fondo personalizado
            FondoApp(child: SizedBox.expand()),

            SafeArea(
              child: Column(
                children: [
                  // Header de navegación
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(Icons.arrow_back_ios_new, color: AppColors.verdePrimario, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'NOTIFICACIONES',
                              style: EstiloTexto.bienvenida.copyWith(
                                fontFamily: 'Oswald',
                                fontSize: 18,
                                color: AppColors.verdePrimario,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                        if (hayPendientes)
                          TextButton(
                            onPressed: _marcarTodasLeidas,
                            child: const Text(
                              'Marcar leídas',
                              style: TextStyle(color: AppColors.verdePrimario, fontSize: 12, decoration: TextDecoration.none),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Contenido principal
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: AppColors.verdePrimario))
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'NOVEDADES RECIENTES',
                                      style: EstiloTexto.enlaceNegritaRoboto.copyWith(
                                        letterSpacing: 1.1,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    Text(
                                      '${_notificaciones.length} avisos',
                                      style: EstiloTexto.textoNormalRoboto.copyWith(
                                        fontSize: 11,
                                        color: AppColors.grisClaro,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5),
                              Expanded(
                                child: RefreshIndicator(
                                  color: AppColors.verdePrimario,
                                  onRefresh: _cargarNotificaciones,
                                  child: _notificaciones.isEmpty
                                      ? ListView(
                                          physics: const AlwaysScrollableScrollPhysics(),
                                          children: [
                                            const SizedBox(height: 120),
                                            Center(
                                              child: Text(
                                                'No tienes notificaciones por el momento',
                                                style: EstiloTexto.hintTexto.copyWith(decoration: TextDecoration.none),
                                              ),
                                            ),
                                          ],
                                        )
                                      : ListView.builder(
                                          physics: const AlwaysScrollableScrollPhysics(),
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          itemCount: _notificaciones.length,
                                          itemBuilder: (context, index) {
                                            final noti = _notificaciones[index];
                                            return TarjetaNotificacionCliente(
                                              noti: noti.toMapaTarjetaCliente(),
                                              onTap: () => _marcarComoLeida(noti),
                                            );
                                          },
                                        ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TarjetaNotificacionCliente extends StatelessWidget {
  final Map<String, dynamic> noti;
  final VoidCallback onTap;

  const TarjetaNotificacionCliente({
    super.key,
    required this.noti,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool esLeido = noti['leido'] ?? false;
    final String imagenUrl = (noti['imagen_url'] ?? '').toString();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: esLeido ? AppColors.grisOscuro.withOpacity(0.8) : AppColors.grisOscuro,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: esLeido ? AppColors.grisMedio.withOpacity(0.3) : AppColors.verdePrimario.withOpacity(0.6),
            width: esLeido ? 1 : 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen (solo si el administrador adjuntó una a la notificación)
            if (imagenUrl.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imagenUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.black26,
                    child: const Icon(Icons.broken_image_outlined, color: AppColors.grisMedio, size: 32),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.verdePrimario.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    (noti['tipo'] ?? 'INFO').toUpperCase(),
                    style: EstiloTexto.textoNormalRoboto.copyWith(
                      color: AppColors.verdePrimario,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      noti['fecha'] ?? '',
                      style: EstiloTexto.textoNormalRoboto.copyWith(
                        fontSize: 10,
                        color: AppColors.grisMedio,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    if (!esLeido) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.verdePrimario,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              noti['titulo'] ?? '',
              style: EstiloTexto.enlaceNegritaRoboto.copyWith(
                fontSize: 14,
                color: AppColors.blancoPuro,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              noti['mensaje'] ?? '',
              style: EstiloTexto.textoNormalRoboto.copyWith(
                color: AppColors.grisClaro,
                fontSize: 12,
                height: 1.3,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}