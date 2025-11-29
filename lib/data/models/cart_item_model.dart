import 'product_model.dart';

/// Modelo que representa un artículo dentro del carrito de compras
/// Asocia un producto con la cantidad deseada por el cliente
class CartItemModel {
  /// Producto incluido en el carrito
  final ProductModel product;
  
  /// Cantidad de unidades del producto en el carrito
  int quantity;

  /// Constructor del modelo CartItemModel
  /// [product] es requerido, [quantity] por defecto es 1
  CartItemModel({required this.product, this.quantity = 1});
}
