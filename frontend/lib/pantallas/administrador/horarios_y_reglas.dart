import 'package:flutter/material.dart';
import 'package:frontend/componentes/administrador/reglasyhorarios/modal_regla_horario.dart';
import 'package:frontend/componentes/administrador/reglasyhorarios/regla_horario_card.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/componentes/fondo.dart';
import 'package:frontend/componentes/cliente/asistente/burbuja_mini_chat_modal.dart'; // 👈 Importación de la burbuja de la IA
import 'package:frontend/models/regla_horario_model.dart'; 
import 'package:frontend/services/regla_horario_service.dart'; 

class HorariosYReglasScreen extends StatefulWidget {
  const HorariosYReglasScreen({super.key});

  @override
  State<HorariosYReglasScreen> createState() => _HorariosYReglasScreenState();
}

class _HorariosYReglasScreenState extends State<HorariosYReglasScreen> {
  // Ya no hay lista simulada: se llena desde el backend
  List<ReglaHorarioModel> _registros = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final lista = await ReglaHorarioService.obtenerReglasHorarios();
      if (!mounted) return;
      setState(() {
        _registros = lista;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _cargando = false;
      });
    }
  }

  void _abrirModal({ReglaHorarioModel? registro}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ModalReglaHorario(
        // El modal sigue recibiendo el mismo mapa de siempre (id, tipo, titulo, contenido)
        registroExistente: registro?.toMapaTarjeta(),
        // Devuelve null si todo salió bien, o el mensaje de error para mostrarlo en el modal
        onSave: (tipo, titulo, contenido) async {
          final r = registro == null
              ? await ReglaHorarioService.crearReglaHorario(
                  tipo: tipo,
                  titulo: titulo,
                  contenido: contenido,
                )
              : await ReglaHorarioService.actualizarReglaHorario(
                  idReglaHorario: registro.idReglaHorario,
                  tipo: tipo,
                  titulo: titulo,
                  contenido: contenido,
                );

          if (r['success'] != true) {
            return (r['message'] as String?) ?? 'No se pudo guardar el registro';
          }

          if (!mounted) return null;
          final guardado = r['regla'] as ReglaHorarioModel?;

          if (guardado == null) {
            // El backend no devolvió el registro: recargamos la lista completa
            _cargar();
          } else {
            setState(() {
              if (registro == null) {
                _registros.add(guardado);
              } else {
                final i = _registros.indexWhere((x) => x.idReglaHorario == registro.idReglaHorario);
                if (i != -1) _registros[i] = guardado;
              }
            });
          }
          return null;
        },
      ),
    );
  }

  Future<void> _eliminarRegistro(int id) async {
    final r = await ReglaHorarioService.eliminarReglaHorario(id);
    if (!mounted) return;

    if (r['success'] == true) {
      setState(() => _registros.removeWhere((x) => x.idReglaHorario == id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro eliminado correctamente'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text((r['message'] as String?) ?? 'No se pudo eliminar el registro'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final horarios = _registros.where((r) => r.esHorario).toList();
    final reglas = _registros.where((r) => r.esRegla).toList();

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
          'ADMINISTRAR HORARIOS Y REGLAS',
          style: EstiloTexto.bienvenida.copyWith(
            fontFamily: 'Oswald',
            fontSize: 16,
            color: AppColors.verdePrimario,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      // 🌟 Usamos un Stack dentro de FondoApp para alojar la lista y la burbuja de la IA flotando libremente
      body: FondoApp(
        child: SafeArea(
          child: Stack(
            children: [
              _construirContenido(horarios, reglas),
              // 🌟 Burbuja de la IA interactiva y arrastrable por toda la pantalla
              const Positioned.fill(
                child: BurbujaMiniChatModal(),
              ),
            ],
          ),
        ),
      ),

      // Botón principal flotante extendido en su sitio habitual
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirModal(),
        backgroundColor: AppColors.verdePrimario,
        icon: const Icon(Icons.add, color: AppColors.fondoNegro),
        label: Text('NUEVO REGISTRO', style: EstiloTexto.botonPrincipal.copyWith(color: AppColors.fondoNegro, fontSize: 15)),
      ),
    );
  }

  Widget _construirContenido(List<ReglaHorarioModel> horarios, List<ReglaHorarioModel> reglas) {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.verdePrimario),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, style: EstiloTexto.hintTexto, textAlign: TextAlign.center),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _cargar,
                child: Text('REINTENTAR', style: EstiloTexto.enlaceNegritaRoboto),
              ),
            ],
          ),
        ),
      );
    }

    // Lista con padding inferior de 100 para que la burbuja y el botón no tapen el contenido al deslizar
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
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
            Text('${horarios.length} activos', style: EstiloTexto.textoNormalRoboto.copyWith(fontSize: 11, color: AppColors.grisClaro)),
          ],
        ),
        const SizedBox(height: 10),
        ...horarios.map((item) => ReglaHorarioCard(
              item: item.toMapaTarjeta(),
              onEdit: () => _abrirModal(registro: item),
              onDelete: () => _eliminarRegistro(item.idReglaHorario),
            )),

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
                Text('REGLAS', style: EstiloTexto.tituloBienvenida.copyWith(color: AppColors.verdePrimario, fontSize: 16)),
              ],
            ),
            Text('${reglas.length} activas', style: EstiloTexto.textoNormalRoboto.copyWith(fontSize: 11, color: AppColors.grisClaro)),
          ],
        ),
        const SizedBox(height: 10),
        ...reglas.map((item) => ReglaHorarioCard(
              item: item.toMapaTarjeta(),
              onEdit: () => _abrirModal(registro: item),
              onDelete: () => _eliminarRegistro(item.idReglaHorario),
            )),
      ],
    );
  }
}