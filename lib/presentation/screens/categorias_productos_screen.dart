import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/providers/category_notifier.dart';
import '../../data/models/category_model.dart';
import '../widgets/custom_app_bar.dart';

/// Pantalla para administrar categorías de productos.
/// Permite listar, registrar, editar, activar/desactivar y eliminar categorías.
/// Todo el estado es gestionado por Riverpod a través de [categoryProvider].
class CategoriasProductosScreen extends ConsumerWidget {
  const CategoriasProductosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// Estado reactivo con la lista de categorías.
    /// Cuando el notifier actualiza la lista, la UI se reconstruye automáticamente.
    final categories = ref.watch(categoryProvider);

    /// Acceso al notifier para ejecutar acciones: registrar, editar, eliminar, togglear estado.
    final notifier = ref.read(categoryProvider.notifier);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Gestión de Categorías'),

      /// Vista principal: Lista de categorías o mensaje si está vacío.
      body: categories.isEmpty
          ? const Center(child: Text('No hay categorías registradas.'))
          : ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];

                return ListTile(
                  title: Text(category.name),
                  subtitle: Text(category.description),

                  /// Acciones rápidas por elemento: cambiar estado, editar o eliminar.
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// Cambia el estado activo/inactivo de la categoría.
                      Switch(
                        value: category.isActive,
                        onChanged: (newValue) async {
                          final result = await notifier.toggleStatus(
                              category.id, newValue);
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(result)));
                        },
                      ),

                      /// Abre diálogo de edición.
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () =>
                            _showEditDialog(context, notifier, category),
                      ),

                      /// Solicita confirmación antes de eliminar.
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            _confirmDelete(context, notifier, category),
                      ),
                    ],
                  ),

                  /// Vista rápida del detalle (placeholder).
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Detalle de ${category.name}')),
                    );
                  },
                );
              },
            ),

      /// Botón flotante para registrar una nueva categoría.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRegisterDialog(context, notifier),
        label: const Text('Nueva Categoría'),
        icon: const Icon(Icons.label),
      ),
    );
  }

  /// Muestra un diálogo para registrar una nueva categoría.
  /// Utiliza textos controlados para capturar la entrada del usuario.
  void _showRegisterDialog(BuildContext context, CategoryNotifier notifier) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrar Categoría'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration:
                  const InputDecoration(labelText: 'Nombre (Requerido)'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) {
                /// Validación mínima para evitar registros inválidos.
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('El nombre es obligatorio.')));
                return;
              }

              Navigator.pop(context);

              final result = await notifier.registerCategory(
                nameController.text,
                descController.text,
              );

              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(result)));
            },
            child: const Text('Registrar'),
          ),
        ],
      ),
    );
  }

  /// Muestra un diálogo para editar una categoría existente.
  /// Se inicializan los campos con los valores actuales de la categoría.
  void _showEditDialog(
      BuildContext context, CategoryNotifier notifier, CategoryModel category) {
    final nameController = TextEditingController(text: category.name);
    final descController = TextEditingController(text: category.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Categoría'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;

              Navigator.pop(context);

              final result = await notifier.editCategory(
                category.id,
                nameController.text,
                descController.text,
              );

              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(result)));
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  /// Solicita confirmación antes de eliminar una categoría.
  /// La eliminación es irreversible dentro de este módulo.
  void _confirmDelete(
      BuildContext context, CategoryNotifier notifier, CategoryModel category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text(
            '¿Está seguro de eliminar la categoría "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              final result = await notifier.deleteCategory(category.id);

              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(result)));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
