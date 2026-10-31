import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/componentes/fondo.dart';
import 'package:frontend/pantallas/burbuja_mensaje_chat.dart';
import 'package:frontend/services/chat_service.dart';

class AsistenteIAAdminScreen extends StatefulWidget {
  const AsistenteIAAdminScreen({super.key});

  @override
  State<AsistenteIAAdminScreen> createState() => _AsistenteIAAdminScreenState();
}

class _AsistenteIAAdminScreenState extends State<AsistenteIAAdminScreen> {
  final TextEditingController _mensajeController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  String? _sesionId;
  bool _cargando = false;

  final List<Map<String, dynamic>> _temasAdminSugeridos = [
    {'titulo': 'Ver métricas y totales del sistema', 'icono': Icons.analytics},
    {'titulo': 'Revisar alertas de stock crítico', 'icono': Icons.warning_amber},
    {'titulo': 'Consultar inventario completo', 'icono': Icons.inventory_2},
    {'titulo': 'Estadísticas de membresías', 'icono': Icons.card_membership},
    {'titulo': 'Control de rutinas y usuarios', 'icono': Icons.group},
    {'titulo': 'Reglas y horarios activos', 'icono': Icons.access_time},
  ];

  final List<Map<String, dynamic>> _mensajes = [];

  @override
  void dispose() {
    _mensajeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _hacerScrollAbajo() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _enviarMensajeAdminAPI(String texto) async {
    final textoLimpio = texto.trim();
    if (textoLimpio.isEmpty || _cargando) return;

    final horaActual = TimeOfDay.now().format(context);

    setState(() {
      _mensajes.add({
        'texto': textoLimpio,
        'hora': horaActual,
        'esUsuario': true,
      });
      _cargando = true;
      _mensajeController.clear();
    });

    _hacerScrollAbajo();

    try {
      final resultado = await ChatService.enviarMensajeAdmin(
        mensaje: textoLimpio,
        sesionId: _sesionId,
      );

      setState(() {
        _sesionId = resultado.sesionId;
        _mensajes.add({
          'texto': resultado.respuesta,
          'hora': TimeOfDay.now().format(context),
          'esUsuario': false,
        });
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _mensajes.add({
          'texto': '⚠️ Error en asistente gerencial: $e',
          'hora': TimeOfDay.now().format(context),
          'esUsuario': false,
        });
        _cargando = false;
      });
    }

    _hacerScrollAbajo();
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
        title: Text('ASISTENTE GERENCIAL IA', style: EstiloTexto.tekoTituloSeccion),
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
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                              children: const [
                                Text(
                                  '¡Panel de Administración!',
                                  style: TextStyle(
                                    fontFamily: 'Teko',
                                    fontSize: 24,
                                    color: AppColors.verdePrimario,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  'Auditoría y control gerencial en tiempo real conectado con Supabase. ¿Qué deseas consultar?',
                                  style: TextStyle(fontFamily: 'Roboto', color: Colors.white70, fontSize: 12, height: 1.3),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: const [
                        Icon(Icons.admin_panel_settings, color: AppColors.verdePrimario, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'ACCESOS DIRECTOS GERENCIALES',
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
                    ..._temasAdminSugeridos.map((tema) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: () => _enviarMensajeAdminAPI('Necesito información sobre: ${tema['titulo']}'),
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
                          esAdmin: true,
                        );
                      },
                    ),
                    if (_cargando)
                      const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Center(
                          child: CircularProgressIndicator(color: AppColors.verdePrimario),
                        ),
                      ),
                  ],
                ),
              ),
            ),
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
                        onSubmitted: _enviarMensajeAdminAPI,
                        decoration: InputDecoration(
                          hintText: 'Consulta gerencial para la IA...',
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
                        onPressed: () => _enviarMensajeAdminAPI(_mensajeController.text),
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
