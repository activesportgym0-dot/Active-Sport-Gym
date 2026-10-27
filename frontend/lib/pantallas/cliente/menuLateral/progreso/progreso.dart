import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/componentes/fondo.dart';
import 'package:frontend/pantallas/cliente/menuLateral/progreso/detalle_medida_screen.dart';
import 'package:frontend/componentes/cliente/asistente/burbuja_mini_chat_modal.dart';

class ProgresoScreen extends StatefulWidget {
  const ProgresoScreen({super.key});

  @override
  State<ProgresoScreen> createState() => _ProgresoScreenState();
}

class _ProgresoScreenState extends State<ProgresoScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _progresoActual;
  List<dynamic> _historialMedidas = [];

  @override
  void initState() {
    super.initState();
    _cargarDatosLocales();
  }

  Future<void> _cargarDatosLocales() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      setState(() {
        _progresoActual = {
          "peso_actual": 75.5,
          "altura": 1.78,
          "brazo_izquierdo": 35.0,
          "brazo_derecho": 35.5,
          "pecho": 102.0,
          "cintura": 80.0,
          "cadera": 95.0,
          "muslo_izquierdo": 58.0,
          "muslo_derecho": 58.5,
          "pantorrilla_izquierda": 38.0,
          "pantorrilla_derecha": 38.2,
          "created_at": "2026-10-20"
        };
        _historialMedidas = [
          {
            "id": 2,
            "peso_actual": 75.5,
            "altura": 1.78,
            "brazo_izquierdo": 35.0,
            "brazo_derecho": 35.5,
            "pecho": 102.0,
            "cintura": 80.0,
            "cadera": 95.0,
            "muslo_izquierdo": 58.0,
            "muslo_derecho": 58.5,
            "pantorrilla_izquierda": 38.0,
            "pantorrilla_derecha": 38.2,
            "created_at": "2026-10-20"
          },
          {
            "id": 1,
            "peso_actual": 77.0,
            "altura": 1.78,
            "brazo_izquierdo": 34.0,
            "brazo_derecho": 34.5,
            "pecho": 100.0,
            "cintura": 82.0,
            "cadera": 96.0,
            "muslo_izquierdo": 59.0,
            "muslo_derecho": 59.5,
            "pantorrilla_izquierda": 38.0,
            "pantorrilla_derecha": 38.0,
            "created_at": "2026-09-15"
          },
        ];
        _isLoading = false;
      });
    }
  }

  // 🗑️ Función para eliminar una medida individual del historial
  void _confirmarBorradoIndividual(int index, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppColors.grisOscuro,
        title: const Text(
          'Eliminar Registro',
          style: TextStyle(color: Colors.white, fontFamily: 'Oswald'),
        ),
        content: Text(
          '¿Deseas eliminar el registro del ${item['created_at']} (${item['peso_actual']} Kg)?',
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(c);
              setState(() {
                _historialMedidas.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Medida eliminada del historial'),
                  backgroundColor: AppColors.verdePrimario,
                ),
              );
            },
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _mostrarModalNuevaMedida() {
    final pesoController = TextEditingController();
    final alturaController = TextEditingController();
    final brazoIzqController = TextEditingController();
    final brazoDerController = TextEditingController();
    final pechoController = TextEditingController();
    final cinturaController = TextEditingController();
    final caderaController = TextEditingController();
    final musloIzqController = TextEditingController();
    final musloDerController = TextEditingController();
    final pantIzqController = TextEditingController();
    final pantDerController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.grisOscuro,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'REGISTRAR NUEVAS MEDIDAS',
                style: TextStyle(
                  fontFamily: 'Oswald',
                  color: AppColors.verdePrimario,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Ingresa los valores corporales (en Kg y cm).',
                style: TextStyle(color: Colors.grey, fontSize: 12, decoration: TextDecoration.none),
              ),
              const SizedBox(height: 16),
              
              _buildTextField('Peso Actual (Kg)', pesoController),
              _buildTextField('Altura (m)', alturaController),
              _buildTextField('Brazo Izquierdo (cm)', brazoIzqController),
              _buildTextField('Brazo Derecho (cm)', brazoDerController),
              _buildTextField('Pecho (cm)', pechoController),
              _buildTextField('Cintura (cm)', cinturaController),
              _buildTextField('Cadera (cm)', caderaController),
              _buildTextField('Muslo Izquierdo (cm)', musloIzqController),
              _buildTextField('Muslo Derecho (cm)', musloDerController),
              _buildTextField('Pantorrilla Izquierda (cm)', pantIzqController),
              _buildTextField('Pantorrilla Derecha (cm)', pantDerController),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.verdePrimario,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Medidas guardadas localmente')),
                    );
                  },
                  child: const Text(
                    'GUARDAR MEDIDAS',
                    style: TextStyle(
                      fontFamily: 'Oswald',
                      color: AppColors.fondoNegro,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 12),
          filled: true,
          fillColor: AppColors.fondoNegro,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.white12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.verdePrimario),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(decoration: TextDecoration.none),
      child: Scaffold(
        backgroundColor: AppColors.fondoNegro,
        body: Stack(
          children: [

            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(Icons.arrow_back_ios_new, color: AppColors.verdePrimario, size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'MI PROGRESO',
                              style: TextStyle(
                                fontFamily: 'Oswald',
                                color: AppColors.verdePrimario,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_chart_rounded, color: AppColors.verdePrimario),
                          onPressed: _mostrarModalNuevaMedida,
                          tooltip: 'Registrar Medida',
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: AppColors.verdePrimario))
                        : RefreshIndicator(
                            color: AppColors.verdePrimario,
                            backgroundColor: AppColors.grisOscuro,
                            onRefresh: _cargarDatosLocales,
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'ESTADÍSTICAS ACTUALES',
                                    style: TextStyle(
                                      fontFamily: 'Oswald',
                                      color: Colors.white70,
                                      fontSize: 16,
                                      letterSpacing: 1,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  _progresoActual == null
                                      ? Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: AppColors.grisOscuro,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'No tienes medidas actuales registradas.',
                                              style: TextStyle(color: Colors.grey, fontSize: 13, decoration: TextDecoration.none),
                                            ),
                                          ),
                                        )
                                      : Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: AppColors.grisOscuro.withOpacity(0.9),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: AppColors.verdePrimario.withOpacity(0.3)),
                                          ),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [
                                                  _buildStatItem('Peso', '${_progresoActual!['peso_actual']} Kg', Icons.fitness_center),
                                                  _buildStatItem('Altura', '${_progresoActual!['altura']} m', Icons.height),
                                                  _buildStatItem('Cintura', '${_progresoActual!['cintura']} cm', Icons.straighten),
                                                ],
                                              ),
                                              const Divider(color: Colors.white12, height: 24),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [
                                                  _buildStatItem('Pecho', '${_progresoActual!['pecho']} cm', Icons.accessibility),
                                                  _buildStatItem('B. Izq', '${_progresoActual!['brazo_izquierdo']} cm', Icons.line_weight),
                                                  _buildStatItem('B. Der', '${_progresoActual!['brazo_derecho']} cm', Icons.line_weight),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                  const SizedBox(height: 24),
                                  
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'HISTORIAL DE REGISTROS',
                                        style: TextStyle(
                                          fontFamily: 'Oswald',
                                          color: Colors.white70,
                                          fontSize: 16,
                                          letterSpacing: 1,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                      if (_historialMedidas.isNotEmpty)
                                        TextButton(
                                          onPressed: () {
                                            setState(() => _historialMedidas.clear());
                                          },
                                          child: const Text(
                                            'Vaciar historial',
                                            style: TextStyle(color: Colors.redAccent, fontSize: 12, decoration: TextDecoration.none),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  _historialMedidas.isEmpty
                                      ? const Text(
                                          'Aún no hay registros en el historial.',
                                          style: TextStyle(color: Colors.grey, fontSize: 12, decoration: TextDecoration.none),
                                        )
                                      : ListView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: _historialMedidas.length,
                                          itemBuilder: (context, index) {
                                            final item = _historialMedidas[index];
                                            return Container(
                                              margin: const EdgeInsets.only(bottom: 8),
                                              decoration: BoxDecoration(
                                                color: AppColors.grisOscuro.withOpacity(0.9),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: Colors.white12),
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: GestureDetector(
                                                      behavior: HitTestBehavior.opaque,
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => DetalleMedidaScreen(medida: item),
                                                          ),
                                                        );
                                                      },
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(12),
                                                        child: Row(
                                                          children: [
                                                            const Icon(Icons.calendar_month, color: AppColors.verdePrimario, size: 20),
                                                            const SizedBox(width: 12),
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  'Peso: ${item['peso_actual']} Kg',
                                                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, decoration: TextDecoration.none),
                                                                ),
                                                                Text(
                                                                  'Fecha: ${item['created_at']}',
                                                                  style: const TextStyle(color: Colors.grey, fontSize: 11, decoration: TextDecoration.none),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  
                                                  IconButton(
                                                    icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                                                    onPressed: () => _confirmarBorradoIndividual(index, item),
                                                    tooltip: 'Eliminar esta medida',
                                                  ),
                                                  const SizedBox(width: 4),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                ],
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: const BurbujaMiniChatModal(),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.verdePrimario, size: 22),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 10, decoration: TextDecoration.none),
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, decoration: TextDecoration.none),
        ),
      ],
    );
  }
}