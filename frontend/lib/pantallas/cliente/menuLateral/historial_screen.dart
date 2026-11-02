import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/componentes/fondo.dart';
import 'package:frontend/models/historial_model.dart';
import 'package:frontend/services/historial_service.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  // Entrenamientos reales del cliente (GET /historial)
  List<HistorialModel> _historial = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  void _mostrarMensaje(String mensaje, {required bool exito}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: exito ? Colors.green : Colors.redAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _cargarHistorial() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final historial = await HistorialService.obtenerMiHistorial();
      if (!mounted) return;
      setState(() {
        _historial = historial;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _mostrarMensaje(
        'Error al cargar tu historial: ${e.toString().replaceFirst('Exception: ', '')}',
        exito: false,
      );
    }
  }

  // DELETE /historial/:id (borrarHistorialPorId)
  Future<void> _eliminarRegistro(int idHistorial) async {
    final resultado = await HistorialService.eliminarRegistro(idHistorial);
    if (!mounted) return;

    final exito = resultado['success'] == true;
    _mostrarMensaje(
      exito ? 'Registro eliminado del historial' : resultado['message'].toString(),
      exito: false, // se mantiene el rojo de tu diseño original al eliminar
    );
    if (exito) await _cargarHistorial();
  }

  // DELETE /historial (borrarTodoElHistorial)
  Future<void> _vaciarHistorial() async {
    final resultado = await HistorialService.vaciarHistorial();
    if (!mounted) return;

    final exito = resultado['success'] == true;
    _mostrarMensaje(
      exito ? 'Se ha vaciado todo el historial' : resultado['message'].toString(),
      exito: false,
    );
    if (exito) await _cargarHistorial();
  }

  // Confirmar y eliminar un registro individual
  void _confirmarEliminarUnico(int idHistorial, String nombreRutina) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.grisOscuro,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          '¿ELIMINAR REGISTRO?',
          style: TextStyle(fontFamily: 'Oswald', color: Colors.white, fontSize: 18),
        ),
        content: Text(
          '¿Estás seguro de eliminar el registro de "$nombreRutina" del historial?',
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(dialogContext);
              _eliminarRegistro(idHistorial);
            },
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Confirmar y vaciar todo el historial
  void _confirmarVaciarHistorial() {
    if (_historial.isEmpty) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.grisOscuro,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          '¿VACIAR TODO EL HISTORIAL?',
          style: TextStyle(fontFamily: 'Oswald', color: Colors.redAccent, fontSize: 18),
        ),
        content: const Text(
          'Esta acción borrará permanentemente todas las rutinas completadas que tienes guardadas.',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(dialogContext);
              _vaciarHistorial();
            },
            child: const Text('VACIAR TODO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

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
        title: Text(
          'HISTORIAL DE RUTINAS',
          style: EstiloTexto.tekoTituloSeccion.copyWith(fontSize: 18),
        ),
        actions: [
          if (_historial.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 22),
              tooltip: 'Vaciar Historial',
              onPressed: _confirmarVaciarHistorial,
            ),
        ],
      ),
      body: FondoApp(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.verdePrimario),
                  )
                : RefreshIndicator(
                    color: AppColors.verdePrimario,
                    onRefresh: _cargarHistorial,
                    child: _historial.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              const SizedBox(height: 120),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.history_toggle_off_rounded, size: 64, color: AppColors.verdePrimario.withOpacity(0.4)),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'No tienes entrenamientos registrados.',
                                      style: TextStyle(color: Colors.grey, fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Completa una rutina para ver tu progreso aquí.',
                                      style: TextStyle(color: Colors.white38, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: _historial.length,
                            itemBuilder: (context, index) {
                              final item = _historial[index];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                decoration: BoxDecoration(
                                  color: AppColors.grisOscuro.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.verdePrimario.withOpacity(0.25)),
                                ),
                                child: ExpansionTile(
                                  iconColor: AppColors.verdePrimario,
                                  collapsedIconColor: Colors.grey,
                                  tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  title: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.verdePrimario.withOpacity(0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.check_circle_outline_rounded, color: AppColors.verdePrimario, size: 20),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.nombreRutina.toUpperCase(),
                                              style: const TextStyle(
                                                fontFamily: 'Oswald',
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${item.fechaFormateada} • ${item.tiempoTotalFormateado}',
                                              style: const TextStyle(color: AppColors.verdePrimario, fontSize: 12, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Botón individual de papelera
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.white38, size: 20),
                                        onPressed: () => _confirmarEliminarUnico(item.idHistorial, item.nombreRutina),
                                      ),
                                    ],
                                  ),
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(14),
                                      decoration: const BoxDecoration(
                                        color: Colors.black26,
                                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'EJERCICIOS COMPLETADOS:',
                                            style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 8),
                                          if (item.ejercicios.isEmpty)
                                            const Text(
                                              'Sin detalle de ejercicios.',
                                              style: TextStyle(color: Colors.white38, fontSize: 12),
                                            ),
                                          ...item.ejercicios.map((ej) {
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 3),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      '• ${ej.nombre}',
                                                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                                                    ),
                                                  ),
                                                  Text(
                                                    ej.tiempoFormateado,
                                                    style: const TextStyle(color: AppColors.verdePrimario, fontSize: 12, fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ),
      ),
    );
  }
}