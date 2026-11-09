class ChatResponseModel {
  final String respuesta;
  final String sesionId;

  ChatResponseModel({
    required this.respuesta,
    required this.sesionId,
  });

  factory ChatResponseModel.fromJson(Map<String, dynamic> json) {
    return ChatResponseModel(
      respuesta: json['respuesta'] ?? '',
      sesionId: json['sesionId'] ?? '',
    );
  }
}

/// Un mensaje de la conversación tal como se muestra en la burbuja del chat.
class MensajeChatLocal {
  final String texto;
  final DateTime fecha;
  final bool esUsuario;
  final bool esError;

  const MensajeChatLocal({
    required this.texto,
    required this.fecha,
    required this.esUsuario,
    this.esError = false,
  });
}
