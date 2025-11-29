/// Modelo que representa un agendamiento de servicio para una motocicleta
/// Registra la cita de un cliente para que su moto reciba mantenimiento
class AppointmentModel {
  /// Identificador único del agendamiento
  final int id;
  
  /// ID del cliente que realiza el agendamiento
  final int clientId;
  
  /// ID de la motocicleta a la que se le dará servicio
  final int motoId;
  
  /// Fecha y hora programada para el servicio
  final DateTime dateTime;
  
  /// Tipo de servicio a realizar (Cambio de Aceite, Revisión General, etc.)
  final String serviceType;
  
  /// ID del empleado/mecánico asignado al agendamiento (si aplica)
  final String employeeId; // ID del empleado asignado (si aplica)
  
  /// Indica si el agendamiento ha sido confirmado
  final bool isConfirmed;

  /// Constructor del modelo AppointmentModel
  /// Todos los parámetros son requeridos excepto [isConfirmed] que por defecto es false
  AppointmentModel({
    required this.id,
    required this.clientId,
    required this.motoId,
    required this.dateTime,
    required this.serviceType,
    required this.employeeId,
    this.isConfirmed = false,
  });

  /// Método copyWith que crea una copia del agendamiento con campos modificados
  AppointmentModel copyWith({
    int? id,
    int? clientId,
    int? motoId,
    DateTime? dateTime,
    String? serviceType,
    String? employeeId,
    bool? isConfirmed,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      motoId: motoId ?? this.motoId,
      dateTime: dateTime ?? this.dateTime,
      serviceType: serviceType ?? this.serviceType,
      employeeId: employeeId ?? this.employeeId,
      isConfirmed: isConfirmed ?? this.isConfirmed,
    );
  }
}
