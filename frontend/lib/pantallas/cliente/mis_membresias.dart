import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/componentes/fondo.dart';
import 'package:frontend/componentes/cliente/asistente/burbuja_mini_chat_modal.dart';

class MisMembresiasScreen extends StatelessWidget {
  const MisMembresiasScreen({super.key});

  // Datos simulados basados en lo que retorna tu backend (Membresía actual e historial)
  final Map<String, dynamic> membresiaActual = const {
    'estado': 'activa',
    'fecha_inicio': '2026-10-01',
    'fecha_fin': '2026-11-01',
    'plan': 'Plan Mensual General',
  };

  final List<Map<String, dynamic>> historialMembresias = const [
    {
      'id_membresia': 101,
      'estado': 'activa',
      'fecha_inicio': '2026-10-01',
      'fecha_fin': '2026-11-01',
      'plan': 'Plan Mensual General',
    },
    {
      'id_membresia': 100,
      'estado': 'vencida',
      'fecha_inicio': '2026-09-01',
      'fecha_fin': '2026-10-01',
      'plan': 'Plan Mensual General',
    },
    {
      'id_membresia': 99,
      'estado': 'inactiva',
      'fecha_inicio': '2026-08-01',
      'fecha_fin': '2026-09-01',
      'plan': 'Plan Quincenal',
    },
  ];

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
        title: const Text(
          'MI MEMBRESÍA',
          style: TextStyle(
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
                  // 🌟 SECCIÓN 1: TARJETA DE MEMBRESÍA ACTUAL
                  const Text(
                    'ESTADO ACTUAL',
                    style: TextStyle(
                      color: AppColors.grisMedio,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.grisOscuro,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: membresiaActual['estado'] == 'activa' 
                            ? AppColors.verdePrimario 
                            : Colors.redAccent,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (membresiaActual['estado'] == 'activa' 
                              ? AppColors.verdePrimario 
                              : Colors.redAccent).withOpacity(0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.card_membership, color: AppColors.verdePrimario, size: 24),
                                const SizedBox(width: 10),
                                Text(
                                  membresiaActual['plan'] ?? 'Membresía Active Sport',
                                  style: const TextStyle(
                                    color: AppColors.blancoPuro,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: (membresiaActual['estado'] == 'activa' 
                                    ? AppColors.verdePrimario 
                                    : Colors.redAccent).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: membresiaActual['estado'] == 'activa' 
                                      ? AppColors.verdePrimario 
                                      : Colors.redAccent,
                                ),
                              ),
                              child: Text(
                                membresiaActual['estado'].toUpperCase(),
                                style: TextStyle(
                                  color: membresiaActual['estado'] == 'activa' 
                                      ? AppColors.verdePrimario 
                                      : Colors.redAccent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Divider(color: AppColors.grisMedio, height: 1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildFechaInfo('Fecha de Inicio', membresiaActual['fecha_inicio']),
                            _buildFechaInfo('Vencimiento', membresiaActual['fecha_fin']),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // 🌟 SECCIÓN 2: HISTORIAL DE MEMBRESÍAS
                  const Text(
                    'HISTORIAL DE PAGOS Y PLANES',
                    style: TextStyle(
                      color: AppColors.grisMedio,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),

                  ...historialMembresias.map((item) {
                    bool esActiva = item['estado'] == 'activa';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.grisOscuro,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.grisMedio.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.fondoNegro,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: esActiva ? AppColors.verdePrimario : AppColors.grisMedio,
                              ),
                            ),
                            child: Icon(
                              esActiva ? Icons.check_circle_outline : Icons.history,
                              color: esActiva ? AppColors.verdePrimario : AppColors.grisClaro,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['plan'],
                                  style: const TextStyle(
                                    color: AppColors.blancoPuro,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Del ${item['fecha_inicio']} al ${item['fecha_fin']}',
                                  style: const TextStyle(
                                    color: AppColors.grisClaro,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.fondoNegro,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item['estado'].toUpperCase(),
                              style: TextStyle(
                                color: esActiva ? AppColors.verdePrimario : AppColors.grisClaro,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
              
            ],
          ),
        ),
      ),
      floatingActionButton: const BurbujaMiniChatModal(),
    );
  }

  Widget _buildFechaInfo(String label, String fecha) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.grisClaro, fontSize: 10),
        ),
        const SizedBox(height: 3),
        Text(
          fecha,
          style: const TextStyle(
            color: AppColors.blancoPuro,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}