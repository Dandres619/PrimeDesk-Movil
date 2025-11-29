import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/mock_data/mock_data.dart';
import '../../data/mock_data/mock_roles_schedules.dart';

/// Provider que gestiona la lista de empleados.
/// Se inicializa excluyendo a los usuarios cuyo rol sea "Cliente".
final employeeProvider =
    StateNotifierProvider<EmployeeNotifier, List<UserModel>>((ref) {
  final initialEmployees = mockUsers.where((u) => u.role != 'Cliente').toList();
  return EmployeeNotifier(initialEmployees);
});

/// Provider que expone roles y horarios disponibles.
/// Se maneja como datos estáticos para selección en formularios.
final roleScheduleProvider = Provider((ref) => {
      'roles': availableRoles,
      'schedules': availableSchedules,
    });

/// Notifier encargado de manejar empleados, búsqueda y operaciones CRUD.
class EmployeeNotifier extends StateNotifier<List<UserModel>> {
  EmployeeNotifier(super.initialState);

  /// Término actual de búsqueda.
  String _currentSearchTerm = '';

  /// Lista completa de empleados (sin clientes).  
  /// Se toma del mock global para simular una fuente persistente.
  List<UserModel> get _allEmployees =>
      mockUsers.where((u) => u.role != 'Cliente').toList();

  /// Actualiza el término de búsqueda y filtra empleados.
  void searchEmployees(String term) {
    _currentSearchTerm = term.toLowerCase();
    _filterEmployees();
  }

  /// Aplica el filtro actual en función del término de búsqueda.
  void _filterEmployees() {
    if (_currentSearchTerm.isEmpty) {
      state = _allEmployees;
    } else {
      state = _allEmployees
          .where((u) =>
              u.name.toLowerCase().contains(_currentSearchTerm) ||
              u.email.toLowerCase().contains(_currentSearchTerm) ||
              u.role.toLowerCase().contains(_currentSearchTerm))
          .toList();
    }
  }

  // ------------------------------------------------------------
  //                  OPERACIONES CRUD EMPLEADOS
  // ------------------------------------------------------------

  /// Registra un nuevo empleado en la lista mock.
  /// Retorna un mensaje indicando el resultado.
  Future<String> registerEmployee(
    String name,
    String email,
    String role,
    String telefono,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // ID generado en base al mayor existente.
    final newId = mockUsers.isNotEmpty
        ? mockUsers.map((u) => u.id).reduce((a, b) => a > b ? a : b) + 1
        : 1;

    final newEmployee = UserModel(
      id: newId,
      name: name,
      email: email,
      telefono: telefono,
      role: role,
      token: '',
    );

    mockUsers.add(newEmployee);
    _filterEmployees();
    return 'Empleado $name registrado como $role con éxito.';
  }

  /// Edita un empleado existente, reemplazando sus datos.
  Future<String> editEmployee(
    UserModel original,
    String name,
    String role,
    String telefono,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _allEmployees.indexWhere((u) => u.id == original.id);
    if (index == -1) return 'Error: Empleado no encontrado.';

    final updatedEmployee = original.copyWith(
      name: name,
      role: role,
      telefono: telefono,
    );

    // Actualización del mock global
    final globalIndex = mockUsers.indexWhere((u) => u.id == original.id);
    if (globalIndex != -1) {
      mockUsers[globalIndex] = updatedEmployee;
    }

    _filterEmployees();
    return 'Empleado $name actualizado con éxito.';
  }

  /// Activa o inactiva un empleado simulando la eliminación del mock.
  Future<String> toggleStatus(UserModel employee, bool isActive) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final globalIndex = mockUsers.indexWhere((u) => u.id == employee.id);
    if (globalIndex != -1) {
      mockUsers.removeAt(globalIndex);
    }

    _filterEmployees();
    return 'Empleado ${employee.name} ${isActive ? 'activado' : 'inactivado'} con éxito.';
  }

  /// Obtiene un empleado por ID. Retorna `null` si no existe.
  UserModel? getEmployeeById(int id) {
    try {
      return _allEmployees.firstWhere((employee) => employee.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Fuerza una recarga del estado en base a los datos mock.
  void reloadEmployees() {
    _filterEmployees();
  }
}
