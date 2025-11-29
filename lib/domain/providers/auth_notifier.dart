import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';

/// Provider encargado de gestionar el estado de autenticación.
/// Maneja inicio de sesión, cierre de sesión y persistencia del usuario.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// Representa el estado actual de autenticación dentro de la aplicación.
/// Contiene información del usuario, errores y estados de carga.
class AuthState {
  /// Indica si hay un usuario autenticado.
  final bool isAuthenticated;

  /// Usuario actualmente autenticado (null si no hay sesión activa).
  final UserModel? user;

  /// Mensaje de error generado durante un intento de inicio de sesión.
  final String? errorMessage;

  /// Indica si se está procesando un intento de login.
  final bool isLoading;

  /// Constructor del estado de autenticación.
  AuthState({
    this.isAuthenticated = false,
    this.user,
    this.errorMessage,
    this.isLoading = false,
  });
}

/// Controlador que maneja toda la lógica de autenticación.
/// Implementa las acciones de login y logout, actualizando el estado.
class AuthNotifier extends StateNotifier<AuthState> {
  /// Inicializa el estado en no autenticado.
  AuthNotifier() : super(AuthState());

  /// Simula un inicio de sesión validando credenciales y roles.
  /// Actualiza el estado según el resultado.
  Future<void> login(String email, String password) async {
    state = AuthState(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 700)); // Simulación backend

    try {
      // --- Login de administrador ---
      if (email == 'admin@taller.com' && password == '12345') {
        final mockUser = UserModel(
          id: 1,
          name: 'Admin Taller',
          email: email,
          role: 'Administrador',
          telefono: '3001234567',
          token: 'token_admin',
        );
        state = AuthState(isAuthenticated: true, user: mockUser);
        return;
      }

      // --- Login de cliente ---
      if (email == 'cliente@taller.com' && password == '12345') {
        final mockUser = UserModel(
          id: 2,
          name: 'Cliente Registrado',
          email: email,
          role: 'Cliente',
          telefono: '3109876543',
          token: 'token_cliente',
        );
        state = AuthState(isAuthenticated: true, user: mockUser);
        return;
      }

      // --- Login de mecánico ---
      if (email == 'mecanico@taller.com' && password == '12345') {
        final mockUser = UserModel(
          id: 3,
          name: 'Mecánico del Taller',
          email: email,
          role: 'Mecanico',
          telefono: '3205558899',
          token: 'token_mecanico',
        );
        state = AuthState(isAuthenticated: true, user: mockUser);
        return;
      }

      // Si ninguna credencial coincide → error
      state = AuthState(
        errorMessage:
            'Credenciales inválidas. Usuario o contraseña incorrectos.',
      );
    } catch (e) {
      // Error genérico de conexión o procesamiento
      state = AuthState(errorMessage: 'Error de conexión.');
    }
  }

  /// Cierra sesión restableciendo el estado de autenticación.
  void logout() {
    state = AuthState();
  }
}
