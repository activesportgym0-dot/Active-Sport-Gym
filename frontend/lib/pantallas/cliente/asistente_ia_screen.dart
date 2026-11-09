import "package:flutter/material.dart";
import "package:frontend/componentes/pantalla_chat_ia.dart";

/// Pantalla del asistente IA del CLIENTE.
/// Se abre igual que siempre (AsistenteIAScreen()); el diseño y la conexión con
/// el backend están en PantallaChatIA, que comparten cliente y administrador.
class AsistenteIAScreen extends StatelessWidget {
  const AsistenteIAScreen({super.key});

  @override
  Widget build(BuildContext context) => const PantallaChatIA(esAdmin: false);
}
