import 'package:flutter/material.dart';
import 'package:frontend/componentes/cliente/home/tarjeta_ejercicio.dart';

class ListaEjerciciosCliente extends StatelessWidget {
  final List<Map<String, String>> ejercicios;

  const ListaEjerciciosCliente({
    super.key,
    required this.ejercicios,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ejercicios.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final ejercicio = ejercicios[index];
        return TarjetaEjercicio(
          category: ejercicio['category']!,
          title: ejercicio['title']!,
          description: ejercicio['description']!,
          imagePath: ejercicio['imagePath']!,
        );
      },
    );
  }
}