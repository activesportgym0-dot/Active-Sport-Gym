import 'package:flutter/foundation.dart';
import '../models/chat_model.dart';
import 'auth_service.dart';
import 'chat_service.dart';

/// Conversación del chat con la IA (una para el cliente y otra para el administrador).
///
/// Vive en memoria mientras el usuario esté dentro de la app con su sesión iniciada,
/// así el historial NO se pierde al cambiar de pantalla (cada pantalla crea su propia burbuja).
/// El envío se hace aquí y no dentro de la burbuja: si cambias de pantalla mientras
/// la IA responde, la respuesta igual llega y queda guardada.
class ConversacionChat extends ChangeNotifier {
  ConversacionChat._(this.esAdmin);

  final bool esAdmin;
  String? _sesionId;
  final List<MensajeChatLocal> _mensajes = [];
  bool _cargando = false;

  List<MensajeChatLocal> get mensajes => List.unmodifiable(_mensajes);
  bool get cargando => _cargando;

  Future<void> enviar(String texto) async {
    final limpio = texto.trim();
    if (limpio.isEmpty || _cargando) return;

    _mensajes.add(MensajeChatLocal(texto: limpio, fecha: DateTime.now(), esUsuario: true));
    _cargando = true;
    notifyListeners();

    try {
      final res = esAdmin
          ? await ChatService.enviarMensajeAdmin(mensaje: limpio, sesionId: _sesionId)
          : await ChatService.enviarMensajeCliente(mensaje: limpio, sesionId: _sesionId);

      if (res.sesionId.isNotEmpty) _sesionId = res.sesionId;

      _mensajes.add(MensajeChatLocal(
        texto: res.respuesta.isEmpty
            ? 'No pude generar una respuesta. ¿Puedes intentarlo de nuevo?'
            : res.respuesta,
        fecha: DateTime.now(),
        esUsuario: false,
      ));
    } catch (e) {
      _mensajes.add(MensajeChatLocal(
        texto: e.toString().replaceFirst('Exception: ', ''),
        fecha: DateTime.now(),
        esUsuario: false,
        esError: true,
      ));
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }
}

/// Guarda las conversaciones mientras dure la sesión del usuario.
/// Si cambia el token (cerró sesión y entró otra persona), se empieza de cero:
/// así nadie ve la conversación de otro usuario.
class ChatSessionStore {
  static String _tokenActual = '';
  static final Map<String, ConversacionChat> _conversaciones = {};

  static ConversacionChat obtener({required bool esAdmin}) {
    if (_tokenActual != SessionService.token) {
      _conversaciones.clear();
      _tokenActual = SessionService.token;
    }
    return _conversaciones.putIfAbsent(
      esAdmin ? 'admin' : 'cliente',
      () => ConversacionChat._(esAdmin),
    );
  }
}
