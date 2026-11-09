import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/models/rutina_guardada_model.dart';
import 'package:frontend/pantallas/cliente/rutina/diaria/crear_rutina_diaria_screen.dart';
import 'package:frontend/pantallas/cliente/rutina/semanal/crear_rutina_semanal_screen.dart';
import 'package:frontend/services/rutina_service.dart';

/// Editar y eliminar rutinas. Lo usan la lista (EntrenamientoScreen) y las pantallas de detalle,
/// así la confirmación, los mensajes y la navegación son los mismos en todos lados.
class AccionesRutina {
  static void _mensaje(BuildContext context, String texto, {required bool exito}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: exito ? Colors.green : Colors.redAccent,
      ),
    );
  }

  /// Pide confirmación y elimina la rutina en el servidor. Devuelve true si se eliminó.
  static Future<bool> eliminar(
    BuildContext context, {
    required int idRutina,
    required String nombre,
  }) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppColors.grisOscuro,
        title: const Text(
          'Eliminar rutina',
          style: TextStyle(color: Colors.white, fontFamily: 'Oswald'),
        ),
        content: Text(
          '¿Deseas eliminar "$nombre"? Se borrarán también sus ejercicios y series. Esta acción no se puede deshacer.',
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmado != true) return false;

    final resultado = await RutinaService.eliminarRutina(idRutina);
    if (!context.mounted) return false;
    _mensaje(context, resultado['message'].toString(), exito: resultado['success'] == true);
    return resultado['success'] == true;
  }

  /// Abre la pantalla de crear en modo edición (diaria o semanal según la rutina).
  /// Si no se pasa [rutina], se busca entre las rutinas del cliente por su id.
  /// Devuelve true si el usuario guardó los cambios.
  static Future<bool> editar(
    BuildContext context, {
    required int idRutina,
    RutinaGuardadaModel? rutina,
  }) async {
    var seleccionada = rutina;

    if (seleccionada == null) {
      try {
        final todas = await RutinaService.obtenerMisRutinas();
        for (final r in todas) {
          if (r.idRutina == idRutina) seleccionada = r;
        }
      } catch (e) {
        if (!context.mounted) return false;
        _mensaje(context, e.toString().replaceFirst('Exception: ', ''), exito: false);
        return false;
      }
    }

    if (!context.mounted) return false;
    if (seleccionada == null) {
      _mensaje(context, 'No se encontró la rutina para editarla.', exito: false);
      return false;
    }

    final rutinaAEditar = seleccionada;
    final guardado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => rutinaAEditar.esDiaria
            ? CrearRutinaDiariaScreen(rutinaEditar: rutinaAEditar)
            : CrearRutinaSemanalScreen(rutinaEditar: rutinaAEditar),
      ),
    );
    return guardado == true;
  }
}
