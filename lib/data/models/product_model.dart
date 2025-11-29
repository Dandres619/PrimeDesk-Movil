/// Modelo que representa un producto en el sistema
/// Contiene información sobre el artículo, su precio, stock y disponibilidad
class ProductModel {
  /// Identificador único del producto
  final int id;
  
  /// Nombre comercial del producto
  final String name;
  
  /// Precio unitario del producto (formato decimal con 2 decimales)
  final double price; // DECIMAL(10,2)
  
  /// Cantidad disponible en inventario
  final int stock;
  
  /// Categoría a la que pertenece el producto (Lubricantes, Filtros, etc.)
  final String category;
  
  /// Indica si el producto está disponible para venta
  final bool isAvailable; // Estado de disponibilidad

  /// Constructor del modelo ProductModel
  /// Todos los parámetros son requeridos excepto [isAvailable] que por defecto es true
  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.category,
    this.isAvailable = true,
  });
}
