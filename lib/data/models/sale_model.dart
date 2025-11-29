// ---------------------------
// MODELOS SIMPLES (SOLO MOCKS)
// ---------------------------

/// Representa un cliente dentro del sistema.
/// Incluye únicamente información básica necesaria para los mocks.
class Cliente {
  final String id;        // Identificador único del cliente
  final String nombre;    // Nombre completo del cliente

  Cliente({required this.id, required this.nombre});
}

/// Modelo que describe una motocicleta asociada a un pedido.
/// Contiene datos esenciales únicamente para el mock.
class Motocicleta {
  final String id;        // Identificador único de la motocicleta
  final String modelo;    // Modelo o descripción de la moto

  Motocicleta({required this.id, required this.modelo});
}

/// Representa un pedido de servicio realizado por un cliente.
/// Incluye la referencia al cliente y la motocicleta involucrada.
class PedidoServicio {
  final String id;              // Identificador único del pedido
  final Cliente cliente;        // Cliente que solicita el servicio
  final Motocicleta moto;       // Motocicleta asociada al pedido

  PedidoServicio({
    required this.id,
    required this.cliente,
    required this.moto,
  });
}

/// Modelo de producto disponible para compras.
/// Cada producto posee un valor y un nombre descriptivo.
class Producto {
  final String id;          // Identificador único del producto
  final String nombre;      // Nombre descriptivo del producto
  final double precio;      // Precio unitario del producto

  Producto({
    required this.id,
    required this.nombre,
    required this.precio,
  });
}

/// Representa una compra individual dentro de una venta.
/// Contiene el producto seleccionado y la cantidad adquirida.
class Compra {
  final Producto producto;   // Producto adquirido
  final int cantidad;        // Cantidad comprada del producto

  Compra({required this.producto, required this.cantidad});

  /// Calcula el subtotal correspondiente al producto multiplicado por la cantidad.
  double get subtotal => producto.precio * cantidad;
}

/// Modelo principal que representa una venta.
/// Incluye el pedido de servicio y el conjunto de compras asociadas.
class Venta {
  final String id;                // Identificador único de la venta
  final PedidoServicio pedido;    // Pedido de servicio vinculado
  final List<Compra> compras;     // Lista de compras incluidas en la venta

  Venta({
    required this.id,
    required this.pedido,
    required this.compras,
  });

  /// Suma total de la venta considerando los subtotales de cada compra.
  double get total =>
      compras.fold(0, (sum, compra) => sum + compra.subtotal);
}
