import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/mock_data/mock_data.dart'; // Contiene lista mockUsers

/// Proveedor que gestiona únicamente los usuarios con rol "Cliente".
final clientProvider =
    StateNotifierProvider<ClientNotifier, List<UserModel>>((ref) {
  final initialClients = mockUsers.where((u) => u.role == 'Cliente').toList();
  return ClientNotifier(initialClients);
});

class ClientNotifier extends StateNotifier<List<UserModel>> {
  ClientNotifier(super.initialClients);

  /// Genera un nuevo ID basado en el ID más alto dentro de mockUsers.
  int _getNextId() {
    if (mockUsers.isEmpty) return 1;
    return mockUsers.map((u) => u.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  /// Obtiene el nombre de un cliente según su ID.
  /// (Usado desde otros notifiers como MotoNotifier).
  String getClientName(int clientId) {
    return mockUsers
        .firstWhere(
          (u) => u.id == clientId,
          orElse: () => const UserModel(
            id: 0,
            name: 'Desconocido',
            email: '',
            role: 'Cliente',
            telefono: '',
            token: '',
          ),
        )
        .name;
  }

  /// Registra un nuevo cliente validando duplicados por correo.
  Future<String> registerClient(
      String name, String email, String phone) async {
    // No se permite registrar un email ya utilizado por cualquier usuario
    if (mockUsers.any((u) => u.email.toLowerCase() == email.toLowerCase())) {
      return 'Error: Ya existe un usuario (cliente o empleado) con este correo electrónico.';
    }

    await Future.delayed(const Duration(milliseconds: 50));

    final newClient = UserModel(
      id: _getNextId(),
      name: name,
      email: email,
      role: 'Cliente',
      telefono: phone,
      token: 'token_cli_${_getNextId()}',
    );

    // Se agrega tanto al estado local como al mock global
    state = [...state, newClient];
    mockUsers.add(newClient);

    return 'Cliente "$name" registrado exitosamente.';
  }

  /// Actualiza nombre y teléfono de un cliente.
  Future<String> editClient(
      UserModel client, String newName, String newPhone) async {
    await Future.delayed(const Duration(milliseconds: 50));

    final updatedClient = UserModel(
      id: client.id,
      name: newName,
      email: client.email, // El email no se edita
      role: client.role,
      telefono: newPhone,
      token: client.token,
    );

    // Actualiza el estado local
    state = state.map((c) => c.id == client.id ? updatedClient : c).toList();

    // Actualiza también la lista mock global
    final index = mockUsers.indexWhere((u) => u.id == client.id);
    if (index != -1) {
      mockUsers[index] = updatedClient;
    }

    return 'Información del cliente actualizada exitosamente.';
  }

  /// Elimina un cliente del sistema (mock), sin validaciones adicionales.
  Future<String> deleteClient(int id) async {
    final clientToDelete = state.firstWhere((c) => c.id == id);

    // Aquí podría insertarse lógica adicional, por ejemplo:
    // evitar eliminar clientes con motos o ventas asociadas.

    await Future.delayed(const Duration(milliseconds: 50));

    // Se elimina del estado y del mock global
    state = state.where((c) => c.id != id).toList();
    mockUsers.removeWhere((u) => u.id == id);

    return 'Cliente "${clientToDelete.name}" eliminado correctamente.';
  }

  /// Realiza una búsqueda por nombre, email o teléfono.
  void searchClients(String query) {
    final allClients = mockUsers.where((u) => u.role == 'Cliente').toList();

    if (query.isEmpty) {
      state = allClients;
      return;
    }

    final lowerQuery = query.toLowerCase();

    final filteredClients = allClients.where((u) {
      return u.name.toLowerCase().contains(lowerQuery) ||
          u.email.toLowerCase().contains(lowerQuery) ||
          u.telefono.contains(lowerQuery);
    }).toList();

    state = filteredClients;
  }
}
