/// Modelo que representa un ítem dentro de una orden de compra
/// Contiene detalles del producto y cantidad comprada
class PurchaseItemModel {
  /// Nombre del producto siendo comprado
  final String itemName;
  
  /// Cantidad de unidades compradas del ítem
  final int quantity;
  
  /// Costo unitario del ítem
  final double unitCost;

  /// Constructor del modelo PurchaseItemModel
  PurchaseItemModel({
    required this.itemName,
    required this.quantity,
    required this.unitCost,
  });

  /// Calcula el total del ítem (cantidad × costo unitario)
  double get total => quantity * unitCost;
}

/// Modelo que representa una orden de compra a un proveedor
/// Agrupa múltiples ítems y almacena información de la transacción
class PurchaseModel {
  /// Identificador único de la orden de compra
  final int id;
  
  /// ID del proveedor del que se realiza la compra
  final int proveedorId;
  
  /// Fecha y hora en que se realizó la orden de compra
  final DateTime date;
  
  /// Lista de ítems incluidos en esta orden de compra
  final List<PurchaseItemModel> items;
  
  /// Indica si la orden de compra ha sido completada/entregada
  final bool isCompleted;

  /// Constructor del modelo PurchaseModel
  PurchaseModel({
    required this.id,
    required this.proveedorId,
    required this.date,
    required this.items,
    this.isCompleted = false,
  });

  /// Calcula el monto total de la orden sumando los totales de todos los ítems
  double get totalAmount => items.fold(0.0, (sum, item) => sum + item.total);

  /// Método copyWith que crea una copia de la orden de compra con campos modificados
  PurchaseModel copyWith({
    int? id,
    int? proveedorId,
    DateTime? date,
    List<PurchaseItemModel>? items,
    bool? isCompleted,
  }) {
    return PurchaseModel(
      id: id ?? this.id,
      proveedorId: proveedorId ?? this.proveedorId,
      date: date ?? this.date,
      items: items ?? this.items,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
