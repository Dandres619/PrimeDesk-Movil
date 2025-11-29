import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/providers/auth_notifier.dart';

// Importación de pantallas de cada módulo del sistema.
import 'agendamientos_screen.dart';
import 'categorias_productos_screen.dart';
import 'clientes_screen.dart';
import 'compras_screen.dart';
import 'horarios_screen.dart';
import 'motos_screen.dart';
import 'pedidos_servicios_screen.dart';
import 'productos_screen.dart';
import 'proveedores_screen.dart';
import 'roles_screen.dart';
import 'usuarios_screen.dart';
import 'ventas_screen.dart';

/// Definición global de módulos disponibles en el panel.
/// Cada módulo contiene:
/// - [key]: identificador interno
/// - [title]: texto mostrado en UI
/// - [icon]: icono representativo
/// - [screen]: pantalla asociada
final List<Map<String, dynamic>> modules = [
  {
    'key': 'dashboard',
    'title': 'Dashboard',
    'icon': Icons.dashboard,
    'screen': const _DashboardContent()
  },
  {
    'key': 'clientes',
    'title': 'Clientes',
    'icon': Icons.person,
    'screen': const ClientesScreen()
  },
  {
    'key': 'motos',
    'title': 'Motos',
    'icon': Icons.two_wheeler,
    'screen': const MotosScreen()
  },
  {
    'key': 'ventas',
    'title': 'Ventas',
    'icon': Icons.monetization_on,
    'screen': const VentasScreen()
  },
  {
    'key': 'pedidos',
    'title': 'Pedidos Servicios',
    'icon': Icons.build,
    'screen': const PedidosServiciosScreen()
  },
  {
    'key': 'productos',
    'title': 'Productos',
    'icon': Icons.category,
    'screen': const ProductosScreen()
  },
  {
    'key': 'categorias',
    'title': 'Categorías',
    'icon': Icons.label,
    'screen': const CategoriasProductosScreen()
  },
  {
    'key': 'compras',
    'title': 'Compras',
    'icon': Icons.shopping_cart,
    'screen': const ComprasScreen()
  },
  {
    'key': 'proveedores',
    'title': 'Proveedores',
    'icon': Icons.local_shipping,
    'screen': const ProveedoresScreen()
  },
  {
    'key': 'usuarios',
    'title': 'Usuarios',
    'icon': Icons.people,
    'screen': const UsuariosScreen()
  },
  {
    'key': 'roles',
    'title': 'Roles',
    'icon': Icons.security,
    'screen': const RolesScreen()
  },
  {
    'key': 'horarios',
    'title': 'Horarios',
    'icon': Icons.access_time,
    'screen': const HorariosScreen()
  },
  {
    'key': 'agendamientos',
    'title': 'Agendamientos',
    'icon': Icons.calendar_month,
    'screen': const AgendamientosScreen()
  },
];

/// Helper general para asegurar que un widget ocupe el ancho completo disponible.
Widget _fullWidth(BoxConstraints constraints, Widget child) {
  return SizedBox(width: constraints.maxWidth, child: child);
}

/// Provider de estado para controlar la pantalla/módulo actual.
/// Su valor es la 'key' del módulo seleccionado.
final currentScreenKeyProvider = StateProvider<String>((ref) => 'dashboard');

/// Retorna la lista de módulos permitidos para un rol específico.
///
/// Roles soportados:
/// - Administrador → acceso total
/// - Mecánico → acceso restringido
/// - Cliente → acceso muy limitado
///
/// Si no hay rol (usuario no autenticado), retorna una lista vacía.
List<String> _allowedKeysForRole(String? role) {
  if (role == null) return [];

  final r = role.toLowerCase();

  if (r == 'administrador' || r == 'admin') {
    return modules.map((m) => m['key'] as String).toList();
  } else if (r == 'mecánico' || r == 'mecanico') {
    return modules
        .where((m) => !['proveedores', 'roles', 'dashboard'].contains(m['key']))
        .map((m) => m['key'] as String)
        .toList();
  } else if (r == 'cliente') {
    return ['agendamientos', 'motos', 'ventas', 'pedidos'];
  }

  return [];
}

/// Pantalla principal del sistema.
/// Administra la navegación dinámica según el rol del usuario.
///
/// - Muestra un Drawer con módulos filtrados.
/// - Cambia el contenido central usando Riverpod.
/// - Incluye control automático cuando el usuario intenta acceder a pantallas no permitidas.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final authNotifier = ref.read(authProvider.notifier);

    /// Clave de la pantalla actual seleccionada.
    final currentKey = ref.watch(currentScreenKeyProvider);

    /// Filtrado de módulos según el rol.
    final allowedKeys = _allowedKeysForRole(user?.role);

    /// Si el usuario seleccionó una pantalla no permitida,
    /// se redirige automáticamente a la primera válida.
    String effectiveKey = currentKey;
    if (allowedKeys.isNotEmpty && !allowedKeys.contains(currentKey)) {
      effectiveKey = allowedKeys.first;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(currentScreenKeyProvider.notifier).state = effectiveKey;
      });
    }

    /// Obtiene los datos del módulo activo.
    final currentModule = modules.firstWhere(
      (m) => m['key'] == effectiveKey,
      orElse: () => modules.first,
    );

    final currentTitle = currentModule['title'] as String;
    final currentScreen = currentModule['screen'] as Widget;

    return Scaffold(
      /// AppBar dinámico basado en el módulo seleccionado.
      appBar: AppBar(
        title: Text(currentTitle),
        backgroundColor: Colors.blue.shade700,
        actions: [
          /// Indicador del rol del usuario logueado.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Center(child: Text('Rol: ${user?.role ?? 'N/A'}')),
          ),

          /// Cerrar sesión.
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: authNotifier.logout,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),

      /// Drawer con los módulos permitidos según el rol.
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            /// Encabezado del usuario.
            UserAccountsDrawerHeader(
              accountName: Text(user?.name ?? 'Usuario'),
              accountEmail: Text(user?.email ?? 'Panel Administrativo'),
              currentAccountPicture:
                  const CircleAvatar(child: Icon(Icons.verified_user)),
              decoration: BoxDecoration(color: Colors.blue.shade700),
            ),

            /// Listado dinámico de módulos permitidos.
            ...modules
                .where((module) =>
                    allowedKeys.isNotEmpty &&
                    allowedKeys.contains(module['key']))
                .map((module) => ListTile(
                      selected: module['key'] == effectiveKey,
                      leading: Icon(module['icon'] as IconData),
                      title: Text(module['title']),
                      onTap: () {
                        ref.read(currentScreenKeyProvider.notifier).state =
                            module['key'] as String;
                        Navigator.pop(context);
                      },
                    )),

            const Divider(),

            /// Opción de cierre de sesión.
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text('Cerrar sesión',
                  style: TextStyle(color: Colors.red)),
              onTap: authNotifier.logout,
            ),
          ],
        ),
      ),

      /// Render dinámico de la pantalla seleccionada.
      body: SafeArea(child: currentScreen),
    );
  }
}

/// Contenido visual principal del Dashboard.
/// Se muestra solo a roles autorizados.
///
/// Contiene:
/// - Estadísticas generales del sistema
/// - Gráfico simple de ingresos semanales
/// - Información de resumen
class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  /// Datos ficticios usados solo para representación visual.
  Map<String, dynamic> get _mockStats => {
        'clientes': 324,
        'motosRegistradas': 128,
        'ventasHoy': 21,
        'ingresosMes': 15420,
        'citasPendientes': 9,
        'mecanicosActivos': 6,
        'ultimoMesPorDia': [1200, 900, 1500, 1800, 2100, 1600, 1420]
      };

  @override
  Widget build(BuildContext context) {
    final stats = _mockStats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Encabezado principal del dashboard.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenido, ${_getUserName(context) ?? 'administrador'}',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Resumen del rendimiento — datos ficticios',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          /// Tarjetas estadísticas responsivas.
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _fullWidth(
                      constraints,
                      _StatCard(
                        title: 'Clientes',
                        value: '${stats['clientes']}',
                        color: Colors.indigo,
                        icon: Icons.people_outline,
                        subtitle: 'Totales registrados',
                      )),
                  _fullWidth(
                      constraints,
                      _StatCard(
                        title: 'Motos',
                        value: '${stats['motosRegistradas']}',
                        color: Colors.teal,
                        icon: Icons.two_wheeler,
                        subtitle: 'Vehículos en inventario',
                      )),
                  _fullWidth(
                      constraints,
                      _StatCard(
                        title: 'Ventas hoy',
                        value: '${stats['ventasHoy']}',
                        color: Colors.deepOrange,
                        icon: Icons.point_of_sale,
                        subtitle: 'Transacciones',
                      )),
                  _fullWidth(
                      constraints,
                      _StatCard(
                        title: 'Ingresos (mes)',
                        value: '\$${stats['ingresosMes']}',
                        color: Colors.green,
                        icon: Icons.monetization_on_outlined,
                        subtitle: 'Aprox. último mes',
                      )),
                  _fullWidth(
                      constraints,
                      _StatCard(
                        title: 'Citas',
                        value: '${stats['citasPendientes']}',
                        color: Colors.purple,
                        icon: Icons.calendar_month_outlined,
                        subtitle: 'Pendientes por asignar',
                      )),
                  _fullWidth(
                      constraints,
                      _StatCard(
                        title: 'Mecánicos',
                        value: '${stats['mecanicosActivos']}',
                        color: Colors.blueGrey,
                        icon: Icons.build_circle_outlined,
                        subtitle: 'Activos ahora',
                      )),
                ],
              );
            },
          ),

          const SizedBox(height: 22),

          /// Gráfico de barras básico.
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ingresos últimos 7 días',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 150,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: () {
                        final values =
                            List<int>.from(stats['ultimoMesPorDia'] as List);
                        final max =
                            values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b);

                        return List.generate(values.length, (i) {
                          final val = values[i];
                          final heightFactor = max == 0 ? 0.05 : val / max;

                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text('\$$val', style: const TextStyle(fontSize: 11)),
                                  const SizedBox(height: 6),
                                  Container(
                                    height: (heightFactor * 60).clamp(8, 60),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade400,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'][i],
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                      }(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Actividad esperada y tendencias',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  /// Recupera el nombre del usuario desde el ProviderScope.
  /// Se usa en el encabezado del Dashboard.
  String? _getUserName(BuildContext context) {
    try {
      final container = ProviderScope.containerOf(context);
      final user = container.read(authProvider).user;
      return user?.name;
    } catch (_) {
      return null;
    }
  }
}

/// Tarjeta visual para mostrar una estadística.
/// Usada en el Dashboard para métricas resumidas.
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.12),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(subtitle!,
                          style: Theme.of(context).textTheme.bodySmall),
                    ]
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
