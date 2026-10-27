import 'package:flutter/material.dart';
import 'package:frontend/componentes/administrador/entrenar/admin_text_field.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/services/producto_service.dart';

class ModalGestionCategoriasProductos extends StatefulWidget {
  final List<dynamic> initialCategories;
  final VoidCallback onCategoriesUpdated;

  const ModalGestionCategoriasProductos({
    super.key,
    required this.initialCategories,
    required this.onCategoriesUpdated,
  });

  @override
  State<ModalGestionCategoriasProductos> createState() =>
      _ModalGestionCategoriasProductosState();
}

class _ModalGestionCategoriasProductosState
    extends State<ModalGestionCategoriasProductos> {
  List<dynamic> categorias = [];
  final TextEditingController _nuevaCategoriaController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    categorias = List.from(widget.initialCategories);
  }

  @override
  void dispose() {
    _nuevaCategoriaController.dispose();
    super.dispose();
  }

  void _mostrarMensaje(String mensaje, {required Color color, int segundos = 3}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
        duration: Duration(seconds: segundos),
      ),
    );
  }

  // Crear una categoría mediante la API
  Future<void> _crearCategoria() async {
    final nombre = _nuevaCategoriaController.text.trim();
    if (nombre.isEmpty) return;

    setState(() => _isLoading = true);
    final resultado = await ProductoService.crearCategoria(nombre);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (resultado['success'] == true) {
      _nuevaCategoriaController.clear();
      await _actualizarListaRemota();
      _mostrarMensaje(resultado['message'].toString(), color: Colors.green);
    } else {
      _mostrarMensaje(resultado['message'].toString(), color: Colors.redAccent);
    }
  }

  // Editar una categoría mediante la API
  Future<void> _editarCategoria(int idCategoria, String nuevoNombre) async {
    setState(() => _isLoading = true);
    final resultado =
        await ProductoService.actualizarCategoria(idCategoria, nuevoNombre);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (resultado['success'] == true) {
      await _actualizarListaRemota();
      if (!mounted) return;
      Navigator.pop(context); // Cierra el diálogo de edición
      _mostrarMensaje(resultado['message'].toString(), color: Colors.green);
    } else {
      _mostrarMensaje(resultado['message'].toString(), color: Colors.orangeAccent);
    }
  }

  // Eliminar una categoría (el backend la rechaza si tiene productos asociados)
  Future<void> _eliminarCategoria(dynamic categoriaItem) async {
    final int? idCategoria = categoriaItem is Map
        ? int.tryParse(categoriaItem['id_categoria'].toString())
        : null;

    if (idCategoria == null) {
      _mostrarMensaje('ID de categoría inválido', color: Colors.redAccent);
      return;
    }

    setState(() => _isLoading = true);
    final resultado = await ProductoService.eliminarCategoria(idCategoria);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (resultado['success'] == true) {
      await _actualizarListaRemota();
      if (!mounted) return;
      Navigator.pop(context); // Cierra el diálogo de confirmación
      _mostrarMensaje(resultado['message'].toString(), color: Colors.green);
    } else {
      Navigator.pop(context); // Cierra el diálogo de confirmación
      _mostrarMensaje(
        resultado['message'].toString(),
        color: Colors.orangeAccent,
        segundos: 4,
      );
    }
  }

  // Sincroniza la lista con el backend y avisa a la pantalla principal
  Future<void> _actualizarListaRemota() async {
    try {
      final remotas = await ProductoService.obtenerCategorias();
      if (!mounted) return;
      setState(() => categorias = remotas);
      widget.onCategoriesUpdated();
    } catch (e) {
      _mostrarMensaje('No se pudo actualizar la lista: $e', color: Colors.redAccent);
    }
  }

  void _mostrarDialogoEditar(dynamic cat) {
    final int? idCategoria =
        cat is Map ? int.tryParse(cat['id_categoria'].toString()) : null;
    final String nombreActual = cat is Map ? (cat['nombre'] ?? '').toString() : cat.toString();

    if (idCategoria == null) {
      _mostrarMensaje(
        'No se puede editar esta categoría por falta de ID',
        color: Colors.redAccent,
      );
      return;
    }

    final TextEditingController editarController =
        TextEditingController(text: nombreActual);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.grisOscuro,
          title: Text(
            'Editar Categoría',
            style: EstiloTexto.enlaceNegritaRoboto.copyWith(color: AppColors.blancoPuro),
          ),
          content: TextField(
            controller: editarController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Nuevo nombre',
              labelStyle: TextStyle(color: AppColors.verdePrimario),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.verdePrimario)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'CANCELAR',
                style: EstiloTexto.politicasRoboto.copyWith(color: AppColors.grisMedio),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.verdePrimario,
                foregroundColor: AppColors.fondoNegro,
              ),
              onPressed: () {
                final String nuevoNombre = editarController.text.trim();
                if (nuevoNombre.isNotEmpty) {
                  _editarCategoria(idCategoria, nuevoNombre);
                }
              },
              child: const Text('GUARDAR'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoEliminar(dynamic cat) {
    final String nombre = cat is Map ? (cat['nombre'] ?? '').toString() : cat.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.grisOscuro,
          title: Text(
            'Eliminar Categoría',
            style: EstiloTexto.enlaceNegritaRoboto.copyWith(color: AppColors.blancoPuro),
          ),
          content: Text(
            '¿Estás segura de que deseas eliminar la categoría "$nombre"?',
            style: EstiloTexto.textoNormalRoboto.copyWith(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'CANCELAR',
                style: EstiloTexto.politicasRoboto.copyWith(color: AppColors.grisMedio),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () => _eliminarCategoria(cat),
              child: const Text('ELIMINAR'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: AppColors.fondoNegro,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ADMINISTRAR CATEGORÍAS',
            style: EstiloTexto.tituloBienvenida.copyWith(
              fontSize: 18,
              color: AppColors.verdePrimario,
            ),
          ),
          const SizedBox(height: 12),

          // Campo para agregar nueva categoría vía API
          Row(
            children: [
              Expanded(
                child: AdminTextField(
                  label: 'Nueva Categoría',
                  controller: _nuevaCategoriaController,
                ),
              ),
              const SizedBox(width: 8),
              _isLoading
                  ? const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        color: AppColors.verdePrimario,
                        strokeWidth: 2,
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.add_circle, color: AppColors.verdePrimario, size: 32),
                      onPressed: _crearCategoria,
                    ),
            ],
          ),
          const SizedBox(height: 15),

          // Lista de categorías conectadas al servidor
          Expanded(
            child: categorias.isEmpty
                ? Center(
                    child: Text(
                      'Aún no hay categorías. Crea la primera.',
                      style: EstiloTexto.textoNormalRoboto.copyWith(
                        color: AppColors.grisClaro,
                        fontSize: 13,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: categorias.length,
                    itemBuilder: (context, index) {
                      final item = categorias[index];
                      final String nombreCat =
                          item is Map ? (item['nombre'] ?? '').toString() : item.toString();
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.grisOscuro,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          title: Text(
                            nombreCat,
                            style: EstiloTexto.textoNormalRoboto.copyWith(color: AppColors.blancoPuro),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: AppColors.verdePrimario, size: 20),
                                onPressed: () => _mostrarDialogoEditar(item),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                onPressed: () => _mostrarDialogoEliminar(item),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
