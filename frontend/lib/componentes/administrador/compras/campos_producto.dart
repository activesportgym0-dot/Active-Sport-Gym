import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';

/// Devuelve el id numérico de una categoría que llega del backend
/// ({'id_categoria': 3, 'nombre': 'Proteínas'}).
int? idDeCategoria(dynamic categoria) {
  if (categoria is! Map) return null;
  return int.tryParse(categoria['id_categoria'].toString());
}

/// Campo de texto con el mismo diseño que tenía el formulario original.
class CampoProducto extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icono;
  final bool esNumero;
  final int maxLines;

  const CampoProducto({
    super.key,
    required this.controller,
    required this.label,
    required this.icono,
    this.esNumero = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: esNumero ? TextInputType.number : TextInputType.text,
      // Precio y stock solo aceptan dígitos (evita "120.000" o letras).
      inputFormatters:
          esNumero ? [FilteringTextInputFormatter.digitsOnly] : null,
      maxLines: maxLines,
      style: EstiloTexto.campoTexto,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: EstiloTexto.hintTexto,
        filled: true,
        fillColor: AppColors.grisOscuro,
        prefixIcon: Icon(icono, color: AppColors.verdePrimario, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

/// Selector Consumible / Material (igual al del formulario original).
class SelectorTipoProducto extends StatelessWidget {
  final String tipo;
  final ValueChanged<String> onChanged;

  const SelectorTipoProducto({
    super.key,
    required this.tipo,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TIPO DE PRODUCTO',
          style: TextStyle(
            color: AppColors.blancoPuro,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: 'consumible',
              label: Text('Consumible'),
              icon: Icon(Icons.fitness_center, size: 16),
            ),
            ButtonSegment(
              value: 'material',
              label: Text('Material / Ropa'),
              icon: Icon(Icons.shopping_bag, size: 16),
            ),
          ],
          selected: {tipo},
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (states.contains(MaterialState.selected)) {
                return AppColors.verdePrimario;
              }
              return AppColors.grisOscuro;
            }),
            foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (states.contains(MaterialState.selected)) {
                return AppColors.fondoNegro;
              }
              return AppColors.blancoPuro;
            }),
          ),
          onSelectionChanged: (Set<String> nuevaSeleccion) {
            onChanged(nuevaSeleccion.first);
          },
        ),
      ],
    );
  }
}

/// Selector de categoría única. Trabaja con los ids que usa el backend.
class DropdownCategoriaProducto extends StatelessWidget {
  final List<dynamic> categorias;
  final int? idSeleccionada;
  final ValueChanged<int?> onChanged;

  const DropdownCategoriaProducto({
    super.key,
    required this.categorias,
    required this.idSeleccionada,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = <DropdownMenuItem<int>>[];
    for (final categoria in categorias) {
      final id = idDeCategoria(categoria);
      if (id == null) continue;
      items.add(
        DropdownMenuItem<int>(
          value: id,
          child: Text(categoria['nombre'].toString()),
        ),
      );
    }

    final valorValido = items.any((item) => item.value == idSeleccionada)
        ? idSeleccionada
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CATEGORÍA',
          style: TextStyle(
            color: AppColors.blancoPuro,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: valorValido,
          dropdownColor: AppColors.grisOscuro,
          style: EstiloTexto.campoTexto,
          hint: Text('Seleccionar categoría...', style: EstiloTexto.hintTexto),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.grisOscuro,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// Cuadro para elegir la foto del producto. En el formulario de editar
/// muestra la foto actual hasta que se elija una nueva.
class SelectorImagenProducto extends StatelessWidget {
  final XFile? imagen;
  final String? urlActual;
  final String textoVacio;
  final VoidCallback onTap;

  const SelectorImagenProducto({
    super.key,
    required this.imagen,
    required this.onTap,
    this.urlActual,
    this.textoVacio = 'Seleccionar Foto',
  });

  @override
  Widget build(BuildContext context) {
    final haySeleccion = imagen != null;
    final hayFotoActual =
        !haySeleccion && urlActual != null && urlActual!.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 90,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.grisOscuro,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: haySeleccion
                ? AppColors.verdePrimario
                : AppColors.verdePrimario.withOpacity(0.4),
          ),
        ),
        child: hayFotoActual
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      urlActual!,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => const Icon(
                        Icons.image,
                        color: Colors.white54,
                        size: 30,
                      ),
                    ),
                    Container(
                      color: Colors.black.withOpacity(0.45),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add_a_photo_outlined,
                            color: AppColors.verdePrimario,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            textoVacio,
                            style: const TextStyle(
                              color: AppColors.blancoPuro,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    haySeleccion
                        ? Icons.check_circle
                        : Icons.add_a_photo_outlined,
                    color: AppColors.verdePrimario,
                    size: 22,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    haySeleccion ? 'Foto seleccionada' : textoVacio,
                    style: const TextStyle(
                      color: AppColors.blancoPuro,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
      ),
    );
  }
}
