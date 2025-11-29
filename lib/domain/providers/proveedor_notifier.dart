import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/proveedor_model.dart';

/// Proveedor global para manejar la lista de proveedores.
/// Se inicializa con datos simulado para propósitos de prueba.
final proveedorProvider =
    StateNotifierProvider<ProveedorNotifier, List<ProveedorModel>>((ref) {
  return ProveedorNotifier([
    ProveedorModel(
        id: 101,
        nombre: 'Repuestos Rueda S.A.',
        contacto: 'Juan Pérez',
        telefono: '555-1001',
        email: 'rueda@repuestos.com',
        direccion: 'Calle 1'),
    ProveedorModel(
        id: 102,
        nombre: 'Aceites Motorizados Ltda.',
        contacto: 'Ana Gómez',
        telefono: '555-1002',
        email: 'motor@aceites.com',
        direccion: 'Avenida 2'),
  ]);
});

/// Notifier que administra la lista de proveedores:
/// - Búsqueda por nombre, contacto o teléfono
/// - Registro, edición y activación/inactivación (CRUD básico)
class ProveedorNotifier extends StateNotifier<List<ProveedorModel>> {
  ProveedorNotifier(super.state);

  /// Término actual de búsqueda
  String _currentSearchTerm = '';

  /// Lista interna completa de proveedores.
  /// Nota: No se recomienda sobrescribirla cada vez, por eso se declara mutable.
  /// Es el origen que se filtra para actualizar [state].
  final List<ProveedorModel> _fullList = [
    ProveedorModel(
        id: 101,
        nombre: 'Repuestos Rueda S.A.',
        contacto: 'Juan Pérez',
        telefono: '555-1001',
        email: 'rueda@repuestos.com',
        direccion: 'Calle 1',
        isActive: true),
    ProveedorModel(
        id: 102,
        nombre: 'Aceites Motorizados Ltda.',
        contacto: 'Ana Gómez',
        telefono: '555-1002',
        email: 'motor@aceites.com',
        direccion: 'Avenida 2',
        isActive: true),
    ProveedorModel(
        id: 103,
        nombre: 'Llantas Seguras',
        contacto: 'Carlos V.',
        telefono: '555-1003',
        email: 'seguras@llantas.com',
        direccion: 'Carrera 3',
        isActive: false),
  ];

  // --------------------------------------------------------------------------
  //                               BÚSQUEDA
  // --------------------------------------------------------------------------

  /// Actualiza el término de búsqueda y refresca el listado visible.
  void searchProveedores(String term) {
    _currentSearchTerm = term.toLowerCase();
    _applyFilters();
  }

  /// Aplica el filtro sobre la lista completa.
  /// Busca por nombre, contacto o teléfono.
  void _applyFilters() {
    if (_currentSearchTerm.isEmpty) {
      state = List.from(_fullList);
      return;
    }

    state = _fullList
        .where((p) =>
            p.nombre.toLowerCase().contains(_currentSearchTerm) ||
            p.contacto.toLowerCase().contains(_currentSearchTerm) ||
            p.telefono.contains(_currentSearchTerm))
        .toList();
  }

  // --------------------------------------------------------------------------
  //                                  CRUD
  // --------------------------------------------------------------------------

  /// HU_95 - Registrar proveedor
  /// Agrega un proveedor nuevo con ID incremental.
  Future<String> registerProveedor(String nombre, String contacto,
      String telefono, String email, String direccion) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulación API

    final newId =
        _fullList.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;

    final newProveedor = ProveedorModel(
      id: newId,
      nombre: nombre,
      contacto: contacto,
      telefono: telefono,
      email: email,
      direccion: direccion,
      isActive: true,
    );

    _fullList.add(newProveedor);
    _applyFilters();

    return 'Proveedor $nombre registrado con éxito.';
  }

  /// HU_97 - Editar proveedor
  /// Permite modificar datos básicos del proveedor.
  Future<String> editProveedor(ProveedorModel original, String nombre,
      String contacto, String telefono, String direccion) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _fullList.indexWhere((p) => p.id == original.id);
    if (index == -1) return 'Error: Proveedor no encontrado.';

    _fullList[index] = original.copyWith(
      nombre: nombre,
      contacto: contacto,
      telefono: telefono,
      direccion: direccion,
    );

    _applyFilters();
    return 'Proveedor $nombre actualizado con éxito.';
  }

  /// HU_98 - Activar/Inactivar proveedor
  Future<String> toggleStatus(ProveedorModel proveedor, bool isActive) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _fullList.indexWhere((p) => p.id == proveedor.id);
    if (index == -1) return 'Error: Proveedor no encontrado.';

    _fullList[index] = proveedor.copyWith(isActive: isActive);
    _applyFilters();

    return 'Proveedor ${proveedor.nombre} ${isActive ? 'activado' : 'inactivado'} con éxito.';
  }
}
