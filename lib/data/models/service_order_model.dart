/// Modelo que representa una orden de servicio para una motocicleta
/// Registra el trabajo a realizar, el cliente, mecánico y estado del servicio
class ServiceOrderModel {
  /// Identificador único de la orden de servicio
  final int id;
  
  /// ID de la motocicleta a la que se le dará servicio
  final int motoId;
  
  /// Nombre del cliente propietario de la moto
  final String clientName;
  
  /// Placa de la motocicleta (para referencia rápida)
  final String motoPlaca;
  
  /// Nombre del mecánico asignado al servicio
  final String mechanicName;
  
  /// Estado actual de la orden: 'Pendiente', 'En Progreso' o 'Finalizado'
  final String status; // Pendiente, En Progreso, Finalizado
  
  /// Fecha y hora de ingreso del vehículo al taller
  final DateTime entryDate;
  
  /// Descripción detallada del trabajo a realizar
  final String workDescription;

  /// Constructor del modelo ServiceOrderModel
  /// Todos los parámetros son requeridos
  ServiceOrderModel({
    required this.id,
    required this.motoId,
    required this.clientName,
    required this.motoPlaca,
    required this.mechanicName,
    required this.status,
    required this.entryDate,
    required this.workDescription,
  });
}
