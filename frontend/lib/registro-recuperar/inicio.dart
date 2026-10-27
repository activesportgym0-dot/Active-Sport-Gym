import 'package:flutter/material.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/registro-recuperar/Login.dart';

class PrimerPantalla extends StatelessWidget {
  const PrimerPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // IMAGEN DE FONDO OCUPANDO TODO EL STACK
          SizedBox.expand(
            child: Image.asset(
              'assets/images/f.jpg',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.45),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          // FILTRO OSCURO
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.7),
              ),
            ),
          // CONTENIDO PRINCIPAL
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              key: const Key('content_padding'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(flex: 10),
                  
                  // LOGO DE ACTIVE SPORT GYM
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.6),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // TEXTO PRINCIPAL LLAMADO DIRECTAMENTE DESDE EL CORE
                  Text(
                    'ENTRENA TU MENTE,\nTRANSFORMA TU\nCUERPO.',
                    textAlign: TextAlign.center,
                    style: EstiloTexto.tituloPrincipalPrimerPantalla,
                  ),
                  
                  const Spacer(flex: 3),

                  // BOTÓN RECTANGULAR "EMPEZAR"
                  SizedBox(
                    width: double.infinity, 
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black, 
                        foregroundColor: Colors.white, 
                        elevation: 0, 
                        shape: const LinearBorder(),
                      ),
                      child: Text(
                        'Empezar',
                        style: EstiloTexto.botonPrincipal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}