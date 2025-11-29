import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/moto_model.dart';
import '../../data/models/user_model.dart';
import '../../data/mock_data/mock_data.dart';

/// Provider encargado de gestionar las motos registradas.
/// El estado inicial contiene únicamente motos activas.
final motoProvider =
    StateNotifierProvider<MotoNotifier, List<MotoModel>>((ref) {
  return MotoNotifier();
});

class MotoNotifier extends StateNotifier<List<MotoModel>> {
  MotoNotifier()
      : super(
          mockMotos.where((m) => m.isActive).toList(),
        );

  /// Genera un nuevo ID incremental basado en la lista global mockMotos.
  int _getNextId() {
    if (mockMotos.isEmpty) return 1;
    return mockMotos.map((m) => m.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  /// Obtiene el nombre del cliente según su ID.
  String _getClientName(int clientId) {
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

  /// Registra una nueva moto validando duplicados por placa.
  Future<String> registerMoto(
    int clientId,
    String placa,
    String marca,
    String modelo,
    int anio,
    String color,
    String vin,
  ) async {
    // No se permite registrar placas repetidas
    if (mockMotos.any((m) => m.placa.toLowerCase() == placa.toLowerCase())) {
      return 'Error: Ya existe una moto registrada con la placa "$placa".';
    }

    await Future.delayed(const Duration(milliseconds: 50));

    final newMoto = MotoModel(
      id: _getNextId(),
      clientId: clientId,
      placa: placa,
      marca: marca,
      modelo: modelo,
      anio: anio,
      color: color,
      vin: vin,
      isActive: true,
    );

    // Se guarda en los datos globales (mock) y se actualiza el estado
    mockMotos.add(newMoto);
    state = mockMotos.where((m) => m.isActive).toList();

    return 'Moto con placa "$placa" registrada exitosamente al cliente ${_getClientName(clientId)}.';
  }

  /// Actualiza los datos principales de una moto.
  Future<String> editMoto(
    MotoModel moto,
    String newMarca,
    String newModelo,
    int newAnio,
    String newColor,
  ) async {
    await Future.delayed(const Duration(milliseconds: 50));

    final updatedMoto = MotoModel(
      id: moto.id,
      clientId: moto.clientId,
      placa: moto.placa, // La placa permanece igual
      marca: newMarca,
      modelo: newModelo,
      anio: newAnio,
      color: newColor,
      vin: moto.vin,
      isActive: moto.isActive,
    );

    // Actualiza en mock global
    final index = mockMotos.indexWhere((m) => m.id == moto.id);
    if (index != -1) {
      mockMotos[index] = updatedMoto;
    }

    // Actualiza en estado local
    state = state.map((m) => m.id == moto.id ? updatedMoto : m).toList();

    return 'Moto ${moto.placa} actualizada correctamente.';
  }

  /// Busca motos activas por placa o VIN.
  void searchMotos(String query) {
    if (query.isEmpty) {
      state = mockMotos.where((m) => m.isActive).toList();
      return;
    }

    final lowerQuery = query.toLowerCase();

    final filteredMotos = mockMotos.where((m) {
      return m.isActive &&
          (m.placa.toLowerCase().contains(lowerQuery) ||
           m.vin.toLowerCase().contains(lowerQuery));
    }).toList();

    state = filteredMotos;
  }

  /// Obtiene una moto específica según su ID.
  MotoModel? getMoto(int motoId) {
    try {
      return state.firstWhere((moto) => moto.id == motoId);
    } catch (_) {
      return null;
    }
  }

  /// Obtiene todas las motos activas pertenecientes a un cliente.
  List<MotoModel> getMotosByClientId(int clientId) {
    return state.where((moto) => moto.clientId == clientId).toList();
  }

  /// Recarga el estado mostrando únicamente motos activas
  /// desde la lista mock global.
  void reloadMotos() {
    state = mockMotos.where((m) => m.isActive).toList();
  }
}
