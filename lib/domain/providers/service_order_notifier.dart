import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock_data/mock_data.dart';
import '../../data/models/service_order_model.dart';

/// Provider que expone la lista de órdenes de servicio
final serviceOrderProvider =
    StateNotifierProvider<ServiceOrderNotifier, List<ServiceOrderModel>>((ref) {
  return ServiceOrderNotifier();
});

/// Notifier encargado de gestionar las órdenes de servicio
class ServiceOrderNotifier extends StateNotifier<List<ServiceOrderModel>> {
  /// Carga inicial usando datos mock
  ServiceOrderNotifier() : super(mockServiceOrders);

  /// Actualiza el estado de una orden de servicio por su ID
  ///
  /// Retorna un mensaje indicando el nuevo estado.
  Future<String> updateStatus(int id, String newStatus) async {
    // Pequeño delay para simular una llamada asíncrona
    await Future.delayed(const Duration(milliseconds: 50));

    // Reemplaza solo la orden correspondiente manteniendo la inmutabilidad
    state = state.map((order) {
      if (order.id == id) {
        return ServiceOrderModel(
          id: order.id,
          motoId: order.motoId,
          clientName: order.clientName,
          motoPlaca: order.motoPlaca,
          mechanicName: order.mechanicName,
          status: newStatus,
          entryDate: order.entryDate,
          workDescription: order.workDescription,
        );
      }
      return order;
    }).toList();

    return 'Estado de la orden #$id actualizado a "$newStatus".';
  }
}
