import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pantallas principales para flujo de autenticación
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/home_screen.dart';

/// Proveedor global que expone el estado de autenticación y sus acciones
import 'domain/providers/auth_notifier.dart';

/// Punto de entrada de la aplicación.
/// Se envuelve la app con [ProviderScope] para habilitar Riverpod
/// en todo el árbol de widgets.
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

/// Widget raíz de la aplicación.
/// Su responsabilidad es configurar el tema global y decidir qué pantalla
/// inicial mostrar según el estado de autenticación.
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// Observa el estado global de autenticación.
    /// Esto permite redibujar automáticamente cuando el usuario inicia/cierra sesión.
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Rafa Motos Gestión de Estados',
      debugShowCheckedModeBanner: false,

      /// Tema global de la aplicación.
      /// Aquí se definen colores base y densidad visual para uniformidad en la UI.
      theme: ThemeData(
        primarySwatch: Colors.red,
        primaryColor: Colors.redAccent,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.red,
        ),
      ),

      /// Navegación inicial basada en autenticación:
      ///  - Si el usuario está logueado → HomeScreen
      ///  - Si no → LoginScreen
      ///
      /// Esto evita usar rutas innecesarias para el flujo básico
      /// y simplifica la lógica inicial.
      home: authState.isAuthenticated
          ? const HomeScreen()
          : const LoginScreen(),
    );
  }
}
