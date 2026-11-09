import 'package:flutter/material.dart';
import 'package:frontend/componentes/burbuja_chat_ia.dart';

/// Burbuja flotante del asistente IA.
/// Se usa igual que siempre (const BurbujaMiniChatModal()). El rol (cliente o admin)
/// se detecta solo según la sesión, así nunca habla con el asistente equivocado.
class BurbujaMiniChatModal extends StatelessWidget {
  const BurbujaMiniChatModal({super.key});

  @override
  Widget build(BuildContext context) => const BurbujaChatIA();
}
