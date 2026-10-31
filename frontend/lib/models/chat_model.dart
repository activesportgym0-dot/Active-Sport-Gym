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
