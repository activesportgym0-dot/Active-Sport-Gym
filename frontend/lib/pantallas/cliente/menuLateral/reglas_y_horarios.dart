import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/componentes/fondo.dart';

class HorariosYReglasClienteScreen extends StatefulWidget {
  const HorariosYReglasClienteScreen({super.key});

  @override
  State<HorariosYReglasClienteScreen> createState() => _HorariosYReglasClienteScreenState();
}

class _HorariosYReglasClienteScreenState extends State<HorariosYReglasClienteScreen> {
  // Lista simulada de consulta (Visual)
  final List<Map<String, dynamic>> _registros = [
    {
      'id': 1,
      'tipo': 'Horario',
      'titulo': 'Lunes a Viernes',
      'contenido': '5:00 a.m. - 10:00 p.m.',
    },
    {
      'id': 2,
      'tipo': 'Horario',
      'titulo': 'Sábados',
      'contenido': '6:00 a.m. - 6:00 p.m.',
    },
    {
      'id': 3,
      'tipo': 'Regla',
      'titulo': 'Uso de Toalla',
      'contenido': 'Es obligatorio el uso de toalla personal en todas las zonas de entrenamiento.',
    },
    {
      'id': 4,
      'tipo': 'Regla',
      'titulo': 'Orden de Equipamiento',
      'contenido': 'Retornar mancuernas, discos y barras a sus respectivos soportes al terminar.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final horarios = _registros.where((r) => r['tipo'] == 'Horario').toList();
    final reglas = _registros.where((r) => r['tipo'] == 'Regla').toList();

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
          'HORARIOS Y REGLAS',
          style: EstiloTexto.bienvenida.copyWith(
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
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // SECCIÓN DE HORARIOS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time_outlined, color: AppColors.verdePrimario, size: 20),
                      const SizedBox(width: 8),
                      Text('HORARIOS', style: EstiloTexto.tituloBienvenida.copyWith(color: AppColors.verdePrimario, fontSize: 16)),
                    ],
                  ),
                  Text('${horarios.length} disponibles', style: EstiloTexto.textoNormalRoboto.copyWith(fontSize: 11, color: AppColors.grisClaro)),
                ],
              ),
              const SizedBox(height: 10),
              ...horarios.map((item) => ReglaHorarioClienteCard(item: item)),

              const SizedBox(height: 25),
              const Divider(color: AppColors.grisMedio, thickness: 0.5),
              const SizedBox(height: 15),

              // SECCIÓN DE REGLAS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.rule_folder_outlined, color: AppColors.verdePrimario, size: 20),
                      const SizedBox(width: 8),
                      Text('REGLAS DEL GIMNASIO', style: EstiloTexto.tituloBienvenida.copyWith(color: AppColors.verdePrimario, fontSize: 16)),
                    ],
                  ),
                  Text('${reglas.length} establecidas', style: EstiloTexto.textoNormalRoboto.copyWith(fontSize: 11, color: AppColors.grisClaro)),
                ],
              ),
              const SizedBox(height: 10),
              ...reglas.map((item) => ReglaHorarioClienteCard(item: item)),
            ],
          ),
        ),
      ),
    );
  }
}

// Tarjeta exclusiva para el cliente (Solo lectura, sin botones de editar/eliminar)
class ReglaHorarioClienteCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const ReglaHorarioClienteCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final bool esHorario = item['tipo'] == 'Horario';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.grisOscuro,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.grisMedio.withOpacity(0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              esHorario ? Icons.schedule : Icons.check_circle_outline,
              color: AppColors.verdePrimario,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['titulo'],
                    style: EstiloTexto.textoNormalRoboto.copyWith(
                      color: AppColors.blancoPuro,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['contenido'],
                    style: EstiloTexto.textoNormalRoboto.copyWith(
                      color: AppColors.grisClaro,
                      fontSize: 12,
                      height: 1.3,
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