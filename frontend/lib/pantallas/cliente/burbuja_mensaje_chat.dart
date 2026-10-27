import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

class BurbujaMensajeChat extends StatelessWidget {
  final String texto;
  final String hora;
  final bool esUsuario; // true si es el usuario, false si es el bot IA

  const BurbujaMensajeChat({
    super.key,
    required this.texto,
    required this.hora,
    required this.esUsuario,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: esUsuario ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar de la IA (ia.png) a la izquierda (si no es usuario)
          if (!esUsuario) ...[
            Container(
              margin: const EdgeInsets.only(right: 8, bottom: 4),
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.verdePrimario, width: 1.5),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/ia.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],

          // Burbuja de mensaje
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: esUsuario ? const Color(0xFF2C3B1E) : AppColors.grisOscuro,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: Radius.circular(esUsuario ? 12 : 2),
                  bottomRight: Radius.circular(esUsuario ? 2 : 12),
                ),
                border: Border.all(
                  color: esUsuario ? AppColors.verdePrimario.withOpacity(0.4) : Colors.transparent,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Etiqueta y Hora del mensaje
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        esUsuario ? 'User' : 'Bot',
                        style: TextStyle(
                          fontFamily: 'RobotoCondensed',
                          color: esUsuario ? AppColors.verdePrimario : Colors.grey.withOpacity(0.9),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        hora,
                        style: TextStyle(
                          fontFamily: 'RobotoCondensed',
                          color: Colors.grey.withOpacity(0.7),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Texto del mensaje
                  Text(
                    texto,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Avatar del Usuario a la derecha (si es usuario)
          if (esUsuario) ...[
            Container(
              margin: const EdgeInsets.only(left: 8, bottom: 4),
              child: const CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.verdePrimario,
                child: Icon(Icons.person, color: Colors.black, size: 16),
              ),
            ),
          ],
        ],
      ),
    );
  }
}