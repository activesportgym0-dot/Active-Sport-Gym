import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/componentes/fondo.dart';
import 'package:frontend/componentes/cliente/asistente/burbuja_mini_chat_modal.dart';

class HistorialClienteAdminScreen extends StatelessWidget {
  final Map<String, dynamic> usuario;

  const HistorialClienteAdminScreen({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    final nombreUsuario = '${usuario['nombre']} ${usuario['apellido']}';

    // Simulación del historial de membresías del cliente (Solo consulta)
    final List<Map<String, dynamic>> historialMembresias = [
      {
        'id_membresia': 101,
        'estado': 'activa',
        'fecha_inicio': '2026-10-01',
        'fecha_fin': '2026-11-01',
      },
      {
        'id_membresia': 95,
        'estado': 'vencida',
        'fecha_inicio': '2026-09-01',
        'fecha_fin': '2026-10-01',
      },
      {
        'id_membresia': 82,
        'estado': 'inactiva',
        'fecha_inicio': '2026-08-01',
        'fecha_fin': '2026-09-01',
      },
    ];

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
          'HISTORIAL: ${nombreUsuario.toUpperCase()}',
          style: const TextStyle(
            fontFamily: 'Oswald',
            fontSize: 13,
            color: AppColors.verdePrimario,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
      ),
      body: FondoApp(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: historialMembresias.isEmpty
                        ? const Center(
                            child: Text(
                              'El usuario no tiene membresías registradas',
                              style: TextStyle(color: AppColors.grisClaro, fontSize: 13),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: historialMembresias.length,
                            itemBuilder: (context, index) {
                              final item = historialMembresias[index];
                              final String estado = item['estado'];
                              final bool esActiva = estado == 'activa';

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.grisOscuro,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: esActiva ? AppColors.verdePrimario.withOpacity(0.5) : AppColors.grisMedio.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      esActiva ? Icons.verified : Icons.history,
                                      color: esActiva ? AppColors.verdePrimario : AppColors.grisMedio,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Membresía #${item['id_membresia']}',
                                            style: const TextStyle(
                                              color: AppColors.blancoPuro,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Del ${item['fecha_inicio']} al ${item['fecha_fin']}',
                                            style: const TextStyle(color: AppColors.grisClaro, fontSize: 11),
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: esActiva ? AppColors.verdePrimario.withOpacity(0.15) : Colors.redAccent.withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              estado.toUpperCase(),
                                              style: TextStyle(
                                                color: esActiva ? AppColors.verdePrimario : Colors.redAccent,
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
              const BurbujaMiniChatModal(),
            ],
          ),
        ),
      ),
    );
  }
}