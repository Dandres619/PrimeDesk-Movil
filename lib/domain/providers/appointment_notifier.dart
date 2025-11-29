import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/appointment_model.dart';

// ====================================================================
// PROVEEDOR PRINCIPAL DE AGENDAMIENTOS
// Maneja la lista de citas registradas en el sistema.
// ====================================================================

final appointmentProvider =
    StateNotifierProvider<AppointmentNotifier, List<AppointmentModel>>((ref) {
  return AppointmentNotifier([
    // Agendamientos iniciales de ejemplo
    AppointmentModel(
      id: 301,
      clientId: 1,
      motoId: 1,
      dateTime: DateTime.now().add(const Duration(hours: 3)),
      serviceType: 'Cambio de Aceite',
      employeeId: 'Mech1',
      isConfirmed: true,
    ),
    AppointmentModel(
      id: 302,
      clientId: 2,
      motoId: 2,
      dateTime: DateTime.now().add(const Duration(days: 1, hours: 10)),
      serviceType: 'Revisión General',
      employeeId: 'Mech1',
      isConfirmed: false,
    ),
  ]);
});

// ====================================================================
// NOTIFIER: ADMINISTRA BUSQUEDA, REGISTRO, EDICIÓN Y CONFIRMACIÓN
// DE AGENDAMIENTOS.
// ====================================================================

class AppointmentNotifier extends StateNotifier<List<AppointmentModel>> {
  AppointmentNotifier(super.state);

  // Lista completa de agendamientos (fuente primaria de datos)
  final List<AppointmentModel> _allAppointments = [
    AppointmentModel(
      id: 301,
      clientId: 1,
      motoId: 1,
      dateTime: DateTime.now().add(const Duration(hours: 3)),
      serviceType: 'Cambio de Aceite',
      employeeId: 'Mech1',
      isConfirmed: true,
    ),
    AppointmentModel(
      id: 302,
      clientId: 2,
      motoId: 2,
      dateTime: DateTime.now().add(const Duration(days: 1, hours: 10)),
      serviceType: 'Revisión General',
      employeeId: 'Mech1',
      isConfirmed: false,
    ),
  ];

  // Palabra clave actual de búsqueda
  String _currentSearchTerm = '';

  // --------------------------------------------------------------------
  // BÚSQUEDA DE AGENDAMIENTOS
  // Filtra por tipo de servicio o por fecha (texto).
  // --------------------------------------------------------------------

  void searchAppointments(String term) {
    _currentSearchTerm = term.toLowerCase();
    _filterAppointments();
  }

  // Aplica el filtro de búsqueda a la lista completa
  void _filterAppointments() {
    if (_currentSearchTerm.isEmpty) {
      state = _allAppointments;
    } else {
      state = _allAppointments.where((a) {
        return a.serviceType.toLowerCase().contains(_currentSearchTerm) ||
            a.dateTime.toString().contains(_currentSearchTerm);
      }).toList();
    }
  }

  // --------------------------------------------------------------------
  // CRUD: REGISTRO, EDICIÓN Y CONFIRMACIÓN DE AGENDAMIENTOS
  // --------------------------------------------------------------------

  // Registrar un nuevo agendamiento
  Future<String> registerAppointment(
    int clientId,
    int motoId,
    DateTime dateTime,
    String serviceType,
    String employeeId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simula proceso

    final newId =
        _allAppointments.map((a) => a.id).reduce((a, b) => a > b ? a : b) + 1;

    final newAppointment = AppointmentModel(
      id: newId,
      clientId: clientId,
      motoId: motoId,
      dateTime: dateTime,
      serviceType: serviceType,
      employeeId: employeeId,
    );

    _allAppointments.add(newAppointment);
    _filterAppointments();

    return 'Agendamiento para "$serviceType" registrado el ${dateTime.toString().substring(0, 16)}.';
  }

  // Editar un agendamiento existente
  Future<String> editAppointment(
    AppointmentModel original,
    DateTime dateTime,
    String serviceType,
    String employeeId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simula proceso

    final index = _allAppointments.indexWhere((a) => a.id == original.id);
    if (index == -1) return 'Error: Agendamiento no encontrado.';

    _allAppointments[index] = original.copyWith(
      dateTime: dateTime,
      serviceType: serviceType,
      employeeId: employeeId,
    );

    _filterAppointments();
    return 'Agendamiento #${original.id} actualizado con éxito.';
  }

  // Cambiar estado de confirmación (confirmado / pendiente)
  Future<String> toggleConfirmation(
    AppointmentModel appointment,
    bool isConfirmed,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simula proceso

    final index = _allAppointments.indexWhere((a) => a.id == appointment.id);
    if (index == -1) return 'Error: Agendamiento no encontrado.';

    _allAppointments[index] =
        appointment.copyWith(isConfirmed: isConfirmed);

    _filterAppointments();
    return 'Agendamiento #${appointment.id} ${isConfirmed ? 'confirmado' : 'marcado como pendiente'}.';
  }
}
