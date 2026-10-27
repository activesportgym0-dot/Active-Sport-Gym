import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';

class NotificacionesClienteScreen extends StatefulWidget {
  const NotificacionesClienteScreen({super.key});

  @override
  State<NotificacionesClienteScreen> createState() => _NotificacionesClienteScreenState();
}

class _NotificacionesClienteScreenState extends State<NotificacionesClienteScreen> {
  bool _isLoading = false;

  // Lista local simulada de notificaciones
  final List<Map<String, dynamic>> _notificaciones = [
    {
      'id': 1,
      'titulo': '¡Nuevo Stock de Proteínas!',
      'mensaje': 'Ya llegó la nueva mercancía de Whey Gold Standard y Smart Gainer.',
      'tipo': 'stock',
      'fecha': '06 Oct 2026',
      'leido': false,
    },
    {
      'id': 2,
      'titulo': 'Mantenimiento de Maquinaria',
      'mensaje': 'El área de peso libre estará cerrada mañana en la mañana por mantenimiento.',
      'tipo': 'evento',
      'fecha': '05 Oct 2026',
      'leido': true,
    },
  ];

  // Marcar una notificación individual como leída localmente
  void _marcarComoLeida(int id) {
    setState(() {
      final index = _notificaciones.indexWhere((n) => n['id'] == id);
      if (index != -1) {
        _notificaciones[index]['leido'] = true;
      }
    });
  }

  // Marcar todas como leídas localmente
  void _marcarTodasLeidas() {
    setState(() {
      for (var n in _notificaciones) {
        n['leido'] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool hayPendientes = _notificaciones.any((n) => !(n['leido'] ?? false));

    return DefaultTextStyle(
      style: const TextStyle(decoration: TextDecoration.none),
      child: Scaffold(
        backgroundColor: AppColors.fondoNegro,
        body: Stack(
          children: [
            // Componente de Fondo personalizado

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
                                child: _notificaciones.isEmpty
                                    ? Center(
                                        child: Text(
                                          'No tienes notificaciones por el momento',
                                          style: EstiloTexto.hintTexto.copyWith(decoration: TextDecoration.none),
                                        ),
                                      )
                                    : ListView.builder(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        itemCount: _notificaciones.length,
                                        itemBuilder: (context, index) {
                                          final noti = _notificaciones[index];
                                          return TarjetaNotificacionCliente(
                                            noti: noti,
                                            onTap: () {
                                              _marcarComoLeida(noti['id']);
                                            },
                                          );
                                        },
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
