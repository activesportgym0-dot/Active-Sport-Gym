import 'package:flutter/material.dart';
import 'package:frontend/componentes/administrador/reglasyhorarios/modal_regla_horario.dart';
import 'package:frontend/componentes/administrador/reglasyhorarios/regla_horario_card.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/componentes/fondo.dart';
import 'package:frontend/componentes/cliente/asistente/burbuja_mini_chat_modal.dart'; // 👈 Importación de la burbuja de la IA

class HorariosYReglasScreen extends StatefulWidget {
  const HorariosYReglasScreen({super.key});

  @override
  State<HorariosYReglasScreen> createState() => _HorariosYReglasScreenState();
}

class _HorariosYReglasScreenState extends State<HorariosYReglasScreen> {
  // Lista simulada inicial de registros (Conforme al backend)
  List<Map<String, dynamic>> _registros = [
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

  void _abrirModal({Map<String, dynamic>? registroExistente}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ModalReglaHorario(
        registroExistente: registroExistente,
        onSave: (tipo, titulo, contenido) {
          setState(() {
            if (registroExistente == null) {
              _registros.add({
                'id': DateTime.now().millisecondsSinceEpoch,
                'tipo': tipo,
                'titulo': titulo,
                'contenido': contenido,
              });
            } else {
              registroExistente['tipo'] = tipo;
              registroExistente['titulo'] = titulo;
              registroExistente['contenido'] = contenido;
            }
          });
        },
      ),
    );
  }

  void _eliminarRegistro(int id) {
    setState(() {
      _registros.removeWhere((item) => item['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registro eliminado correctamente'), backgroundColor: Colors.green),
    );
  }

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
          'ADMINISTRAR HORARIOS Y REGLAS',
          style: EstiloTexto.bienvenida.copyWith(
            fontFamily: 'Oswald',
            fontSize: 16,
            color: AppColors.verdePrimario,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      // 🌟 Usamos un Stack dentro de FondoApp para alojar la lista y la burbuja de la IA flotando libremente
      body: FondoApp(
        child: SafeArea(
          child: Stack(
            children: [
              // Lista con padding inferior de 100 para que la burbuja y el botón no tapen el contenido al deslizar
              ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
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
                      Text('${horarios.length} activos', style: EstiloTexto.textoNormalRoboto.copyWith(fontSize: 11, color: AppColors.grisClaro)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...horarios.map((item) => ReglaHorarioCard(
                        item: item,
                        onEdit: () => _abrirModal(registroExistente: item),
                        onDelete: () => _eliminarRegistro(item['id']),
                      )),

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
                          Text('REGLAS', style: EstiloTexto.tituloBienvenida.copyWith(color: AppColors.verdePrimario, fontSize: 16)),
                        ],
                      ),
                      Text('${reglas.length} activas', style: EstiloTexto.textoNormalRoboto.copyWith(fontSize: 11, color: AppColors.grisClaro)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...reglas.map((item) => ReglaHorarioCard(
                        item: item,
                        onEdit: () => _abrirModal(registroExistente: item),
                        onDelete: () => _eliminarRegistro(item['id']),
                      )),
                ],
              ),

              // 🌟 Burbuja de la IA interactiva y arrastrable por toda la pantalla
              const Positioned.fill(
                child: BurbujaMiniChatModal(),
              ),
            ],
          ),
        ),
      ),
      
      // Botón principal flotante extendido en su sitio habitual
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirModal(),
        backgroundColor: AppColors.verdePrimario,
        icon: const Icon(Icons.add, color: AppColors.fondoNegro),
        label: Text('NUEVO REGISTRO', style: EstiloTexto.botonPrincipal.copyWith(color: AppColors.fondoNegro, fontSize: 15)),
      ),
    );
  }
}