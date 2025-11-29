import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product_model.dart';
import '../../data/mock_data/mock_data.dart'; // Datos mock para pruebas

/// Estado que representa la lista de productos junto con
/// información de carga, errores y preferencias de filtrado/ordenamiento.
class ProductListState {
  final List<ProductModel> products;
  final bool isLoading;
  final String? error;
  final String currentFilter; // Categoría aplicada como filtro
  final String currentSort; // Criterio de ordenamiento activo

  ProductListState({
    required this.products,
    this.isLoading = false,
    this.error,
    this.currentFilter = 'Todos',
    this.currentSort = 'Ninguno',
  });
}

/// Proveedor principal que expone la lista de productos filtrada y ordenada.
final productListProvider =
    StateNotifierProvider<ProductListNotifier, ProductListState>((ref) {
  return ProductListNotifier();
});

/// Notifier encargado de cargar productos, filtrarlos y ordenarlos.
/// Todos los cambios de estado pasan por aquí.
class ProductListNotifier extends StateNotifier<ProductListState> {
  ProductListNotifier() : super(ProductListState(products: [])) {
    loadProducts(); // Carga inicial
  }

  /// Carga productos desde mock data, aplicando:
  /// 1. Filtros por categoría
  /// 2. Ordenamientos por nombre o precio
  /// El método simula una espera para replicar una llamada real a backend.
  Future<void> loadProducts({String? filterCategory, String? sortBy}) async {
    // Actualizar estado mientras se solicita el nuevo filtro/ordenamiento
    state = ProductListState(
      products: state.products,
      isLoading: true,
      currentFilter: filterCategory ?? state.currentFilter,
      currentSort: sortBy ?? state.currentSort,
    );

    // Simulación de tiempo de carga (CA_40_01)
    await Future.delayed(const Duration(milliseconds: 400));

    // 1️⃣ Filtrar productos disponibles
    List<ProductModel> filtered =
        mockProducts.where((p) => p.isAvailable).toList();

    // Filtro por categoría (CU20)
    if (state.currentFilter != 'Todos') {
      filtered =
          filtered.where((p) => p.category == state.currentFilter).toList();
    }

    // 2️⃣ Ordenamiento según criterio seleccionado
    if (state.currentSort == 'name') {
      filtered.sort((a, b) => a.name.compareTo(b.name));
    } else if (state.currentSort == 'price_asc') {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    }

    // Actualizar estado final con la lista procesada
    state = ProductListState(
      products: filtered,
      isLoading: false,
      currentFilter: state.currentFilter,
      currentSort: state.currentSort,
    );
  }
}
