import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/sale_model.dart';

/// StateNotifier encargado de manejar el estado de las ventas de la aplicación.
/// Expone las ventas existentes y permite crear nuevas.
/// Además contiene mocks completos de productos, compras y pedidos.
class SaleNotifier extends StateNotifier<List<Venta>> {
  SaleNotifier() : super([]);

  /// Carga la lista inicial de ventas mock para mostrar datos desde el inicio.
  void cargarMock() {
    state = _mockVentas.toList();
  }

  // ---------------------------------------------------------------------------
  // MOCK DE COMPRAS
  // Cada elemento representa una "compra completa" compuesta por varios productos.
  // Aquí no se guardan ventas, sino compras independientes seleccionables.
  // ---------------------------------------------------------------------------
  final List<List<Compra>> comprasMock = [
    [
      Compra(producto: Producto(id: "p1", nombre: "Aceite 10W-40", precio: 1000), cantidad: 3),
      Compra(producto: Producto(id: "p2", nombre: "Lubricante Premium", precio: 1500), cantidad: 1),
    ],
    [
      Compra(producto: Producto(id: "p3", nombre: "Filtro de Aire Deportivo", precio: 2500), cantidad: 2),
    ],
    [
      Compra(producto: Producto(id: "p1", nombre: "Aceite 10W-40", precio: 1000), cantidad: 1),
      Compra(producto: Producto(id: "p2", nombre: "Lubricante Premium", precio: 1500), cantidad: 2),
      Compra(producto: Producto(id: "p3", nombre: "Filtro de Aire Deportivo", precio: 2500), cantidad: 1),
    ],
  ];

  /// Contador interno opcional para generar IDs incrementales si algún día se requiere.
  int _idCounter = 1;

  // ---------------------------------------------------------------------------
  // MOCK DE PRODUCTOS
  // Lista básica de productos disponibles. Se usa como referencia estática.
  // ---------------------------------------------------------------------------
  final List<Producto> productos = [
    Producto(id: "p1", nombre: "Aceite 10W-40", precio: 1000),
    Producto(id: "p2", nombre: "Lubricante Premium", precio: 1500),
    Producto(id: "p3", nombre: "Filtro de Aire Deportivo", precio: 2500),
  ];

  // ---------------------------------------------------------------------------
  // MOCK DE PEDIDOS DE SERVICIO
  // Cada venta debe estar asociada a un pedido, por eso se proveen algunos mock.
  // ---------------------------------------------------------------------------
  final List<PedidoServicio> pedidosServicio = [
    PedidoServicio(
      id: "ps1",
      cliente: Cliente(id: "c1", nombre: "Marcos Herrera"),
      moto: Motocicleta(id: "m1", modelo: "Kawasaki Ninja 300"),
    ),
    PedidoServicio(
      id: "ps2",
      cliente: Cliente(id: "c2", nombre: "Pedro Valdés"),
      moto: Motocicleta(id: "m2", modelo: "Yamaha MT-03"),
    ),
  ];

  // ---------------------------------------------------------------------------
  // CREAR UNA NUEVA VENTA
  //
  // Recibe un pedido asociado y la lista completa de compras seleccionadas.
  // Luego genera un nuevo objeto Venta y lo agrega al estado.
  // ---------------------------------------------------------------------------
  void crearVenta({
    required PedidoServicio pedido,
    required List<Compra> compras,
  }) {
    final nuevaVenta = Venta(
      id: "v${state.length + 1}",
      pedido: pedido,
      compras: compras,
    );

    /// Se genera un nuevo estado inmutable con la venta agregada al final.
    state = [...state, nuevaVenta];
  }
}

// -----------------------------------------------------------------------------
// MOCKS COMPLETOS DE VENTAS
// Contienen ejemplos reales de ventas ya registradas. Se utilizan como base
// para mostrar la tabla poblada al iniciar la aplicación.
// -----------------------------------------------------------------------------
final List<Venta> _mockVentas = [
  Venta(
    id: "v1",
    pedido: PedidoServicio(
      id: "ps1",
      cliente: Cliente(id: "c1", nombre: "Marcos Herrera"),
      moto: Motocicleta(id: "m1", modelo: "Kawasaki Ninja 300"),
    ),
    compras: [
      Compra(
        producto: Producto(id: "p1", nombre: "Aceite 10W-40", precio: 1000),
        cantidad: 2,
      ),
      Compra(
        producto: Producto(id: "p2", nombre: "Lubricante Premium", precio: 1500),
        cantidad: 1,
      ),
    ],
  ),

  Venta(
    id: "v2",
    pedido: PedidoServicio(
      id: "ps2",
      cliente: Cliente(id: "c2", nombre: "Pedro Valdés"),
      moto: Motocicleta(id: "m2", modelo: "Yamaha MT-03"),
    ),
    compras: [
      Compra(
        producto: Producto(id: "p3", nombre: "Filtro de Aire Deportivo", precio: 2500),
        cantidad: 1,
      ),
    ],
  ),

  Venta(
    id: "v3",
    pedido: PedidoServicio(
      id: "ps3",
      cliente: Cliente(id: "c3", nombre: "Diego Ramírez"),
      moto: Motocicleta(id: "m3", modelo: "Suzuki GSX-S750"),
    ),
    compras: [
      Compra(
        producto: Producto(id: "p1", nombre: "Aceite 10W-40", precio: 1000),
        cantidad: 3,
      ),
      Compra(
        producto: Producto(id: "p2", nombre: "Lubricante Premium", precio: 1500),
        cantidad: 2,
      ),
    ],
  ),

  Venta(
    id: "v4",
    pedido: PedidoServicio(
      id: "ps4",
      cliente: Cliente(id: "c4", nombre: "Andrés Molina"),
      moto: Motocicleta(id: "m4", modelo: "Honda CBR500R"),
    ),
    compras: [
      Compra(
        producto: Producto(id: "p3", nombre: "Filtro de Aire Deportivo", precio: 2500),
        cantidad: 2,
      ),
      Compra(
        producto: Producto(id: "p1", nombre: "Aceite 10W-40", precio: 1000),
        cantidad: 1,
      ),
    ],
  ),

  Venta(
    id: "v5",
    pedido: PedidoServicio(
      id: "ps5",
      cliente: Cliente(id: "c5", nombre: "Ricardo Soto"),
      moto: Motocicleta(id: "m5", modelo: "KTM Duke 390"),
    ),
    compras: [
      Compra(
        producto: Producto(id: "p2", nombre: "Lubricante Premium", precio: 1500),
        cantidad: 4,
      ),
    ],
  ),

  Venta(
    id: "v6",
    pedido: PedidoServicio(
      id: "ps6",
      cliente: Cliente(id: "c6", nombre: "Samuel Escobar"),
      moto: Motocicleta(id: "m6", modelo: "BMW G310R"),
    ),
    compras: [
      Compra(
        producto: Producto(id: "p1", nombre: "Aceite 10W-40", precio: 1000),
        cantidad: 1,
      ),
      Compra(
        producto: Producto(id: "p3", nombre: "Filtro de Aire Deportivo", precio: 2500),
        cantidad: 1,
      ),
    ],
  ),

  Venta(
    id: "v7",
    pedido: PedidoServicio(
      id: "ps7",
      cliente: Cliente(id: "c7", nombre: "Fabián Rivas"),
      moto: Motocicleta(id: "m7", modelo: "Ducati Monster 797"),
    ),
    compras: [
      Compra(
        producto: Producto(id: "p1", nombre: "Aceite 10W-40", precio: 1000),
        cantidad: 5,
      ),
    ],
  ),

  Venta(
    id: "v8",
    pedido: PedidoServicio(
      id: "ps8",
      cliente: Cliente(id: "c8", nombre: "Héctor Medina"),
      moto: Motocicleta(id: "m8", modelo: "Triumph Street Triple"),
    ),
    compras: [
      Compra(
        producto: Producto(id: "p2", nombre: "Lubricante Premium", precio: 1500),
        cantidad: 3,
      ),
      Compra(
        producto: Producto(id: "p1", nombre: "Aceite 10W-40", precio: 1000),
        cantidad: 1,
      ),
    ],
  ),
];

/// Provider global que expone el estado de las ventas.
/// Se inicializa cargando los mocks automáticamente.
final saleProvider = StateNotifierProvider<SaleNotifier, List<Venta>>((ref) {
  return SaleNotifier()..cargarMock();
});
