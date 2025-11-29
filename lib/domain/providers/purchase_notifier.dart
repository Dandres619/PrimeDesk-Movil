import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/purchase_model.dart';

/// Provider que gestiona la lista de órdenes de compra.
/// Se inicializa con datos simulados.
final purchaseProvider =
    StateNotifierProvider<PurchaseNotifier, List<PurchaseModel>>((ref) {
  return PurchaseNotifier([
    PurchaseModel(
      id: 201,
      proveedorId: 101,
      date: DateTime.now().subtract(const Duration(days: 7)),
      isCompleted: true,
      items: [
        PurchaseItemModel(itemName: 'Filtro de aceite', quantity: 20, unitCost: 5.50),
      ],
    ),
    PurchaseModel(
      id: 202,
      proveedorId: 102,
      date: DateTime.now().subtract(const Duration(days: 3)),
      isCompleted: false,
      items: [
        PurchaseItemModel(itemName: 'Aceite sintético 10W40', quantity: 100, unitCost: 8.00),
      ],
    ),
  ]);
});

/// Notifier que administra las compras:
/// - Búsqueda por ID, ítems o total.
/// - Registro de nuevas compras.
/// - Marcado como completado.
class PurchaseNotifier extends StateNotifier<List<PurchaseModel>> {
  PurchaseNotifier(List<PurchaseModel> initialPurchases)
      : _fullList = List.from(initialPurchases),
        super(initialPurchases);

  /// Lista interna completa de compras (permite filtrar sin perder datos).
  final List<PurchaseModel> _fullList;

  /// Término actual de búsqueda.
  String _currentSearchTerm = '';

  // --------------------------------------------------------------------------
  //                                BÚSQUEDA
  // --------------------------------------------------------------------------

  /// Actualiza el término ingresado por el usuario y vuelve a aplicar filtros.
  void searchPurchases(String term) {
    _currentSearchTerm = term.toLowerCase();
    _applyFilters();
  }

  /// Filtra por:
  /// - ID
  /// - Nombre de ítem dentro de la compra
  /// - Total formateado
  void _applyFilters() {
    if (_currentSearchTerm.isEmpty) {
      state = List.from(_fullList);
      return;
    }

    state = _fullList
        .where(
          (p) =>
              p.id.toString().contains(_currentSearchTerm) ||
              p.items.any((item) => item.itemName.toLowerCase().contains(_currentSearchTerm)) ||
              p.totalAmount.toStringAsFixed(2).contains(_currentSearchTerm),
        )
        .toList();
  }

  // --------------------------------------------------------------------------
  //                                 CRUD
  // --------------------------------------------------------------------------

  /// Registra una nueva orden de compra.
  /// El ID se genera automáticamente a partir del mayor existente.
  Future<String> registerPurchase(
    int proveedorId,
    List<PurchaseItemModel> items,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final newId = _fullList.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;

    final newPurchase = PurchaseModel(
      id: newId,
      proveedorId: proveedorId,
      date: DateTime.now(),
      items: items,
      isCompleted: false,
    );

    _fullList.add(newPurchase);
    _applyFilters();

    return 'Orden de Compra #$newId registrada con éxito. Total: \$${newPurchase.totalAmount.toStringAsFixed(2)}';
  }

  /// Marca una orden como completada.
  /// Normalmente aquí se actualizaría inventario, pero en este mock solo se refleja el estado.
  Future<String> markAsCompleted(PurchaseModel purchase) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _fullList.indexWhere((p) => p.id == purchase.id);
    if (index == -1) return 'Error: Compra no encontrada.';

    _fullList[index] = purchase.copyWith(isCompleted: true);
    _applyFilters();

    return 'Orden de Compra #${purchase.id} marcada como completada.';
  }
}
