import 'package:flutter/material.dart';
import 'package:frontend/componentes/burbuja_chat_ia.dart';

/// Burbuja flotante del asistente IA para el ADMINISTRADOR.
/// Se usa igual que siempre (const BurbujaMiniChatAdminModal()).
class BurbujaMiniChatAdminModal extends StatelessWidget {
  const BurbujaMiniChatAdminModal({super.key});

  @override
  Widget build(BuildContext context) => const BurbujaChatIA(esAdmin: true);
}
