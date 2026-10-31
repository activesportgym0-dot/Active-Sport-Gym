import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/models/ejercicio_catalogo_model.dart';
import 'package:frontend/componentes/cliente/rutina/diaria/mini_buscador_ejercicios.dart';

/// Tarjeta "Ejercicio N" de las pantallas de crear rutina (diaria y semanal).
///
/// Tiene dos estados:
///  - ELIGIENDO: no hay ejercicio elegido todavía (id_ejercicio == null) o se pulsó
///    EDITAR (cambiando == true). Muestra el mini buscador dentro de la tarjeta.
///  - NORMAL: muestra el ejercicio elegido, sus series y los descansos.
///
/// Lo que el usuario escribe (repeticiones, peso y descansos) se guarda directamente
/// en el mapa [ejercicioData], que es el que luego se envía al backend.
class TarjetaEjercicioAgregado extends StatelessWidget {
  final int numeroEjercicio;
  final Map<String, dynamic> ejercicioData;

  // Datos del mini buscador
  final List<EjercicioCatalogoModel> catalogo;
  final List<String> categorias;
  final bool cargandoCatalogo;
  final ValueChanged<EjercicioCatalogoModel> onSeleccionarEjercicio;
  final VoidCallback onCancelarSeleccion;

  // Acciones de la tarjeta
  final VoidCallback onEditar;
  final VoidCallback onAgregarSerie;
  final VoidCallback onEliminarEjercicio;
  final Function(int index) onEliminarSerie;

  const TarjetaEjercicioAgregado({
    super.key,
    required this.numeroEjercicio,
    required this.ejercicioData,
    required this.catalogo,
    required this.categorias,
    required this.onSeleccionarEjercicio,
    required this.onCancelarSeleccion,
    required this.onEditar,
    required this.onAgregarSerie,
    required this.onEliminarEjercicio,
    required this.onEliminarSerie,
    this.cargandoCatalogo = false,
  });

  bool get _eligiendo => ejercicioData['id_ejercicio'] == null || ejercicioData['cambiando'] == true;

  // La imagen es una URL de Cloudinary (o un asset local, si algún ejercicio lo trae)
  Widget _construirImagen(String ruta) {
    const double ancho = 90;
    const double alto = 60;
    final placeholder = Container(
      width: ancho,
      height: alto,
      color: Colors.black26,
      child: const Icon(Icons.fitness_center, color: Colors.white38, size: 24),
    );

    if (ruta.isEmpty) return placeholder;
    if (ruta.startsWith('assets/')) {
      return Image.asset(ruta, width: ancho, height: alto, fit: BoxFit.cover);
    }
    return Image.network(
      ruta,
      width: ancho,
      height: alto,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => placeholder,
    );
  }

  // Campo numérico pequeño que escribe su valor en el mapa mediante onChanged
  Widget _campoNumero({
    required String inicial,
    required ValueChanged<String> onChanged,
    double ancho = 35,
    double alto = 25,
    double fontSize = 11,
    bool decimal = false,
  }) {
    return SizedBox(
      width: ancho,
      height: alto,
      child: TextFormField(
        initialValue: inicial,
        style: TextStyle(color: Colors.white, fontSize: fontSize),
        textAlign: TextAlign.center,
        keyboardType: decimal ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.number,
        inputFormatters: [
          decimal
              ? FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))
              : FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: onChanged,
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.fondoNegro,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  String _texto(dynamic valor) => (valor == null) ? '' : valor.toString();

  @override
  Widget build(BuildContext context) {
    final List series = ejercicioData['series'] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grisOscuro,
        borderRadius: BorderRadius.circular(12),
      ),
      child: _eligiendo ? _construirModoEleccion() : _construirModoNormal(series),
    );
  }

  // ESTADO 1: el usuario está eligiendo el ejercicio (mini buscador dentro de la tarjeta)
  Widget _construirModoEleccion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ejercicio $numeroEjercicio',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 10),
        MiniBuscadorEjercicios(
          catalogo: catalogo,
          categorias: categorias,
          cargando: cargandoCatalogo,
          onSeleccionar: onSeleccionarEjercicio,
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: onCancelarSeleccion,
            child: const Text('CANCELAR', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  // ESTADO 2: ejercicio elegido, con sus series y descansos
  Widget _construirModoNormal(List series) {
    final String etiqueta = _texto(ejercicioData['etiqueta']).isNotEmpty
        ? _texto(ejercicioData['etiqueta'])
        : _texto(ejercicioData['category']).toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ejercicio $numeroEjercicio',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 8),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    etiqueta,
                    style: const TextStyle(color: AppColors.verdePrimario, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ejercicioData['title'] ?? 'Sin nombre',
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _construirImagen(_texto(ejercicioData['imagePath'])),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Listado dinámico interno de series
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: series.length,
          itemBuilder: (context, index) {
            final serie = series[index] as Map;
            return Padding(
              key: ObjectKey(serie), // cada fila conserva su texto aunque se borre otra serie
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Text(
                    'Serie ${index + 1}',
                    style: const TextStyle(color: AppColors.verdePrimario, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  const Text('repeticion:', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  const SizedBox(width: 4),
                  _campoNumero(
                    inicial: _texto(serie['repeticiones']),
                    onChanged: (v) => serie['repeticiones'] = int.tryParse(v),
                  ),
                  const SizedBox(width: 10),
                  const Text('Peso:', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  const SizedBox(width: 4),
                  _campoNumero(
                    inicial: _texto(serie['peso']),
                    ancho: 45,
                    decimal: true,
                    onChanged: (v) => serie['peso'] = double.tryParse(v.replaceAll(',', '.')),
                  ),
                  const Spacer(),
                  if (series.length > 1)
                    GestureDetector(
                      onTap: () => onEliminarSerie(index),
                      child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 10),

        // Tiempos de descanso
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  const Text('DESCANSO ENTRE SERIES:', style: TextStyle(color: Colors.grey, fontSize: 8)),
                  const SizedBox(width: 2),
                  _campoNumero(
                    inicial: series.isNotEmpty ? _texto((series.first as Map)['descanso_entre_series']) : '',
                    alto: 22,
                    fontSize: 10,
                    // El mismo descanso se aplica a todas las series del ejercicio
                    onChanged: (v) {
                      final segundos = int.tryParse(v);
                      for (final s in series) {
                        (s as Map)['descanso_entre_series'] = segundos;
                      }
                    },
                  ),
                  const Text(' Seg', style: TextStyle(color: Colors.grey, fontSize: 8)),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  const Text('DESCANSO FINAL:', style: TextStyle(color: Colors.grey, fontSize: 8)),
                  const SizedBox(width: 2),
                  _campoNumero(
                    inicial: _texto(ejercicioData['descanso_final']),
                    alto: 22,
                    fontSize: 10,
                    onChanged: (v) => ejercicioData['descanso_final'] = int.tryParse(v),
                  ),
                  const Text(' Seg', style: TextStyle(color: Colors.grey, fontSize: 8)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Botones de acción de la tarjeta
        Row(
          children: [
            Expanded(child: _botonAccion('AGREGAR SERIE', onAgregarSerie)),
            const SizedBox(width: 6),
            // EDITAR vuelve a abrir el mini buscador para cambiar el ejercicio
            Expanded(child: _botonAccion('EDITAR', onEditar)),
            const SizedBox(width: 6),
            Expanded(child: _botonAccion('ELIMINAR', onEliminarEjercicio)),
          ],
        ),
      ],
    );
  }

  Widget _botonAccion(String texto, VoidCallback onPressed) {
    return SizedBox(
      height: 30,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.verdePrimario,
          foregroundColor: Colors.black,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Text(texto, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
