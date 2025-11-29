/// Modelo que representa una categoría de productos
/// Las categorías agrupan productos por tipo (Lubricantes, Filtros, Frenos, etc.)
class CategoryModel {
  /// Identificador único de la categoría
  final int id;
  
  /// Nombre de la categoría (máx 50 caracteres)
  String name; // VARCHAR(50)
  
  /// Descripción detallada de la categoría
  String description; // TEXT
  
  /// Indica si la categoría está activa o desactivada en el sistema
  bool isActive; // Estado Activo/Inactivo

  /// Constructor del modelo CategoryModel
  /// Acepta [id] y [name] como parámetros obligatorios
  /// [description] tiene valor por defecto de cadena vacía
  /// [isActive] por defecto es true
  CategoryModel({
    required this.id,
    required this.name,
    this.description = '',
    this.isActive = true,
  });
}
