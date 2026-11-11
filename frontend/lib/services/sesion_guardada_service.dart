import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/perfil_model.dart';
import 'auth_service.dart'; // SessionService
import 'perfil_cache.dart';
import 'perfil_service.dart';

/// "Recuérdame": guarda la sesión en el teléfono para no pedir correo y contraseña cada vez.
/// Se guarda el token (dura 30 días), el rol, el nombre, el id y el correo. La contraseña NUNCA se guarda.
class SesionGuardada {
  static const String _kRecordar = 'sesion_recordar';
  static const String _kToken = 'sesion_token';
  static const String _kRol = 'sesion_rol';
  static const String _kNombre = 'sesion_nombre';
  static const String _kIdUsuario = 'sesion_id_usuario';
  static const String _kCorreo = 'sesion_correo';

  /// Guarda lo que hay en SessionService (llamar justo después de un login exitoso con "Recuérdame" marcado).
  static Future<void> guardar(String correo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kRecordar, true);
    await prefs.setString(_kToken, SessionService.token);
    await prefs.setString(_kRol, SessionService.rol);
    await prefs.setString(_kNombre, SessionService.nombreUsuario);
    await prefs.setString(_kCorreo, correo);
    final id = SessionService.idUsuario;
    if (id != null) await prefs.setInt(_kIdUsuario, id);
  }

  /// Correo que se recordó (para rellenarlo en el login), o null si no se marcó "Recuérdame".
  static Future<String?> correoRecordado() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_kRecordar) != true) return null;
    return prefs.getString(_kCorreo);
  }

  /// Borra todo lo guardado. Se llama al cerrar sesión o si se entra con "Recuérdame" desmarcado.
  static Future<void> olvidar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kRecordar);
    await _borrarSesion(prefs);
    await prefs.remove(_kCorreo);
  }

  // Borra la sesión pero deja el correo, para que el login lo siga rellenando
  static Future<void> _borrarSesion(SharedPreferences prefs) async {
    await prefs.remove(_kToken);
    await prefs.remove(_kRol);
    await prefs.remove(_kNombre);
    await prefs.remove(_kIdUsuario);
  }

  /// Intenta volver a entrar con la sesión guardada.
  /// Devuelve el rol ('admin' o 'cliente') si la sesión sigue siendo válida, o null si hay que iniciar sesión.
  static Future<String?> restaurar() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_kRecordar) != true) return null;

    final token = prefs.getString(_kToken) ?? '';
    final id = prefs.getInt(_kIdUsuario);
    if (token.isEmpty || id == null || _tokenVencido(token)) {
      await _borrarSesion(prefs);
      return null;
    }

    // El token solo sirve si el servidor todavía lo acepta (la cuenta puede haberse desactivado o borrado)
    SessionService.token = token;
    SessionService.rol = prefs.getString(_kRol) ?? 'cliente';
    SessionService.nombreUsuario = prefs.getString(_kNombre) ?? '';
    SessionService.idUsuario = id;

    final r = await PerfilService.obtenerPerfil(id);
    if (r['success'] == true) {
      final perfil = r['perfil'] as PerfilModel;
      // Se refrescan rol y nombre por si el administrador los cambió
      SessionService.rol = perfil.rol;
      SessionService.nombreUsuario = perfil.nombre;
      await prefs.setString(_kRol, perfil.rol);
      await prefs.setString(_kNombre, perfil.nombre);
      PerfilCache.guardar(perfil); // deja listos el menú y el perfil
      return perfil.rol;
    }

    // El servidor no la aceptó: se descarta y se pide iniciar sesión
    SessionService.limpiarSesion(borrarGuardada: false);
    await _borrarSesion(prefs);
    return null;
  }

  // Lee la fecha de vencimiento (exp) que trae el token, sin llamar al servidor
  static bool _tokenVencido(String token) {
    try {
      final partes = token.split('.');
      if (partes.length != 3) return true;
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(partes[1]))),
      );
      final exp = payload['exp'];
      if (exp is! int) return false;
      return DateTime.now().millisecondsSinceEpoch ~/ 1000 >= exp;
    } catch (_) {
      return true;
    }
  }
}
