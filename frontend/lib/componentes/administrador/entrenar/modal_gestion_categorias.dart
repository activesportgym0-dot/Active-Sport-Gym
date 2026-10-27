import 'package:flutter/material.dart';
import 'package:frontend/componentes/administrador/entrenar/admin_text_field.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/services/ejercicio_service.dart';

class ModalGestionCategorias extends StatefulWidget {
  final List<dynamic> initialCategories; // Puede recibir objetos o strings
  final Function(List<String>) onCategoriesUpdated;

  const ModalGestionCategorias({
    super.key,
    required this.initialCategories,
    required this.onCategoriesUpdated,
  });

  @override
  State<ModalGestionCategorias> createState() => _ModalGestionCategoriasState();
}

class _ModalGestionCategoriasState extends State<ModalGestionCategorias> {
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

  // 🌟 Método para crear una categoría mediante la API
  Future<void> _crearCategoria() async {
    final nombre = _nuevaCategoriaController.text.trim();
    if (nombre.isEmpty) return;

    setState(() => _isLoading = true);
    var resultado = await EjercicioService.crearCategoria(nombre);
    setState(() => _isLoading = false);

    if (resultado['success']) {
      _nuevaCategoriaController.clear();
      // Recargamos las categorías desde el servidor
      await _actualizarListaRemota();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resultado['message']), backgroundColor: Colors.green),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resultado['message']), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  // 🌟 Método para editar una categoría mediante la API
  Future<void> _editarCategoria(int idCategoria, String nuevoNombre) async {
    setState(() => _isLoading = true);
    var resultado = await EjercicioService.actualizarCategoria(idCategoria, nuevoNombre);
    setState(() => _isLoading = false);

    if (resultado['success']) {
      await _actualizarListaRemota();
      if (mounted) {
        Navigator.pop(context); // Cierra el diálogo de edición
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resultado['message']), backgroundColor: Colors.green),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resultado['message']), backgroundColor: Colors.orangeAccent),
        );
      }
    }
  }

  // 🌟 Método para eliminar una categoría validando el código 409 del backend
  Future<void> _eliminarCategoria(dynamic categoriaItem) async {
    int? idCategoria;
    String nombreCat = '';

    if (categoriaItem is Map) {
      idCategoria = categoriaItem['id_categoria'];
      nombreCat = categoriaItem['nombre'] ?? '';
    } else {
      nombreCat = categoriaItem.toString();
    }

    if (idCategoria == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID de categoría inválido'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isLoading = true);
    var resultado = await EjercicioService.eliminarCategoria(idCategoria);
    setState(() => _isLoading = false);

    if (resultado['success']) {
      await _actualizarListaRemota();
      if (mounted) {
        Navigator.pop(context); // Cierra el diálogo de confirmación
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resultado['message']), backgroundColor: Colors.green),
        );
      }
    } else {
      if (mounted) {
        Navigator.pop(context); // Cierra el diálogo de confirmación
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resultado['message']),
            backgroundColor: Colors.orangeAccent,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  // Sincroniza la lista con el backend y notifica al padre
  Future<void> _actualizarListaRemota() async {
    final remotas = await EjercicioService.obtenerCategorias();
    setState(() {
      categorias = remotas;
    });

    List<String> nombres = remotas.map((c) => c['nombre'].toString()).toList();
    widget.onCategoriesUpdated(nombres);
  }

  // 🌟 Diálogo para editar nombre de categoría
  void _mostrarDialogoEditar(dynamic cat) {
    int? idCategoria = cat is Map ? cat['id_categoria'] : null;
    String nombreActual = cat is Map ? (cat['nombre'] ?? '') : cat.toString();

    if (idCategoria == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se puede editar esta categoría por falta de ID'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    final TextEditingController editarController = TextEditingController(text: nombreActual);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.grisOscuro,
          title: Text('Editar Categoría', style: EstiloTexto.enlaceNegritaRoboto.copyWith(color: AppColors.blancoPuro)),
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
              child: Text('CANCELAR', style: EstiloTexto.politicasRoboto.copyWith(color: AppColors.grisMedio)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.verdePrimario, foregroundColor: AppColors.fondoNegro),
              onPressed: () {
                String nuevoNombre = editarController.text.trim();
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
    String nombre = cat is Map ? cat['nombre'] : cat.toString();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.grisOscuro,
          title: Text('Eliminar Categoría', style: EstiloTexto.enlaceNegritaRoboto.copyWith(color: AppColors.blancoPuro)),
          content: Text(
            '¿Estás segura de que deseas eliminar la categoría "$nombre"?',
            style: EstiloTexto.textoNormalRoboto.copyWith(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CANCELAR', style: EstiloTexto.politicasRoboto.copyWith(color: AppColors.grisMedio)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
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
            style: EstiloTexto.tituloBienvenida.copyWith(fontSize: 18, color: AppColors.verdePrimario),
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
                  ? const SizedBox(width: 32, height: 32, child: CircularProgressIndicator(color: AppColors.verdePrimario, strokeWidth: 2))
                  : IconButton(
                      icon: const Icon(Icons.add_circle, color: AppColors.verdePrimario, size: 32),
                      onPressed: _crearCategoria,
                    ),
            ],
          ),
          const SizedBox(height: 15),
          
          // Lista de categorías actuales conectadas al servidor
          Expanded(
            child: ListView.builder(
              itemCount: categorias.length,
              itemBuilder: (context, index) {
                final item = categorias[index];
                String nombreCat = item is Map ? item['nombre'] : item.toString();

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.grisOscuro,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    title: Text(nombreCat, style: EstiloTexto.textoNormalRoboto.copyWith(color: AppColors.blancoPuro)),
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