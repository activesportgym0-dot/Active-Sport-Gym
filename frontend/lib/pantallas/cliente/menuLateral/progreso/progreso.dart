import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/pantallas/cliente/menuLateral/progreso/detalle_medida_screen.dart';
import 'package:frontend/models/progreso_model.dart';
import 'package:frontend/services/progreso_service.dart';
import 'package:frontend/componentes/cliente/burbuja_mini_chat_modal.dart';

class ProgresoScreen extends StatefulWidget {
  const ProgresoScreen({super.key});

  @override
  State<ProgresoScreen> createState() => _ProgresoScreenState();
}

class _ProgresoScreenState extends State<ProgresoScreen> {
  bool _isLoading = false;
  ProgresoModel? _progresoActual;
  List<ProgresoModel> _historialMedidas = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _mostrarMensaje(String mensaje, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: error ? Colors.redAccent : AppColors.verdePrimario,
      ),
    );
  }

  // Carga la medida actual y el historial desde el backend
  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);

    try {
      final resultados = await Future.wait([
        ProgresoService.obtenerProgresoActual(),
        ProgresoService.obtenerHistorial(),
      ]);

      if (!mounted) return;
      setState(() {
        _progresoActual = resultados[0] as ProgresoModel?;
        _historialMedidas = resultados[1] as List<ProgresoModel>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _mostrarMensaje(e.toString().replaceFirst('Exception: ', ''), error: true);
    }
  }

  // 🗑️ Función para eliminar una medida individual del historial
  void _confirmarBorradoIndividual(ProgresoModel item) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppColors.grisOscuro,
        title: const Text(
          'Eliminar Registro',
          style: TextStyle(color: Colors.white, fontFamily: 'Oswald'),
        ),
        content: Text(
          '¿Deseas eliminar el registro del ${item.fechaRegistro} (${item.pesoActual} Kg)?',
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(c);
              final r = await ProgresoService.eliminarMedida(item.idProgreso);
              if (r['success'] == true) {
                await _cargarDatos();
                _mostrarMensaje('Medida eliminada del historial');
              } else {
                _mostrarMensaje(r['message'], error: true);
              }
            },
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 🗑️ Vaciar todo el historial (se borra en el servidor, por eso pide confirmación)
  void _confirmarVaciarHistorial() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppColors.grisOscuro,
        title: const Text(
          'Vaciar historial',
          style: TextStyle(color: Colors.white, fontFamily: 'Oswald'),
        ),
        content: const Text(
          '¿Deseas eliminar todos tus registros de medidas? Esta acción no se puede deshacer.',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(c);
              final r = await ProgresoService.vaciarHistorial();
              if (r['success'] == true) {
                await _cargarDatos();
                _mostrarMensaje('Historial vaciado');
              } else {
                _mostrarMensaje(r['message'], error: true);
              }
            },
            child: const Text('VACIAR', style: TextStyle(color: Colors.white)),
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

    bool guardando = false;
    String? errorModal; // el SnackBar queda tapado por el modal, por eso el error se muestra dentro

    // Acepta coma o punto como separador decimal
    double? aNumero(TextEditingController c) =>
        double.tryParse(c.text.trim().replaceAll(',', '.'));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.grisOscuro,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModal) => Padding(
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

              if (errorModal != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    errorModal!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 12, decoration: TextDecoration.none),
                  ),
                ),
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
                  onPressed: () async {
                    if (guardando) return;

                    final valores = [
                      aNumero(pesoController),
                      aNumero(alturaController),
                      aNumero(brazoIzqController),
                      aNumero(brazoDerController),
                      aNumero(pechoController),
                      aNumero(cinturaController),
                      aNumero(caderaController),
                      aNumero(musloIzqController),
                      aNumero(musloDerController),
                      aNumero(pantIzqController),
                      aNumero(pantDerController),
                    ];

                    // El backend exige los 11 campos y que sean mayores a cero
                    if (valores.any((v) => v == null || v <= 0)) {
                      setModal(() => errorModal = 'Completa todos los campos con números mayores a cero.');
                      return;
                    }

                    // La altura va en metros (el IMC se calcula con ese valor)
                    if (valores[1]! > 3) {
                      setModal(() => errorModal = 'La altura debe estar en metros (ejemplo: 1.78).');
                      return;
                    }

                    guardando = true;
                    setModal(() => errorModal = null);
                    final r = await ProgresoService.registrarMedida(
                      pesoActual: valores[0]!,
                      altura: valores[1]!,
                      brazoIzquierdo: valores[2]!,
                      brazoDerecho: valores[3]!,
                      pecho: valores[4]!,
                      cintura: valores[5]!,
                      cadera: valores[6]!,
                      musloIzquierdo: valores[7]!,
                      musloDerecho: valores[8]!,
                      pantorrillaIzquierda: valores[9]!,
                      pantorrillaDerecha: valores[10]!,
                    );
                    guardando = false;

                    if (r['success'] == true) {
                      if (context.mounted) Navigator.pop(context);
                      await _cargarDatos();
                      _mostrarMensaje(r['message']);
                    } else {
                      setModal(() => errorModal = r['message'].toString());
                    }
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
                            onRefresh: _cargarDatos,
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
                                                  _buildStatItem('Peso', '${_progresoActual!.pesoActual} Kg', Icons.fitness_center),
                                                  _buildStatItem('Altura', '${_progresoActual!.altura} m', Icons.height),
                                                  _buildStatItem('Cintura', '${_progresoActual!.cintura} cm', Icons.straighten),
                                                ],
                                              ),
                                              const Divider(color: Colors.white12, height: 24),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [
                                                  _buildStatItem('Pecho', '${_progresoActual!.pecho} cm', Icons.accessibility),
                                                  _buildStatItem('B. Izq', '${_progresoActual!.brazoIzquierdo} cm', Icons.line_weight),
                                                  _buildStatItem('B. Der', '${_progresoActual!.brazoDerecho} cm', Icons.line_weight),
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
                                          onPressed: _confirmarVaciarHistorial,
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
                                                                  'Peso: ${item.pesoActual} Kg',
                                                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, decoration: TextDecoration.none),
                                                                ),
                                                                Text(
                                                                  'Fecha: ${item.fechaRegistro}',
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
                                                    onPressed: () => _confirmarBorradoIndividual(item),
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