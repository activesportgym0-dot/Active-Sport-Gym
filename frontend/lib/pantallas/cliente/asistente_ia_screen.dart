import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/componentes/fondo.dart';
import 'package:frontend/pantallas/cliente/burbuja_mensaje_chat.dart';

class AsistenteIAScreen extends StatefulWidget {
  const AsistenteIAScreen({super.key});

  @override
  State<AsistenteIAScreen> createState() => _AsistenteIAScreenState();
}

class _AsistenteIAScreenState extends State<AsistenteIAScreen> {
  final TextEditingController _mensajeController = TextEditingController();

  // Lista de temas rápidos con sus respectivos iconos personalizados
  final List<Map<String, dynamic>> _temasSugeridos = [
    {'titulo': 'Rutinas de entrenamiento', 'icono': Icons.fitness_center},
    {'titulo': 'Nutrición y dietas', 'icono': Icons.restaurant_menu},
    {'titulo': 'Suplementos', 'icono': Icons.bolt},
    {'titulo': 'Pérdida de grasa', 'icono': Icons.local_fire_department},
    {'titulo': 'Ganancia muscular', 'icono': Icons.security},
    {'titulo': 'Consejos generales', 'icono': Icons.lightbulb},
    {'titulo': '¿Cuánta agua debo de tomar?', 'icono': Icons.water_drop},
  ];

  // Historial de mensajes de ejemplo
  final List<Map<String, dynamic>> _mensajes = [
    {
      'texto': '¿Cuál es la mejor rutina para principiantes en el gimnasio?',
      'hora': '10:30 AM',
      'esUsuario': true,
    },
    {
      'texto': '¡Hola! Para principiantes recomiendo una rutina full body 3 veces por semana. Enfócate en ejercicios compuestos como sentadillas y press de banca. ¡Tú puedes con todo!',
      'hora': '10:30 AM',
      'esUsuario': false,
    },
  ];

  @override
  void dispose() {
    _mensajeController.dispose();
    super.dispose();
  }

  void _enviarMensaje(String texto) {
    if (texto.trim().isEmpty) return;
    setState(() {
      _mensajes.add({
        'texto': texto.trim(),
        'hora': '10:35 AM',
        'esUsuario': true,
      });
      _mensajeController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoNegro,
      appBar: AppBar(
        backgroundColor: AppColors.fondoNegro,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.verdePrimario, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('ASISTENTE IA VIRTUAL', style: EstiloTexto.tekoTituloSeccion),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.verdePrimario, width: 1.5),
              ),
              child: ClipOval(
                child: Image.asset('assets/images/ia.png', width: 34, height: 34, fit: BoxFit.cover),
              ),
            ),
          ),
        ],
      ),
      body: FondoApp(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tarjeta de Bienvenida Principal Estilizada con la mascota
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.grisOscuro, const Color(0xFF141F0C)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.verdePrimario.withOpacity(0.5), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.verdePrimario.withOpacity(0.15),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 65,
                            height: 65,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.verdePrimario, width: 2),
                            ),
                            child: ClipOval(
                              child: Image.asset('assets/images/ia.png', fit: BoxFit.cover),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '¡Hola, atleta!',
                                  style: TextStyle(
                                    fontFamily: 'Teko',
                                    fontSize: 24,
                                    color: AppColors.verdePrimario,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const Text(
                                  'Estoy listo para llevar tu entrenamiento y nutrición al siguiente nivel. ¿Qué entrenamos hoy?',
                                  style: TextStyle(fontFamily: 'Roboto', color: Colors.white70, fontSize: 12, height: 1.3),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Título de Categorías Rápidas
                    Row(
                      children: [
                        const Icon(Icons.bolt, color: AppColors.verdePrimario, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'ACCESOS DIRECTOS',
                          style: TextStyle(
                            fontFamily: 'Teko',
                            color: Colors.white,
                            fontSize: 18,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Lista de Categorías con Iconos
                    ..._temasSugeridos.map((tema) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: () => _enviarMensaje('Quiero información sobre: ${tema['titulo']}'),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                              decoration: BoxDecoration(
                                color: AppColors.grisOscuro.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.verdePrimario.withOpacity(0.25)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(tema['icono'], color: AppColors.verdePrimario, size: 20),
                                      const SizedBox(width: 12),
                                      Text(
                                        tema['titulo'],
                                        style: const TextStyle(
                                          fontFamily: 'RobotoCondensed',
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Icon(Icons.arrow_forward_ios, color: AppColors.verdePrimario, size: 14),
                                ],
                              ),
                            ),
                          ),
                        )),
                    const SizedBox(height: 20),

                    // Historial del chat dentro de la pantalla
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _mensajes.length,
                      itemBuilder: (context, index) {
                        final msg = _mensajes[index];
                        return BurbujaMensajeChat(
                          texto: msg['texto'],
                          hora: msg['hora'],
                          esUsuario: msg['esUsuario'],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Barra inferior para escribir mensaje mejorada
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border(top: BorderSide(color: AppColors.verdePrimario.withOpacity(0.3))),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _mensajeController,
                        style: const TextStyle(fontFamily: 'RobotoCondensed', color: Colors.white, fontSize: 14),
                        onSubmitted: _enviarMensaje,
                        decoration: InputDecoration(
                          hintText: 'Pregúntale algo a tu IA...',
                          hintStyle: TextStyle(fontFamily: 'RobotoCondensed', color: Colors.grey.withOpacity(0.6)),
                          filled: true,
                          fillColor: AppColors.grisOscuro,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.verdePrimario.withOpacity(0.4)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.verdePrimario, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.verdePrimario,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.verdePrimario.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.black, size: 20),
                        onPressed: () => _enviarMensaje(_mensajeController.text),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}