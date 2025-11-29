/// Modelo que representa una motocicleta registrada en el sistema
/// Almacena información técnica del vehículo y su relación con el propietario (cliente)
class MotoModel {
  /// Identificador único de la motocicleta
  final int id;
  
  /// ID del cliente propietario de la moto
  final int clientId; // ID del cliente dueño
  
  /// Placa de registro del vehículo (Registrar Motocicleta)
  final String placa;
  
  /// Marca fabricante de la motocicleta (Yamaha, Honda, Kawasaki, etc.)
  final String marca;
  
  /// Modelo específico del vehículo (MT-07, CB500X, Ninja 400, etc.) 
  final String modelo;
  
  /// Año de fabricación de la motocicleta
  final int anio;
  
  /// Color del vehículo
  final String color;
  
  /// Número VIN (Vehicle Identification Number) - Identificación única del vehículo
  final String vin; // Identificación del vehículo
  
  /// Indica si la moto está activa en el sistema (Cambiar estado de Moto)
  final bool isActive;

  /// Constructor del modelo MotoModel
  /// Todos los parámetros son requeridos excepto [isActive] que por defecto es true
  MotoModel({
    required this.id,
    required this.clientId,
    required this.placa,
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.color,
    required this.vin,
    this.isActive = true,
  });
}
