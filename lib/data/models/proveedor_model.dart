/// Modelo que representa a un proveedor de productos y servicios
/// Contiene información de contacto y estado del proveedor
class ProveedorModel {
  /// Identificador único del proveedor
  final int id;
  
  /// Nombre comercial del proveedor
  final String nombre;
  
  /// Nombre de la persona de contacto en el proveedor
  final String contacto;
  
  /// Número telefónico de contacto del proveedor
  final String telefono;
  
  /// Correo electrónico del proveedor
  final String email;
  
  /// Dirección física del proveedor
  final String direccion;
  
  /// Indica si el proveedor está activo o inactivo en el sistema
  final bool isActive;

  /// Constructor del modelo ProveedorModel
  /// Todos los parámetros son requeridos excepto [isActive] que por defecto es true
  ProveedorModel({
    required this.id,
    required this.nombre,
    required this.contacto,
    required this.telefono,
    required this.email,
    required this.direccion,
    this.isActive = true,
  });

  /// Método copyWith que crea una copia del proveedor con campos modificados
  ProveedorModel copyWith({
    int? id,
    String? nombre,
    String? contacto,
    String? telefono,
    String? email,
    String? direccion,
    bool? isActive,
  }) {
    return ProveedorModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      contacto: contacto ?? this.contacto,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      direccion: direccion ?? this.direccion,
      isActive: isActive ?? this.isActive,
    );
  }
}
