import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

class TarjetaEjercicioAgregado extends StatelessWidget {
  final int numeroEjercicio;
  final Map<String, dynamic> ejercicioData;
  final VoidCallback onAgregarSerie;
  final VoidCallback onEliminarEjercicio;
  final Function(int index) onEliminarSerie;

  const TarjetaEjercicioAgregado({
    super.key,
    required this.numeroEjercicio,
    required this.ejercicioData,
    required this.onAgregarSerie,
    required this.onEliminarEjercicio,
    required this.onEliminarSerie,
  });

  @override
  Widget build(BuildContext context) {
    final List series = ejercicioData['series'] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grisOscuro,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ejercicio $numeroEjercicio',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${ejercicioData['category']?.toString().toUpperCase()} - RESISTENCIA',
                      style: const TextStyle(color: AppColors.verdePrimario, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ejercicioData['title'] ?? 'Sin nombre',
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  ejercicioData['imagePath'] ?? 'assets/images/3.jpg',
                  width: 90,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Listado dinámico interno de series
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: series.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Text(
                      'Serie ${index + 1}',
                      style: const TextStyle(color: AppColors.verdePrimario, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 10),
                    const Text('repeticion:', style: TextStyle(color: Colors.grey, fontSize: 11)),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 35,
                      height: 25,
                      child: TextField(
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.fondoNegro,
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text('Peso:', style: TextStyle(color: Colors.grey, fontSize: 11)),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 35,
                      height: 25,
                      child: TextField(
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.fondoNegro,
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (series.length > 1)
                      GestureDetector(
                        onTap: () => onEliminarSerie(index),
                        child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 10),

          // Tiempos de descanso
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Text('DESCANSO ENTRE SERIES:', style: TextStyle(color: Colors.grey, fontSize: 8)),
                    const SizedBox(width: 2),
                    SizedBox(
                      width: 35,
                      height: 22,
                      child: TextField(
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.fondoNegro,
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const Text(' Seg', style: TextStyle(color: Colors.grey, fontSize: 8)),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    const Text('DESCANSO FINAL:', style: TextStyle(color: Colors.grey, fontSize: 8)),
                    const SizedBox(width: 2),
                    SizedBox(
                      width: 35,
                      height: 22,
                      child: TextField(
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.fondoNegro,
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const Text(' Seg', style: TextStyle(color: Colors.grey, fontSize: 8)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Botones de acción de la tarjeta
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 30,
                  child: ElevatedButton(
                    onPressed: onAgregarSerie,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.verdePrimario,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('AGREGAR SERIE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: SizedBox(
                  height: 30,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.verdePrimario,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('EDITAR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: SizedBox(
                  height: 30,
                  child: ElevatedButton(
                    onPressed: onEliminarEjercicio,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.verdePrimario,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('ELIMINAR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}