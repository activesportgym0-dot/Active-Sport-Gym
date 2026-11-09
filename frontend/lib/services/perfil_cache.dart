import 'package:frontend/models/perfil_model.dart';
import 'package:frontend/services/auth_service.dart'; // SessionService

/// Perfil del usuario guardado en memoria. Lo comparten el menú lateral y la pantalla de perfil,
/// así ninguno vuelve a quedar vacío esperando al servidor cada vez que se abre.
class PerfilCache {
  static int? _idUsuario;
  static PerfilModel? _perfil;

  /// Perfil guardado del usuario con sesión activa (null si no hay ninguno, o si era de otro usuario).
  static PerfilModel? get perfil =>
      _idUsuario == SessionService.idUsuario ? _perfil : null;

  static void guardar(PerfilModel perfil) {
    _idUsuario = SessionService.idUsuario;
    _perfil = perfil;
  }

  /// Se llama al cerrar sesión.
  static void limpiar() {
    _idUsuario = null;
    _perfil = null;
  }
}
