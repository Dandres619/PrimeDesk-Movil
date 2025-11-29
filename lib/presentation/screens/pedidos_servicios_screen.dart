import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/providers/service_order_notifier.dart';
import '../../data/models/service_order_model.dart';
import '../widgets/custom_app_bar.dart';

/// Pantalla que muestra la lista de órdenes de servicio registradas.
/// Permite visualizar estado, datos clave y actualizar el estado de cada orden.
class PedidosServiciosScreen extends ConsumerWidget {
  const PedidosServiciosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtiene la lista de órdenes y el notifier para realizar acciones (actualizar estado).
    final orders = ref.watch(serviceOrderProvider);
    final notifier = ref.read(serviceOrderProvider.notifier);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Pedidos de Servicio'),

      // Si no hay órdenes registradas, se muestra un mensaje informativo.
      body: orders.isEmpty
          ? const Center(child: Text('No hay órdenes de servicio registradas.'))
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final statusColor = _getStatusColor(order.status);

                return ListTile(
                  // Avatar que muestra el ID de la orden y usa color según estado.
                  leading: CircleAvatar(
                    backgroundColor: statusColor,
                    child: Text(
                      '${order.id}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),

                  // Datos principales de la orden: placa y cliente.
                  title: Text(
                    'Placa: ${order.motoPlaca} | Cliente: ${order.clientName}',
                  ),

                  // Información adicional: mecánico y descripción del trabajo.
                  subtitle: Text(
                    'Mecánico: ${order.mechanicName}\nDescripción: ${order.workDescription}',
                  ),

                  // Chip visual del estado de la orden.
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      order.status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Al tocar una orden, se abre un diálogo para cambiar su estado.
                  onTap: () => _showStatusDialog(context, notifier, order),
                );
              },
            ),

      // Botón flotante para registrar una nueva orden.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Simulando registrar nueva orden...'),
            ),
          );
        },
        label: const Text('Nueva Orden'),
        icon: const Icon(Icons.receipt_long),
      ),
    );
  }

  /// Devuelve un color asociado al estado de la orden para facilitar la lectura visual.
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pendiente':
        return Colors.orange;
      case 'En Progreso':
        return Colors.blue;
      case 'Finalizado':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  /// Muestra un diálogo que permite actualizar el estado de la orden seleccionada.
  /// Llama al notifier para persistir el cambio.
  void _showStatusDialog(
    BuildContext context,
    ServiceOrderNotifier notifier,
    ServiceOrderModel order,
  ) {
    String? newStatus = order.status;
    final List<String> statuses = ['Pendiente', 'En Progreso', 'Finalizado'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Actualizar Estado de Orden #${order.id}'),

        // StatefulBuilder mantiene el estado local del Dropdown dentro del diálogo.
        content: StatefulBuilder(
          builder: (context, setState) {
            return DropdownButton<String>(
              value: newStatus,
              items: statuses.map((String status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() => newStatus = newValue);
              },
            );
          },
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),

          // Guarda el nuevo estado y muestra un mensaje con el resultado.
          ElevatedButton(
            onPressed: () async {
              if (newStatus != null) {
                Navigator.pop(context);
                final result =
                    await notifier.updateStatus(order.id, newStatus!);
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(result)));
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
