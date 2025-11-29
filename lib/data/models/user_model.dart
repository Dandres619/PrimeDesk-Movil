/// Modelo que representa un usuario en el sistema
/// Almacena información de autenticación y perfil del usuario
class UserModel {
  /// Identificador único del usuario en la base de datos
  final int id;
  
  /// Nombre completo del usuario
  final String name;
  
  /// Correo electrónico único del usuario
  final String email;
  
  /// Rol asignado al usuario: 'Administrador', 'Mecánico' o 'Cliente'
  final String role; // 'Administrador', 'Mecánico', 'Cliente'
  
  /// Número de teléfono del usuario (máx 20 caracteres)
  final String telefono; // VARCHAR(20)
  
  /// Token de autenticación/sesión del usuario
  final String token;

  /// Constructor del modelo UserModel
  /// Todos los parámetros son requeridos y deben pasarse como nombrados
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.telefono,
    required this.token,
  });

  /// Constructor nombrado para crear un usuario no autenticado (valores por defecto vacíos)
  const UserModel.unauthenticated()
      : id = 0,
        name = '',
        email = '',
        role = '',
        telefono = '',
        token = '';

  /// Método copyWith que crea una copia del objeto con algunos campos modificados
  /// Esencial para Riverpod y gestión de estado inmutable
  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    String? telefono,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      telefono: telefono ?? this.telefono,
      token: token ?? this.token,
    );
  }

  /// Método toMap: Convierte el modelo a un mapa para serialización JSON
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'telefono': telefono,
      'token': token,
    };
  }

  /// Factory constructor que crea un UserModel desde un mapa (deserialización JSON)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      telefono: map['telefono'] ?? '',
      token: map['token'] ?? '',
    );
  }

  /// Operador de igualdad para comparar dos objetos UserModel
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.role == role &&
        other.telefono == telefono &&
        other.token == token;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, email, role, telefono, token);
  }

  /// Método toString para representar el objeto como cadena (útil para debugging)
  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, role: $role, telefono: $telefono, token: ${token.isNotEmpty ? '***' : 'empty'})';
  }

  /// Getter que verifica si el usuario tiene un token válido (autenticado)
  bool get isAuthenticated => token.isNotEmpty;
  
  /// Getter que verifica si el usuario tiene rol de Administrador
  bool get isAdmin => role == 'Administrador';
  
  /// Getter que verifica si el usuario tiene rol de Mecánico
  bool get isMecanico => role == 'Mecánico';
  
  /// Getter que verifica si el usuario tiene rol de Cliente
  bool get isCliente => role == 'Cliente';
  
  /// Getter que verifica si el objeto está vacío (sin datos)
  bool get isEmpty => id == 0 && name.isEmpty && email.isEmpty;
}
