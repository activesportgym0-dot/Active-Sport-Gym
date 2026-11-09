import "package:flutter/material.dart";
import "package:frontend/componentes/pantalla_chat_ia.dart";

/// Pantalla del asistente IA gerencial del ADMINISTRADOR.
/// Se abre igual que siempre (AsistenteIAAdminScreen()); el diseño y la conexión con
/// el backend están en PantallaChatIA, que comparten cliente y administrador.
class AsistenteIAAdminScreen extends StatelessWidget {
  const AsistenteIAAdminScreen({super.key});

  @override
  Widget build(BuildContext context) => const PantallaChatIA(esAdmin: true);
}
