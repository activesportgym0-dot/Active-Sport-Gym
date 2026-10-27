import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/componentes/cliente/asistente/burbuja_mini_chat_modal.dart';

class DetalleMedidaScreen extends StatelessWidget {
  final Map<String, dynamic> medida;

  const DetalleMedidaScreen({
    super.key,
    required this.medida,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(decoration: TextDecoration.none),
      child: Scaffold(
        backgroundColor: AppColors.fondoNegro,
        body: Stack(
          children: [
            // Fondo con gradiente institucional
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF111111),
                      AppColors.fondoNegro,
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // Barra superior con botón de regreso
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back_ios_new, color: AppColors.verdePrimario, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'DETALLE DE MEDIDAS',
                          style: TextStyle(
                            fontFamily: 'Oswald',
                            color: AppColors.verdePrimario,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Contenido desplazable con los detalles
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tarjeta de Fecha de Registro
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.grisOscuro,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.verdePrimario.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Fecha de registro:',
                                  style: TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                                Text(
                                  medida['created_at'] ?? 'N/A',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Tarjeta con la lista completa de medidas corporales
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.grisOscuro.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Column(
                              children: [
                                const Center(
                                  child: Text(
                                    'REGISTRO ANTROPOMÉTRICO',
                                    style: TextStyle(
                                      fontFamily: 'Oswald',
                                      color: AppColors.verdePrimario,
                                      fontSize: 15,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                                const Divider(color: Colors.white12, height: 20),
                                _buildFichaDetalle('Peso Actual', '${medida['peso_actual'] ?? 'N/A'} Kg'),
                                _buildFichaDetalle('Altura', '${medida['altura'] ?? 'N/A'} m'),
                                _buildFichaDetalle('Brazo Izquierdo', '${medida['brazo_izquierdo'] ?? 'N/A'} cm'),
                                _buildFichaDetalle('Brazo Derecho', '${medida['brazo_derecho'] ?? 'N/A'} cm'),
                                _buildFichaDetalle('Pecho', '${medida['pecho'] ?? 'N/A'} cm'),
                                _buildFichaDetalle('Cintura', '${medida['cintura'] ?? 'N/A'} cm'),
                                _buildFichaDetalle('Cadera', '${medida['cadera'] ?? 'N/A'} cm'),
                                _buildFichaDetalle('Muslo Izquierdo', '${medida['muslo_izquierdo'] ?? 'N/A'} cm'),
                                _buildFichaDetalle('Muslo Derecho', '${medida['muslo_derecho'] ?? 'N/A'} cm'),
                                _buildFichaDetalle('Pantorrilla Izquierda', '${medida['pantorrilla_izquierda'] ?? 'N/A'} cm'),
                                _buildFichaDetalle('Pantorrilla Derecha', '${medida['pantorrilla_derecha'] ?? 'N/A'} cm'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Botón inferior para volver
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.verdePrimario,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'VOLVER',
                                style: TextStyle(
                                  fontFamily: 'Oswald',
                                  color: AppColors.fondoNegro,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          
                          // 🌟 Espacio extra al final para que la burbuja flotante no tape el botón inferior al deslizar
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // 🌟 Burbuja de chat flotante de la IA integrada
        floatingActionButton: const BurbujaMiniChatModal(),
      ),
    );
  }

  Widget _buildFichaDetalle(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}