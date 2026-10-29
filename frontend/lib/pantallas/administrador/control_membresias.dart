import 'package:flutter/material.dart';
import 'package:frontend/componentes/administrador/membresia/control_membresia_admin.dart';
import 'package:frontend/componentes/cliente/asistente/burbuja_mini_chat_modal.dart';
import 'package:frontend/componentes/fondo.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/models/membresia_model.dart';
import 'package:frontend/services/membresia_service.dart';

class MembresiasAdminScreen extends StatefulWidget {
  const MembresiasAdminScreen({super.key});

  @override
  State<MembresiasAdminScreen> createState() => _MembresiasAdminScreenState();
}

class _MembresiasAdminScreenState extends State<MembresiasAdminScreen> {
  static const List<String> _filtros = [
    'Todos',
    'Activa',
    'Inactiva',
    'Vencida',
    'Sin membresía',
  ];

  String _filtroSeleccionado = 'Todos';
  final TextEditingController _searchController = TextEditingController();

  // Clientes con su membresía más reciente (GET /membresias/admin)
  List<ClienteMembresiaModel> _clientes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) setState(() {});
    });
    _cargarClientes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarClientes() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final clientes = await MembresiaService.obtenerClientesConMembresia();
      if (!mounted) return;
      setState(() {
        _clientes = clientes;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _mostrarMensaje(
        'Error al cargar las membresías: ${e.toString().replaceFirst('Exception: ', '')}',
        exito: false,
      );
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

  // Mismos colores que usa la tarjeta ControlMembresiaAdmin
  Color _colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'activa':
        return AppColors.verdePrimario;
      case 'vencida':
        return Colors.redAccent;
      case 'inactiva':
        return Colors.orangeAccent;
      default:
        return Colors.grey;
    }
  }

  List<ClienteMembresiaModel> get _clientesFiltrados {
    final texto = _searchController.text.toLowerCase().trim();

    return _clientes.where((c) {
      final coincideTexto = texto.isEmpty ||
          c.nombre.toLowerCase().contains(texto) ||
          c.correo.toLowerCase().contains(texto);

      bool coincideFiltro;
      if (_filtroSeleccionado == 'Todos') {
        coincideFiltro = true;
      } else if (_filtroSeleccionado == 'Sin membresía') {
        coincideFiltro = c.membresia == null;
      } else {
        coincideFiltro = c.membresia?.estado == _filtroSeleccionado.toLowerCase();
      }

      return coincideTexto && coincideFiltro;
    }).toList();
  }

  // ACCIONES

  void _abrirDetalle(ClienteMembresiaModel cliente) {
    final membresia = cliente.membresia;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.fondoNegro,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            20,
            16,
            MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cliente.nombre.toUpperCase(),
                  style: EstiloTexto.tituloBienvenida.copyWith(
                    fontSize: 18,
                    color: AppColors.verdePrimario,
                  ),
                ),
                if (cliente.correo.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    cliente.correo,
                    style: EstiloTexto.textoNormalRoboto.copyWith(
                      color: AppColors.grisClaro,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                ControlMembresiaAdmin(
                  estadoMembresia: cliente.estadoVisible,
                  fechaInicio: membresia?.fechaInicioFormateada ?? '—',
                  fechaFin: membresia?.fechaFinFormateada ?? '—',
                  onEstadoChanged: (nuevoEstado) {
                    Navigator.pop(sheetContext);
                    _cambiarEstado(cliente, nuevoEstado);
                  },
                  onRenovarAsignar: () {
                    Navigator.pop(sheetContext);
                    _abrirDialogoAsignar(cliente);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _cambiarEstado(ClienteMembresiaModel cliente, String nuevoEstado) async {
    final membresia = cliente.membresia;

    if (membresia == null) {
      _mostrarMensaje(
        'Este cliente no tiene un plan. Usa "Asignar / Renovar plan" primero.',
        exito: false,
      );
      return;
    }
    if (membresia.estado == nuevoEstado) {
      _mostrarMensaje('La membresía ya está en estado $nuevoEstado.', exito: false);
      return;
    }

    final resultado = await MembresiaService.cambiarEstado(
      idMembresia: membresia.idMembresia,
      estado: nuevoEstado,
    );
    if (!mounted) return;

    final exito = resultado['success'] == true;
    _mostrarMensaje(resultado['message']?.toString() ?? 'Operación finalizada', exito: exito);
    if (exito) await _cargarClientes();
  }

  DateTime _soloFecha(DateTime f) => DateTime(f.year, f.month, f.day);
  DateTime _sumarMes(DateTime f) => DateTime(f.year, f.month + 1, f.day);

  Future<void> _abrirDialogoAsignar(ClienteMembresiaModel cliente) async {
    String estado = 'activa';
    DateTime inicio = _soloFecha(DateTime.now());
    DateTime fin = _sumarMes(inicio);
    String? errorFechas;

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (builderContext, setDialogState) {
            Future<void> elegirFecha({required bool esInicio}) async {
              final elegida = await showDatePicker(
                context: builderContext,
                initialDate: esInicio ? inicio : fin,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                builder: (pickerContext, child) => Theme(
                  data: Theme.of(pickerContext).copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: AppColors.verdePrimario,
                      onPrimary: AppColors.fondoNegro,
                      surface: AppColors.grisOscuro,
                      onSurface: AppColors.blancoPuro,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (elegida == null) return;

              setDialogState(() {
                errorFechas = null;
                if (esInicio) {
                  inicio = elegida;
                  // Si el fin quedó antes del nuevo inicio, se ajusta a un mes después
                  if (!fin.isAfter(inicio)) fin = _sumarMes(inicio);
                } else {
                  fin = elegida;
                }
              });
            }

            Widget filaFecha(String titulo, DateTime valor, bool esInicio) {
              return InkWell(
                onTap: () => elegirFecha(esInicio: esInicio),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.verdePrimario.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(color: AppColors.grisClaro, fontSize: 12),
                      ),
                      Row(
                        children: [
                          Text(
                            MembresiaModel.fechaCorta(valor),
                            style: const TextStyle(
                              color: AppColors.blancoPuro,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.calendar_today, color: AppColors.verdePrimario, size: 16),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }

            return AlertDialog(
              backgroundColor: AppColors.grisOscuro,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                'ASIGNAR / RENOVAR PLAN',
                style: EstiloTexto.tekoSubtituloSeccion.copyWith(
                  color: AppColors.verdePrimario,
                  fontSize: 18,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cliente: ${cliente.nombre}',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Estado del plan:',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: estado,
                      dropdownColor: AppColors.fondoNegro,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.verdePrimario.withOpacity(0.5)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.verdePrimario),
                        ),
                        filled: true,
                        fillColor: Colors.black26,
                      ),
                      items: MembresiaModel.estados
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e[0].toUpperCase() + e.substring(1)),
                            ),
                          )
                          .toList(),
                      onChanged: (valor) {
                        if (valor != null) setDialogState(() => estado = valor);
                      },
                    ),
                    const SizedBox(height: 14),
                    filaFecha('Fecha de inicio', inicio, true),
                    const SizedBox(height: 10),
                    filaFecha('Fecha de fin', fin, false),
                    if (errorFechas != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        errorFechas!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('CANCELAR', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.verdePrimario),
                  onPressed: () {
                    if (!fin.isAfter(inicio)) {
                      setDialogState(
                        () => errorFechas = 'La fecha de fin debe ser posterior a la de inicio.',
                      );
                      return;
                    }
                    Navigator.pop(dialogContext, true);
                  },
                  child: const Text(
                    'GUARDAR',
                    style: TextStyle(color: AppColors.fondoNegro, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmado != true || !mounted) return;

    final resultado = await MembresiaService.asignarMembresia(
      idUsuario: cliente.idUsuario,
      estado: estado,
      fechaInicio: MembresiaModel.fechaIso(inicio),
      fechaFin: MembresiaModel.fechaIso(fin),
    );
    if (!mounted) return;

    final exito = resultado['success'] == true;
    _mostrarMensaje(resultado['message']?.toString() ?? 'Operación finalizada', exito: exito);
    if (exito) await _cargarClientes();
  }

  // INTERFAZ

  @override
  Widget build(BuildContext context) {
    final lista = _clientesFiltrados;

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
          'GESTIÓN DE MEMBRESÍAS (ADMIN)',
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
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Buscador por nombre o correo
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: TextField(
                      controller: _searchController,
                      style: EstiloTexto.campoTexto,
                      decoration: InputDecoration(
                        hintText: 'Buscar cliente por nombre o correo...',
                        hintStyle: EstiloTexto.hintTexto,
                        filled: true,
                        fillColor: AppColors.grisOscuro,
                        prefixIcon: const Icon(Icons.search, color: AppColors.grisMedio, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),

                  // Filtro por estado
                  SizedBox(
                    height: 42,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      itemCount: _filtros.length,
                      itemBuilder: (context, index) {
                        final filtro = _filtros[index];
                        final bool sel = _filtroSeleccionado == filtro;
                        return GestureDetector(
                          onTap: () => setState(() => _filtroSeleccionado = filtro),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: sel ? AppColors.verdePrimario : AppColors.grisOscuro,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: sel ? AppColors.verdePrimario : Colors.grey.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              filtro,
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

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'CLIENTES',
                          style: EstiloTexto.enlaceNegritaRoboto.copyWith(letterSpacing: 1.1),
                        ),
                        Text(
                          '${lista.length} en total',
                          style: EstiloTexto.textoNormalRoboto.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Lista de clientes (desliza hacia abajo para refrescar)
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(color: AppColors.verdePrimario),
                          )
                        : RefreshIndicator(
                            color: AppColors.verdePrimario,
                            onRefresh: _cargarClientes,
                            child: lista.isEmpty
                                ? ListView(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    children: const [
                                      SizedBox(height: 120),
                                      Center(
                                        child: Text(
                                          'No se encontraron clientes.',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                    ],
                                  )
                                : ListView.builder(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                                    itemCount: lista.length,
                                    itemBuilder: (context, index) {
                                      return _construirTarjetaCliente(lista[index]);
                                    },
                                  ),
                          ),
                  ),
                ],
              ),

              // Burbuja de la IA interactiva y arrastrable por toda la pantalla
              const Positioned.fill(
                child: BurbujaMiniChatModal(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirTarjetaCliente(ClienteMembresiaModel cliente) {
    final membresia = cliente.membresia;
    final Color colorEstado = _colorEstado(cliente.estadoVisible);

    return GestureDetector(
      onTap: () => _abrirDetalle(cliente),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.grisOscuro.withOpacity(0.85),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorEstado.withOpacity(0.35)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cliente.nombre,
                    style: EstiloTexto.enlaceNegritaRoboto.copyWith(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (cliente.correo.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      cliente.correo,
                      style: EstiloTexto.textoNormalRoboto.copyWith(
                        color: AppColors.grisClaro,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    membresia == null
                        ? 'Sin plan registrado'
                        : 'Vence: ${membresia.fechaFinFormateada}',
                    style: TextStyle(color: Colors.grey[400], fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colorEstado.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorEstado),
              ),
              child: Text(
                cliente.estadoVisible.toUpperCase(),
                style: TextStyle(
                  color: colorEstado,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: AppColors.grisMedio, size: 20),
          ],
        ),
      ),
    );
  }
}
