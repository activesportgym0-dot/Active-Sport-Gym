import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/pantallas/administrador/Gestionusuariosadmin.dart';
import 'package:frontend/pantallas/administrador/historia_gym.dart';
import 'package:frontend/pantallas/administrador/horarios_y_reglas.dart';
import 'package:frontend/registro-recuperar/Login.dart';

class MenuLateralAdministrador extends StatelessWidget {
  const MenuLateralAdministrador({super.key});

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
                          Icons.admin_panel_settings,
                          color: Colors.black,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'ACTIVE SPORT - ADMIN',
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

            // 2. Tarjeta de Bienvenida del Administrador
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
                    child: Icon(Icons.admin_panel_settings, color: AppColors.blancoPuro, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Modo Administrador',
                        style: TextStyle(
                          color: AppColors.verdePrimario,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Panel de Control',
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

            // SECCIÓN: CONTROL DE USUARIOS
            const Text(
              'CONTROL DE ACCESOS',
              style: TextStyle(
                color: AppColors.grisMedio,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 5),
            _buildMenuItem(Icons.manage_accounts_outlined, 'Gestión de Usuarios', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GestionUsuariosAdminScreen()),
              );
            }),

            const Divider(color: AppColors.grisMedio, height: 25, thickness: 0.5),

            // SECCIÓN: INFORMACIÓN DEL GYM
            const Text(
              'ACERCA DEL GYM',
              style: TextStyle(
                color: AppColors.grisMedio,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 5),
            _buildMenuItem(Icons.history_edu_outlined, 'Historia del Gimnasio', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoriaGymScreen()),
              );
            }),
            _buildMenuItem(Icons.schedule_outlined, 'Horarios y Reglas', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HorariosYReglasScreen()),
              );
            }),

            const Divider(color: AppColors.grisMedio, height: 25, thickness: 0.5),

            _buildMenuItem(Icons.logout, 'Cerrar sesión', () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
            }, isRed: true),
            const SizedBox(height: 20),

            // 3. Tarjeta de Estado del Sistema
            Container(
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
                    child: const Icon(Icons.security, color: AppColors.verdePrimario, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ESTADO DEL SISTEMA',
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
                              'Servidor Activo',
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
                          'Sincronizado con BD',
                          style: TextStyle(
                            color: AppColors.grisClaro,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Pie de página
            Center(
              child: Column(
                children: const [
                  Text(
                    'CONTROL TOTAL ACTIVE SPORT',
                    style: TextStyle(
                      color: AppColors.verdePrimario,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Versión Admin 1.0.0',
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