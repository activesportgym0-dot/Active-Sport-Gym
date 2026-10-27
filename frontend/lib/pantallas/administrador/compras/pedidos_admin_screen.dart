import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/componentes/fondo.dart';
import 'package:frontend/componentes/cliente/asistente/burbuja_mini_chat_modal.dart';

class PedidosAdminScreen extends StatefulWidget {
  const PedidosAdminScreen({super.key});

  @override
  State<PedidosAdminScreen> createState() => _PedidosAdminScreenState();
}

class _PedidosAdminScreenState extends State<PedidosAdminScreen> {
  String estadoFiltro = 'Todos';
  final List<String> estadosPermitidos = ['Todos', 'Pendiente', 'Aceptado', 'Completado', 'Cancelado'];

  // Lista simulada según la respuesta de obtenerTodosPedidos BD
  final List<Map<String, dynamic>> _pedidosGlobales = [
    {
      'id_pedido': 1001,
      'total': 115000,
      'estado': 'Pendiente',
      'created_at': '2026-10-16 08:30',
      'usuarios': {
        'nombre': 'Luisa Carvajal',
        'correo': 'luisa@gmail.com',
      },
      'detalle_pedidos': [
        {'nombre': 'Army BCAA', 'cantidad': 1, 'precio_unitario': 115000}
      ]
    },
    {
      'id_pedido': 1002,
      'total': 230000,
      'estado': 'Aceptado',
      'created_at': '2026-10-15 16:10',
      'usuarios': {
        'nombre': 'Carlos Ruiz',
        'correo': 'carlos@gmail.com',
      },
      'detalle_pedidos': [
        {'nombre': 'Best Protein', 'cantidad': 2, 'precio_unitario': 115000}
      ]
    },
  ];

  List<Map<String, dynamic>> get pedidosFiltrados {
    if (estadoFiltro == 'Todos') return _pedidosGlobales;
    return _pedidosGlobales.where((p) => p['estado'] == estadoFiltro).toList();
  }

  Color _obtenerColorEstado(String estado) {
    switch (estado) {
      case 'Pendiente':
        return Colors.orangeAccent;
      case 'Aceptado':
        return Colors.blueAccent;
      case 'Completado':
        return AppColors.verdePrimario;
      case 'Cancelado':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  void _abrirModalCambiarEstado(Map<String, dynamic> pedido) {
    String nuevoEstadoSeleccionado = pedido['estado'];
    final TextEditingController motivoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: AppColors.grisOscuro,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                'ACTUALIZAR PEDIDO #${pedido['id_pedido']}',
                style: EstiloTexto.tekoSubtituloSeccion.copyWith(color: AppColors.verdePrimario, fontSize: 18),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Selecciona el nuevo estado:', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: nuevoEstadoSeleccionado,
                    dropdownColor: AppColors.fondoNegro,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.verdePrimario.withOpacity(0.5))),
                      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.verdePrimario)),
                      filled: true,
                      fillColor: Colors.black26,
                    ),
                    items: ['Pendiente', 'Aceptado', 'Completado', 'Cancelado']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          nuevoEstadoSeleccionado = val;
                        });
                      }
                    },
                  ),
                  if (nuevoEstadoSeleccionado == 'Cancelado') ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: motivoController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Motivo de cancelación',
                        labelStyle: TextStyle(color: Colors.grey),
                        hintText: 'Ej. Sin stock en depósito',
                        hintStyle: TextStyle(color: Colors.white24),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCELAR', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.verdePrimario),
                  onPressed: () {
                    setState(() {
                      pedido['estado'] = nuevoEstadoSeleccionado;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Estado actualizado a $nuevoEstadoSeleccionado'),
                        backgroundColor: Colors.black87,
                      ),
                    );
                  },
                  child: const Text('GUARDAR', style: TextStyle(color: AppColors.fondoNegro, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatearPrecio(num valor) {
    String precioStr = valor.toInt().toString();
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return '\$${precioStr.replaceAllMapped(reg, (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    final lista = pedidosFiltrados;

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
          'GESTIÓN DE PEDIDOS (ADMIN)',
          style: EstiloTexto.tekoTituloSeccion.copyWith(fontSize: 18),
        ),
      ),
      body: FondoApp(
        child: SafeArea(
          child: Column(
            children: [
              // Filtro por Estado
              SizedBox(
                height: 42,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  itemCount: estadosPermitidos.length,
                  itemBuilder: (context, index) {
                    final estado = estadosPermitidos[index];
                    bool sel = estadoFiltro == estado;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          estadoFiltro = estado;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: sel ? AppColors.verdePrimario : AppColors.grisOscuro,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: sel ? AppColors.verdePrimario : Colors.grey.withOpacity(0.3)),
                        ),
                        child: Text(
                          estado,
                          style: TextStyle(
                            color: sel ? AppColors.fondoNegro : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Lista de Pedidos Globales
              Expanded(
                child: lista.isEmpty
                    ? const Center(
                        child: Text('No hay pedidos registrados.', style: TextStyle(color: Colors.grey)),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: lista.length,
                        itemBuilder: (context, index) {
                          final p = lista[index];
                          final String estado = p['estado'];
                          final Color colorEstado = _obtenerColorEstado(estado);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.grisOscuro.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.withOpacity(0.2)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'PEDIDO #${p['id_pedido']}',
                                      style: const TextStyle(
                                        fontFamily: 'Teko',
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: colorEstado.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: colorEstado),
                                      ),
                                      child: Text(
                                        estado,
                                        style: TextStyle(color: colorEstado, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Cliente: ${p['usuarios']['nombre']} (${p['usuarios']['correo']})',
                                  style: TextStyle(color: Colors.grey[300], fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Fecha: ${p['created_at']}',
                                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                                ),
                                const Divider(color: Colors.white12, height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total: ${_formatearPrecio(p['total'])}',
                                      style: const TextStyle(
                                        fontFamily: 'Teko',
                                        color: AppColors.verdePrimario,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: AppColors.verdePrimario),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      icon: const Icon(Icons.edit_note, color: AppColors.verdePrimario, size: 18),
                                      label: const Text('CAMBIAR ESTADO', style: TextStyle(color: AppColors.verdePrimario, fontSize: 11)),
                                      onPressed: () => _abrirModalCambiarEstado(p),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: const BurbujaMiniChatModal(),
    );
  }
}