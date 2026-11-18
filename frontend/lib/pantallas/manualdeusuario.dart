import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PantallaManualUsuario extends StatefulWidget {
  const PantallaManualUsuario({super.key});

  @override
  State<PantallaManualUsuario> createState() => _PantallaManualUsuarioState();
}

class _PantallaManualUsuarioState extends State<PantallaManualUsuario> {
  bool _cargando = false;

  // Paleta de colores Active Sport Gym
  static const Color _fondoNegro = Color(0xFF000000);
  static const Color _tarjetaOscura = Color(0xFF141414);
  static const Color _verdeNeon = Color(0xFFCCFF00);

  Future<void> _abrirManual() async {
    setState(() => _cargando = true);
    try {
      if (kIsWeb) {
        final url = Uri.base.resolve('assets/assets/pdf/Manual_de_usuario.pdf');
        if (!await launchUrl(url)) {
          throw StateError('No se pudo abrir el manual en el navegador.');
        }
        return;
      }

      // Cargar el PDF desde la carpeta assets del proyecto (nombre exacto con minúscula)
      final bytes = await rootBundle.load('assets/pdf/Manual_de_usuario.pdf');

      // Copiarlo a la carpeta temporal del dispositivo para visualizarlo
      final dir = await getTemporaryDirectory();
      final archivo = File('${dir.path}/Manual_de_usuario.pdf');
      await archivo.writeAsBytes(bytes.buffer.asUint8List(), flush: true);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VisorPdf(ruta: archivo.path),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al abrir el manual: $e',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: _tarjetaOscura,
        ),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondoNegro,
      appBar: AppBar(
        title: const Text(
          'MANUAL DE USUARIO',
          style: TextStyle(
            color: _verdeNeon,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        backgroundColor: _fondoNegro,
        elevation: 0,
        iconTheme: const IconThemeData(color: _verdeNeon),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: _tarjetaOscura,
                        shape: BoxShape.circle,
                        border: Border.all(color: _verdeNeon.withOpacity(0.4)),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        size: 64,
                        color: _verdeNeon,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Manual de Usuario',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Consulta aquí la guía paso a paso y toda la documentación de uso de Active Sport Gym.',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: _cargando ? null : _abrirManual,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _verdeNeon,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: _cargando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.black,
                              ),
                            )
                          : const Icon(Icons.picture_as_pdf_rounded),
                      label: const Text(
                        'ABRIR MANUAL EN PDF',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: _tarjetaOscura,
              border: Border(
                top: BorderSide(color: _verdeNeon.withOpacity(0.5), width: 1),
              ),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Desarrollado por:',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Luisa María Carvajal Ospina',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _verdeNeon,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VisorPdf extends StatelessWidget {
  final String ruta;
  const VisorPdf({super.key, required this.ruta});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'MANUAL DE USUARIO',
          style: TextStyle(
            color: Color(0xFFCCFF00),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Color(0xFFCCFF00)),
      ),
      body: PDFView(
        filePath: ruta,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
      ),
    );
  }
}