import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

/// Banner de bienvenida del home del administrador: saludo con el nombre,
/// saludo según la hora y la fecha de hoy. Todo sale del teléfono y de la sesión,
/// no necesita internet ni base de datos.
class AdminBannerHome extends StatelessWidget {
  final String nombre;

  const AdminBannerHome({super.key, required this.nombre});

  static const List<String> _dias = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo',
  ];
  static const List<String> _meses = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];

  String get _saludoHora {
    final hora = DateTime.now().hour;
    if (hora < 12) return 'Buenos días';
    if (hora < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  // "Lunes, 3 de noviembre"
  String get _fechaHoy {
    final hoy = DateTime.now();
    return '${_dias[hoy.weekday - 1]}, ${hoy.day} de ${_meses[hoy.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.verdePrimario,
            AppColors.verdePrimario.withOpacity(0.72),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.verdePrimario.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Icono grande de adorno
          Positioned(
            right: -6,
            bottom: -14,
            child: Icon(
              Icons.admin_panel_settings_rounded,
              size: 110,
              color: AppColors.fondoNegro.withOpacity(0.13),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.fondoNegro,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'ADMINISTRADOR',
                  style: TextStyle(
                    color: AppColors.verdePrimario,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                nombre.isEmpty ? 'HOLA' : 'HOLA, ${nombre.toUpperCase()}',
                style: const TextStyle(
                  fontFamily: 'Oswald',
                  color: AppColors.fondoNegro,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$_saludoHora • Panel de control',
                style: const TextStyle(
                  color: AppColors.fondoNegro,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, color: AppColors.fondoNegro, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    _fechaHoy,
                    style: const TextStyle(color: AppColors.fondoNegro, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
