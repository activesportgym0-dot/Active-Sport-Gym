import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

class TarjetaUsuarioAdmin extends StatelessWidget {
  final Map<String, dynamic> usuario;
  final VoidCallback onTap;
  final ValueChanged<bool> onSwitchChanged;

  const TarjetaUsuarioAdmin({
    super.key,
    required this.usuario,
    required this.onTap,
    required this.onSwitchChanged,
  });

  // "Garzón · Barrio Centro" (vacío si el usuario no tiene residencia registrada)
  String get _residencia {
    final partes = [usuario['municipio'], usuario['direccion']]
        .map((p) => (p ?? '').toString().trim())
        .where((p) => p.isNotEmpty)
        .toList();
    return partes.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    bool activo = usuario['activo'];
    bool verificado = usuario['verificado'] != false;
    bool esAdmin = usuario['rol'] == 'admin';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.grisOscuro,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: activo ? AppColors.grisMedio.withOpacity(0.3) : Colors.redAccent.withOpacity(0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.fondoNegro,
                  radius: 22,
                  child: Icon(
                    esAdmin ? Icons.admin_panel_settings : Icons.person,
                    color: activo ? AppColors.verdePrimario : Colors.redAccent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${usuario['nombre']} ${usuario['apellido']}',
                        style: const TextStyle(
                          color: AppColors.blancoPuro,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Cédula: ${usuario['cedula']}',
                        style: const TextStyle(color: AppColors.grisClaro, fontSize: 11),
                      ),
                      if (_residencia.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          _residencia,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.grisClaro, fontSize: 11),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: activo ? AppColors.verdePrimario.withOpacity(0.15) : Colors.redAccent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              activo ? 'ACTIVO' : 'INACTIVO',
                              style: TextStyle(
                                color: activo ? AppColors.verdePrimario : Colors.redAccent,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.grisMedio.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              usuario['rol'].toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.grisClaro,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!verificado) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orangeAccent.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'SIN VERIFICAR',
                                style: TextStyle(
                                  color: Colors.orangeAccent,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: activo,
                  activeColor: AppColors.verdePrimario,
                  inactiveThumbColor: Colors.redAccent,
                  onChanged: onSwitchChanged,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}