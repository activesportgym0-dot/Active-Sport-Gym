import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/pantallas/administrador/historia_gym.dart';
import 'package:frontend/pantallas/cliente/menuLateral/progreso/progreso.dart';
import 'package:frontend/pantallas/cliente/menuLateral/reglas_y_horarios.dart';
import 'package:frontend/pantallas/cliente/mis_membresias.dart';
import 'package:frontend/registro-recuperar/Login.dart';
import '../../../pantallas/cliente/menuLateral/entrenamiento_screen.dart';

class MenuLateral extends StatelessWidget {
  const MenuLateral({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.fondoNegro,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // 1. Logo superior
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.verdePrimario,
                    AppColors.fondoNegro,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.fondoNegro,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.fitness_center,
                          color: Colors.black,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'ACTIVE SPORT GYM',
                    style: TextStyle(
                      color: AppColors.blancoPuro,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // 2. Tarjeta de Bienvenida con borde verde
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.grisOscuro,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.verdePrimario, width: 1),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.grisMedio,
                    child: Icon(Icons.person, color: AppColors.blancoPuro, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '¡Bienvenido!',
                        style: TextStyle(
                          color: AppColors.verdePrimario,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '(NOMBRE)',
                        style: TextStyle(
                          color: AppColors.blancoPuro,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // SECCIÓN: PRINCIPAL
            const Text(
              'PRINCIPAL',
              style: TextStyle(
                color: AppColors.grisMedio,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 5),
            _buildMenuItem(Icons.fitness_center, 'Entrenamiento', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  EntrenamientoScreen()),
              );
            }),
            _buildMenuItem(Icons.trending_up, 'Progreso', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  ProgresoScreen()),
              );
            }),
            const Divider(color: AppColors.grisMedio, height: 25, thickness: 0.5),

            // SECCIÓN: INFORMACIÓN
            const Text(
              'INFORMACIÓN',
              style: TextStyle(
                color: AppColors.grisMedio,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 5),
            _buildMenuItem(Icons.info_outline, 'Historia del Gym', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  HistoriaGymScreen()),
              );
            }),
            _buildMenuItem(Icons.access_time, 'Reglas y horarios', () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  HorariosYReglasClienteScreen()),
              );
            
            }),

            const Divider(color: AppColors.grisMedio, height: 25, thickness: 0.5),

            // SECCIÓN: CONFIGURACIÓN
            const Text(
              'CONFIGURACIÓN',
              style: TextStyle(
                color: AppColors.grisMedio,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 5),
            _buildMenuItem(Icons.logout, 'Cerrar sesión', () {
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context)=> const LoginScreen()));
            }, isRed: true),
            const SizedBox(height: 20),
           // 3. Tarjeta de Membresía Activa (Interactiva)
            InkWell(
              borderRadius: BorderRadius.circular(10), // Para que el efecto de toque respete los bordes redondeados
              onTap: () {
                // Navegación hacia la pantalla de Historial de Membresías
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MisMembresiasScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.grisOscuro,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.verdePrimario, width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.verdePrimario.withOpacity(0.2),
                      ),
                      child: const Icon(Icons.card_membership, color: AppColors.verdePrimario, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TU MEMBRESÍA',
                            style: TextStyle(
                              color: AppColors.verdePrimario,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: const [
                              Text(
                                'Activa',
                                style: TextStyle(
                                  color: AppColors.blancoPuro,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.circle, color: Colors.green, size: 10),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Vence el 31/08/2026',
                            style: TextStyle(
                              color: AppColors.grisClaro,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.verdePrimario, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Pie de página del menú
            Center(
              child: Column(
                children: const [
                  Text(
                    'SUPERA TUS LÍMITES',
                    style: TextStyle(
                      color: AppColors.verdePrimario,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Versión 1.0.0',
                    style: TextStyle(
                      color: AppColors.grisMedio,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {bool isRed = false}) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: isRed ? Colors.redAccent : AppColors.blancoPuro,
        size: 20,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isRed ? Colors.redAccent : AppColors.blancoPuro,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}