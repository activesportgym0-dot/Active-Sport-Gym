import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/componentes/fondo.dart';
import 'package:frontend/models/regla_horario_model.dart';
import 'package:frontend/services/regla_horario_service.dart';

class HorariosYReglasClienteScreen extends StatefulWidget {
  const HorariosYReglasClienteScreen({super.key});

  @override
  State<HorariosYReglasClienteScreen> createState() => _HorariosYReglasClienteScreenState();
}

class _HorariosYReglasClienteScreenState extends State<HorariosYReglasClienteScreen> {
  List<ReglaHorarioModel> _horarios = [];
  List<ReglaHorarioModel> _reglas = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarRegistros();
  }

  // Usa las funciones del cliente de ReglaHorarioService (GET /reglas-horarios, solo requiere token)
  Future<void> _cargarRegistros() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    final r = await ReglaHorarioService.obtenerReglasHorariosCliente();
    if (!mounted) return;

    if (r['success'] == true) {
      setState(() {
        _horarios = List<ReglaHorarioModel>.from(r['horarios']);
        _reglas = List<ReglaHorarioModel>.from(r['reglas']);
        _cargando = false;
      });
    } else {
      setState(() {
        _error = r['message']?.toString() ?? 'No se pudieron cargar los horarios y reglas';
        _cargando = false;
      });
    }
  }

  Widget _mensajeCentrado(Widget hijo) {
    // ListView para que el pull-to-refresh también funcione con la lista vacía o en error
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        Center(child: hijo),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final horarios = _horarios;
    final reglas = _reglas;

    return Scaffold(
      backgroundColor: AppColors.fondoNegro,
      appBar: AppBar(
        backgroundColor: AppColors.fondoNegro,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.verdePrimario, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'HORARIOS Y REGLAS',
          style: EstiloTexto.bienvenida.copyWith(
            fontFamily: 'Oswald',
            fontSize: 16,
            color: AppColors.verdePrimario,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: FondoApp(
        child: SafeArea(
          child: _cargando
              ? const Center(child: CircularProgressIndicator(color: AppColors.verdePrimario))
              : RefreshIndicator(
            color: AppColors.verdePrimario,
            onRefresh: _cargarRegistros,
            child: _error != null
                ? _mensajeCentrado(Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.grisClaro, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: _cargarRegistros,
                        icon: const Icon(Icons.refresh, color: AppColors.verdePrimario, size: 18),
                        label: const Text(
                          'REINTENTAR',
                          style: TextStyle(color: AppColors.verdePrimario, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ))
                : (horarios.isEmpty && reglas.isEmpty)
                    ? _mensajeCentrado(const Text(
                        'Aún no hay horarios ni reglas publicados.',
                        style: TextStyle(color: AppColors.grisClaro, fontSize: 13),
                      ))
                    : ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              // SECCIÓN DE HORARIOS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time_outlined, color: AppColors.verdePrimario, size: 20),
                      const SizedBox(width: 8),
                      Text('HORARIOS', style: EstiloTexto.tituloBienvenida.copyWith(color: AppColors.verdePrimario, fontSize: 16)),
                    ],
                  ),
                  Text('${horarios.length} disponibles', style: EstiloTexto.textoNormalRoboto.copyWith(fontSize: 11, color: AppColors.grisClaro)),
                ],
              ),
              const SizedBox(height: 10),
              ...horarios.map((item) => ReglaHorarioClienteCard(item: item)),

              const SizedBox(height: 25),
              const Divider(color: AppColors.grisMedio, thickness: 0.5),
              const SizedBox(height: 15),

              // SECCIÓN DE REGLAS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.rule_folder_outlined, color: AppColors.verdePrimario, size: 20),
                      const SizedBox(width: 8),
                      Text('REGLAS DEL GIMNASIO', style: EstiloTexto.tituloBienvenida.copyWith(color: AppColors.verdePrimario, fontSize: 16)),
                    ],
                  ),
                  Text('${reglas.length} establecidas', style: EstiloTexto.textoNormalRoboto.copyWith(fontSize: 11, color: AppColors.grisClaro)),
                ],
              ),
              const SizedBox(height: 10),
              ...reglas.map((item) => ReglaHorarioClienteCard(item: item)),
            ],
          ),
          ),
        ),
      ),
    );
  }
}

// Tarjeta exclusiva para el cliente (Solo lectura, sin botones de editar/eliminar)
class ReglaHorarioClienteCard extends StatelessWidget {
  final ReglaHorarioModel item;

  const ReglaHorarioClienteCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final bool esHorario = item.esHorario;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.grisOscuro,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.grisMedio.withOpacity(0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              esHorario ? Icons.schedule : Icons.check_circle_outline,
              color: AppColors.verdePrimario,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.titulo,
                    style: EstiloTexto.textoNormalRoboto.copyWith(
                      color: AppColors.blancoPuro,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.contenido,
                    style: EstiloTexto.textoNormalRoboto.copyWith(
                      color: AppColors.grisClaro,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}