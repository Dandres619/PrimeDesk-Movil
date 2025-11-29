import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/providers/product_list_notifier.dart';
import '../../data/mock_data/mock_data.dart';
import '../widgets/custom_app_bar.dart';

/// Pantalla de Gestión de Productos.
/// Permite visualizar, filtrar y ordenar los productos disponibles.
/// Implementa CU18–CU24: funcionalidades de listado, búsqueda y filtrado.
class ProductosScreen extends ConsumerWidget {
  const ProductosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Estado proveniente del ProductListNotifier: incluye productos, loading, filtros, etc.
    final productState = ref.watch(productListProvider);

    // Notifier utilizado para ejecutar acciones como filtrar u ordenar.
    final productNotifier = ref.read(productListProvider.notifier);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Gestión de Productos'),
      body: Column(
        children: [
          // =====================================================================
          // SECCIÓN DE FILTRADO Y ORDENAMIENTO
          // Permite ajustar la vista según categoría seleccionada y criterio de ordenación.
          // =====================================================================
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // -------------------------------
                // Filtro por Categoría (CU20)
                // -------------------------------
                DropdownButton<String>(
                  value: productState.currentFilter,
                  items: ['Todos', ...mockCategories].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      productNotifier.loadProducts(filterCategory: newValue);
                    }
                  },
                ),

                // -------------------------------
                // Ordenamiento de productos (CU20)
                // -------------------------------
                DropdownButton<String>(
                  value: productState.currentSort,
                  items: const [
                    DropdownMenuItem(
                        value: 'Ninguno', child: Text('Ordenar')),
                    DropdownMenuItem(
                        value: 'name', child: Text('Nombre A-Z')),
                    DropdownMenuItem(
                        value: 'price_asc', child: Text('Precio Asc.')),
                  ],
                  onChanged: (newValue) {
                    if (newValue != null) {
                      productNotifier.loadProducts(sortBy: newValue);
                    }
                  },
                ),
              ],
            ),
          ),

          // =====================================================================
          // LISTADO DE PRODUCTOS (CU19)
          // Muestra los productos según los filtros aplicados.
          // Maneja estados de carga, lista vacía y lista con elementos.
          // =====================================================================
          Expanded(
            child: productState.isLoading
                // Indicador mientras se cargan los productos
                ? const Center(child: CircularProgressIndicator())

                // Mensaje cuando la búsqueda/filtrado no arroja resultados
                : productState.products.isEmpty
                    ? const Center(
                        child: Text(
                            'No se encontraron productos disponibles.'), // CA_41_02
                      )

                    // Lista de productos cargados
                    : ListView.builder(
                        itemCount: productState.products.length,
                        itemBuilder: (context, index) {
                          final product = productState.products[index];

                          return ListTile(
                            title: Text(product.name),
                            subtitle: Text(
                              'Categoría: ${product.category} | Stock: ${product.stock}',
                            ),
                            trailing: Text(
                              '\$${product.price.toStringAsFixed(2)}',
                            ),

                            // Acción simulada para CU23: Ver detalle del producto
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Simulando Ver Detalle del Producto...'),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),

      // =====================================================================
      // BOTÓN FLOTANTE PARA REGISTRAR PRODUCTOS (CU18)
      // =====================================================================
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Acción de CU18: Registrar nuevos productos (por implementar).
        },
        label: const Text('Nuevo Producto'),
        icon: const Icon(Icons.add_shopping_cart),
      ),
    );
  }
}
