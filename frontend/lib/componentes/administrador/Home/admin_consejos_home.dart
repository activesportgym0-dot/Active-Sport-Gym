import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

/// Tarjeta con consejos para el administrador que van cambiando solos cada pocos
/// segundos (con un desvanecimiento suave) y puntos indicadores.
class AdminConsejosHome extends StatefulWidget {
  final Duration cada;

  const AdminConsejosHome({super.key, this.cada = const Duration(seconds: 6)});

  @override
  State<AdminConsejosHome> createState() => _AdminConsejosHomeState();
}

class _AdminConsejosHomeState extends State<AdminConsejosHome> {
  static const List<_Consejo> _consejos = [
    _Consejo('🧾', 'ATIENDE LOS PEDIDOS', 'Cambia el estado de cada pedido de manera puntual para que el cliente reciba su aviso de actualización directamente en su correo electrónico y se mantenga informado.'),
    _Consejo('📦', 'REVISA EL STOCK', 'Mantén actualizadas las unidades y existencias de tus productos e implementos en el inventario para evitar confusiones y no perder ninguna venta en el gimnasio.'),
    _Consejo('📣', 'COMUNICA NOVEDADES', 'Envía notificaciones push atractivas con imágenes para anunciar nuevas promociones, eventos especiales, cambios de horario o avisos importantes de Active Sport Gym.'),
    _Consejo('👥', 'CUIDA LAS MEMBRESÍAS', 'Monitorea constantemente los planes por vencer de tus usuarios para recordarles su renovación a tiempo o desactivar cuentas inactivas y mantener la seguridad del sistema.'),
    _Consejo('💪', 'CATÁLOGO AL DÍA', 'Agrega nuevos ejercicios y rutinas completas acompañadas de GIF o videos explicativos para asegurar que tus clientes entrenen de la forma correcta y obtengan mejores resultados.'),
    _Consejo('📊', 'ANALIZA EL PROGRESO', 'Revisa periódicamente las estadísticas de asistencia y rendimiento de los clientes para identificar cuáles son las horas pico y ofrecer un servicio más personalizado.'),
    _Consejo('⭐', 'GESTIONA LOS PAGOS', 'Verifica y confirma los comprobantes de pago de las membresías subidos por los usuarios para aprobar sus accesos al gimnasio de forma rápida y sin demoras innecesarias.'),
    _Consejo('💬', 'MONITOREA EL CHAT IA', 'Revisa las conversaciones del asistente virtual de la aplicación para asegurarte de que está respondiendo correctamente a las dudas frecuentes sobre horarios y tarifas.'),
  ];

  Timer? _timer;
  int _indice = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.cada, (_) {
      if (mounted) setState(() => _indice = (_indice + 1) % _consejos.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final consejo = _consejos[_indice];

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 108),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grisOscuro,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.verdePrimario.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Column(
              key: ValueKey(_indice),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('${consejo.emoji} ', style: const TextStyle(fontSize: 16)),
                    Text(
                      consejo.titulo,
                      style: const TextStyle(color: AppColors.blancoPuro, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  consejo.texto,
                  style: const TextStyle(color: AppColors.grisClaro, fontSize: 13, height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: List.generate(_consejos.length, (i) {
              final activo = i == _indice;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(left: 4),
                width: activo ? 14 : 5,
                height: 5,
                decoration: BoxDecoration(
                  color: activo ? AppColors.verdePrimario : AppColors.grisMedio,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _Consejo {
  final String emoji;
  final String titulo;
  final String texto;

  const _Consejo(this.emoji, this.titulo, this.texto);
}