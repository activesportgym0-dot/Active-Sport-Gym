import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/core/formato.dart';
import 'package:frontend/componentes/fondo.dart';
import 'package:frontend/componentes/cliente/asistente/burbuja_mini_chat_modal.dart';
import 'package:frontend/models/pedido_model.dart';
import 'package:frontend/services/pedido_service.dart';

class PedidosAdminScreen extends StatefulWidget {
  const PedidosAdminScreen({super.key});

  @override
  State<PedidosAdminScreen> createState() => _PedidosAdminScreenState();
}

class _PedidosAdminScreenState extends State<PedidosAdminScreen> {
  String estadoFiltro = 'Todos';
  final List<String> estadosPermitidos = ['Todos', ...PedidoModel.estados];

  // Pedidos que vienen del servidor (GET /pedidos/admin)
  List<PedidoModel> _pedidosGlobales = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarPedidos();
  }

  Future<void> _cargarPedidos() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final pedidos = await PedidoService.obtenerTodosLosPedidos();
      if (!mounted) return;
      setState(() {
        _pedidosGlobales = pedidos;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al cargar los pedidos: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  List<PedidoModel> get pedidosFiltrados {
    if (estadoFiltro == 'Todos') return _pedidosGlobales;
    return _pedidosGlobales.where((p) => p.estado == estadoFiltro).toList();
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

  void _mostrarMensaje(String mensaje, {required bool exito}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: exito ? Colors.green : Colors.redAccent,
      ),
    );
  }

  Future<void> _guardarEstado(
    PedidoModel pedido,
    String nuevoEstado,
    String motivo,
  ) async {
    final resultado = await PedidoService.cambiarEstado(
      idPedido: pedido.idPedido,
      estado: nuevoEstado,
      motivo: nuevoEstado == 'Cancelado' ? motivo : null,
    );
    if (!mounted) return;

    final exito = resultado['success'] == true;
    _mostrarMensaje(
      resultado['message']?.toString() ?? 'Operación finalizada',
      exito: exito,
    );
    if (exito) await _cargarPedidos();
  }

  void _abrirModalCambiarEstado(PedidoModel pedido) {
    String nuevoEstadoSeleccionado =
        PedidoModel.estados.contains(pedido.estado) ? pedido.estado : 'Pendiente';
    final TextEditingController motivoController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (builderContext, setModalState) {
            return AlertDialog(
              backgroundColor: AppColors.grisOscuro,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                'ACTUALIZAR PEDIDO #${pedido.idPedido}',
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
                    items: PedidoModel.estados
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
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('CANCELAR', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.verdePrimario),
                  onPressed: () {
                    final motivo = motivoController.text.trim();
                    Navigator.pop(dialogContext);

                    // El backend rechaza el cambio al mismo estado; se avisa sin llamar.
                    if (nuevoEstadoSeleccionado == pedido.estado) {
                      _mostrarMensaje(
                        'El pedido ya está en estado $nuevoEstadoSeleccionado',
                        exito: false,
                      );
                      return;
                    }
                    _guardarEstado(pedido, nuevoEstadoSeleccionado, motivo);
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

              // Lista de Pedidos Globales (desliza hacia abajo para refrescar)
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.verdePrimario),
                      )
                    : RefreshIndicator(
                        color: AppColors.verdePrimario,
                        onRefresh: _cargarPedidos,
                        child: lista.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: const [
                                  SizedBox(height: 120),
                                  Center(
                                    child: Text('No hay pedidos registrados.', style: TextStyle(color: Colors.grey)),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(16),
                                itemCount: lista.length,
                                itemBuilder: (context, index) {
                                  final p = lista[index];
                                  final String estado = p.estado;
                                  final Color colorEstado = _obtenerColorEstado(estado);
                                  final String nombre = p.nombreCliente.isEmpty ? 'Cliente' : p.nombreCliente;
                                  final String cliente = p.correoCliente.isEmpty
                                      ? nombre
                                      : '$nombre (${p.correoCliente})';

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
                                              'PEDIDO #${p.idPedido}',
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
                                          'Cliente: $cliente',
                                          style: TextStyle(color: Colors.grey[300], fontSize: 13),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Fecha: ${p.fechaFormateada}',
                                          style: TextStyle(color: Colors.grey[500], fontSize: 11),
                                        ),
                                        const Divider(color: Colors.white12, height: 16),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Total: ${Formato.precio(p.total)}',
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
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: const BurbujaMiniChatModal(),
    );
  }
}
