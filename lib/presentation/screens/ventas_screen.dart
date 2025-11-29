import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/providers/sale_notifier.dart';
import '../../data/models/sale_model.dart';

/// Pantalla principal que muestra el listado de ventas usando Riverpod
class VentasScreen extends ConsumerStatefulWidget {
  const VentasScreen({super.key});

  @override
  ConsumerState<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends ConsumerState<VentasScreen> {
  /// Controla cuántas filas se muestran por página en la tabla
  int _rowsPerPage = 10;

  @override
  Widget build(BuildContext context) {
    /// Observa el estado reactivo de las ventas
    final ventas = ref.watch(saleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ventas", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 1,
      ),

      /// Botón para abrir el formulario de creación de una nueva venta
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openNuevaVentaDialog(),
        label: const Text("Nueva venta"),
        icon: const Icon(Icons.add),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

          /// Tabla paginada con las ventas registradas
          child: PaginatedDataTable(
            header: const Text(
              "Listado de Ventas",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            rowsPerPage: _rowsPerPage,
            onRowsPerPageChanged: (v) {
              if (v != null) setState(() => _rowsPerPage = v);
            },
            columns: const [
              DataColumn(label: Text("Cliente")),
              DataColumn(label: Text("Moto")),
              DataColumn(label: Text("Pedido Servicio")),
              DataColumn(label: Text("Total")),
            ],
            source: _VentasTableSource(ventas),
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────────
  // DIÁLOGO: CREACIÓN DE UNA NUEVA VENTA
  // ────────────────────────────────────────────────────────────────────────────────

  /// Abre un diálogo modal para registrar una nueva venta
  void _openNuevaVentaDialog() {
    final notifier = ref.read(saleProvider.notifier);

    /// Estado local dentro del diálogo
    PedidoServicio? pedidoSeleccionado;

    /// Se guardan solo los índices de las compras seleccionadas
    List<int> comprasSeleccionadas = [];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Nueva Venta",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          /// StatefulBuilder permite actualizar solo el contenido interno del diálogo
          content: StatefulBuilder(builder: (context, setSB) {
            /// Cálculo acumulado del total según las compras seleccionadas
            double totalVenta = comprasSeleccionadas.fold(0, (s, idx) {
              return s + notifier.comprasMock[idx].fold(0, (x, c) => x + c.subtotal);
            });

            return SizedBox(
              width: MediaQuery.of(context).size.width * 0.75,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // ───────────────────── SELECCIÓN DEL PEDIDO DE SERVICIO ─────────────────────
                    DropdownButtonFormField<PedidoServicio>(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: "Pedido de Servicio",
                        border: OutlineInputBorder(),
                      ),
                      items: notifier.pedidosServicio
                          .map((ps) => DropdownMenuItem(
                                value: ps,
                                child: Text("${ps.id} - ${ps.cliente.nombre}"),
                              ))
                          .toList(),
                      onChanged: (v) => setSB(() => pedidoSeleccionado = v),
                    ),

                    const SizedBox(height: 20),

                    // ───────────────────── LISTA DE COMPRAS DISPONIBLES ─────────────────────
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Selecciona compras:",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 10),

                          /// Listado desplazable de todas las compras mock
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              itemCount: notifier.comprasMock.length,
                              itemBuilder: (context, i) {
                                final selected = comprasSeleccionadas.contains(i);

                                return CheckboxListTile(
                                  title: Text("Compra #${i + 1}"),
                                  subtitle: Text(
                                    "${notifier.comprasMock[i].length} productos",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  value: selected,
                                  onChanged: (v) {
                                    setSB(() {
                                      v == true
                                          ? comprasSeleccionadas.add(i)
                                          : comprasSeleccionadas.remove(i);
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ───────────────────── RESUMEN DETALLADO DE COMPRAS ─────────────────────
                    if (comprasSeleccionadas.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Resumen de compras:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),

                            /// Muestra el detalle de productos por compra seleccionada
                            SizedBox(
                              height: 250,
                              child: ListView.builder(
                                itemCount: comprasSeleccionadas.length,
                                itemBuilder: (context, i) {
                                  final idx = comprasSeleccionadas[i];
                                  final lista = notifier.comprasMock[idx];

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: lista.map((c) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 2),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("${c.producto.nombre} x${c.cantidad}"),
                                              Text("\$${c.subtotal.toStringAsFixed(2)}"),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 20),

                    // ───────────────────── TOTAL ACUMULADO ─────────────────────
                    Text(
                      "TOTAL: \$${totalVenta.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),

            /// Guarda la venta si los campos requeridos están completos
            FilledButton(
              onPressed: () {
                if (pedidoSeleccionado != null && comprasSeleccionadas.isNotEmpty) {
                  /// Combina todas las listas de compras seleccionadas en una sola
                  final todas = comprasSeleccionadas
                      .map((i) => notifier.comprasMock[i])
                      .expand((x) => x)
                      .toList();

                  notifier.crearVenta(
                    pedido: pedidoSeleccionado!,
                    compras: todas,
                  );

                  Navigator.pop(context);
                }
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FUENTE DE DATOS PARA LA TABLA PAGINADA DE VENTAS
// ─────────────────────────────────────────────────────────────────────────────

/// Provee las filas necesarias para el PaginatedDataTable
class _VentasTableSource extends DataTableSource {
  final List<Venta> ventas;
  _VentasTableSource(this.ventas);

  @override
  DataRow? getRow(int index) {
    if (index >= ventas.length) return null;
    final v = ventas[index];

    return DataRow(cells: [
      DataCell(Text(v.pedido.cliente.nombre)),
      DataCell(Text(v.pedido.moto.modelo)),
      DataCell(Text(v.pedido.id)),
      DataCell(Text("\$${v.total.toStringAsFixed(2)}")),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => ventas.length;

  @override
  int get selectedRowCount => 0;
}
