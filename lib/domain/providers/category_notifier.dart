import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/category_model.dart';
import '../../data/mock_data/mock_data.dart'; // Contiene mockCategoriesData y mockProducts

/// Proveedor principal que expone la lista de categorías y permite modificarlas.
final categoryProvider =
    StateNotifierProvider<CategoryNotifier, List<CategoryModel>>((ref) {
  return CategoryNotifier(ref);
});

class CategoryNotifier extends StateNotifier<List<CategoryModel>> {
  final Ref ref;

  /// Inicializa el notifier con datos mock para pruebas.
  CategoryNotifier(this.ref) : super(mockCategoriesData);

  /// Genera un ID incremental basado en los IDs existentes.
  int _getNextId() {
    if (state.isEmpty) return 1;
    return state.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  /// Registra una nueva categoría, validando duplicados por nombre.
  Future<String> registerCategory(String name, String description) async {
    // Verificación de nombre duplicado
    if (state.any((c) => c.name.toLowerCase() == name.toLowerCase())) {
      return 'Error: Ya existe una categoría con ese nombre.';
    }

    // Simulación de respuesta rápida del servidor
    await Future.delayed(const Duration(milliseconds: 50));

    final newCategory = CategoryModel(
      id: _getNextId(),
      name: name,
      description: description,
      isActive: true,
    );

    // Agregar nueva categoría a la lista
    state = [...state, newCategory];

    return 'Categoría registrada exitosamente.';
  }

  /// Permite editar el nombre y descripción de una categoría existente.
  Future<String> editCategory(
      int id, String newName, String newDescription) async {
    // Evita duplicar nombres en otras categorías activas
    if (state.any((c) =>
        c.id != id &&
        c.name.toLowerCase() == newName.toLowerCase() &&
        c.isActive)) {
      return 'Error: Ya existe una categoría activa con ese nombre.';
    }

    await Future.delayed(const Duration(milliseconds: 50));

    // Actualiza únicamente la categoría cuyo ID coincide
    state = state.map((c) {
      if (c.id == id) {
        return CategoryModel(
          id: id,
          name: newName,
          description: newDescription,
          isActive: c.isActive,
        );
      }
      return c;
    }).toList();

    return 'Categoría actualizada exitosamente.';
  }

  /// Cambia el estado activo/inactivo de una categoría.
  /// Evita desactivar categorías actualmente usadas por productos.
  Future<String> toggleStatus(int id, bool newStatus) async {
    final categoryToToggle = state.firstWhere((c) => c.id == id);

    // No permite desactivar categorías que están asociadas a productos
    if (!newStatus && _isCategoryUsed(categoryToToggle.name)) {
      return 'Error: No es posible desactivar esta categoría porque está en uso por un producto.';
    }

    await Future.delayed(const Duration(milliseconds: 50));

    state = state.map((c) {
      return c.id == id
          ? CategoryModel(
              id: id,
              name: c.name,
              description: c.description,
              isActive: newStatus,
            )
          : c;
    }).toList();

    return 'Estado actualizado correctamente.';
  }

  /// Elimina una categoría si no está asociada a ningún producto.
  Future<String> deleteCategory(int id) async {
    final categoryName = state.firstWhere((c) => c.id == id).name;

    // No se puede eliminar si está en uso por un producto
    if (_isCategoryUsed(categoryName)) {
      return 'Error: No es posible eliminar esta categoría porque está en uso.';
    }

    await Future.delayed(const Duration(milliseconds: 50));

    state = state.where((c) => c.id != id).toList();

    return 'Categoría eliminada correctamente.';
  }

  /// Indica si una categoría está actualmente usada por algún producto mock.
  bool _isCategoryUsed(String categoryName) {
    return mockProducts.any((p) => p.category == categoryName);
  }
}
