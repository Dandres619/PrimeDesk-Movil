import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/providers/auth_notifier.dart';

/// Pantalla de inicio de sesión.
/// Permite autenticar a un usuario mediante email y contraseña.
/// Utiliza Riverpod para manejar el estado de autenticación.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Estado de autenticación (loading, error, usuario, etc.)
    final authState = ref.watch(authProvider);

    // Notifier responsable de ejecutar el login
    final authNotifier = ref.read(authProvider.notifier);

    // Controladores de los campos de texto
    final emailController = TextEditingController(text: 'admin@taller.com');
    final passwordController = TextEditingController(text: '12345');

    // Listener para mostrar errores provenientes del AuthState
    ref.listen<AuthState>(authProvider, (previous, current) {
      if (current.errorMessage case final msg? when msg.isNotEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Rafa Motos')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Campo de email del usuario
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 20),

              // Campo de contraseña del usuario
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 30),

              // Botón que dispara el proceso de login
              // Se deshabilita cuando el estado está cargando
              ElevatedButton(
                onPressed: authState.isLoading
                    ? null
                    : () {
                        authNotifier.login(
                          emailController.text.trim(),
                          passwordController.text.trim(),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: authState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Iniciar Sesión'),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
