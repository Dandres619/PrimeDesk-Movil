import 'package:flutter/material.dart';

/// Widget CustomAppBar: AppBar personalizada reutilizable en todo el proyecto
/// Implementa PreferredSizeWidget para usarse como AppBar en Scaffold
/// Proporciona un título centrado y soporte para acciones opcionales
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Título que se muestra en el centro del AppBar
  final String title;
  
  /// Lista opcional de widgets de acción (botones, iconos, etc.) en el lado derecho
  /// Permitimos acciones opcionales para botones en la AppBar (ej. botón "Agregar")
  final List<Widget>? actions;

  /// Implementamos PreferredSizeWidget para que pueda ser usado como AppBar en Scaffold
  /// Define el tamaño preferido del AppBar (altura estándar de toolbar)
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  /// Constructor del CustomAppBar
  /// [title] es requerido, [actions] es opcional
  const CustomAppBar({
    super.key,
    required this.title,
    this.actions, // Los actions pueden ser nulos si no se necesitan botones extra
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      /// Muestra el título del AppBar
      title: Text(title),
      /// Centra el título en todas las plataformas (iOS y Android)
      centerTitle: true,
      /// Estilo de color consistente en toda la aplicación
      backgroundColor: Colors.blue.shade700,
      /// Se pasan las acciones que la pantalla que lo llama requiera
      actions: actions,
    );
  }
}
