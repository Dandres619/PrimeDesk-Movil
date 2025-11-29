import 'package:flutter/material.dart';

/// --- Modelo de datos para Usuarios ---
class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final bool isEnabled;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isEnabled,
  });
}

/// Lista de usuarios simulada para pruebas y demostración
final List<User> mockUsers = [
  User(
      id: 101,
      name: 'Juan Pérez',
      email: 'juan.perez@admin.com',
      role: 'Administrador',
      isEnabled: true),
  User(
      id: 102,
      name: 'María García',
      email: 'maria.g@mecanico.com',
      role: 'Mecánico',
      isEnabled: true),
  User(
      id: 103,
      name: 'Carlos López',
      email: 'carlos.l@mecanico.com',
      role: 'Mecánico',
      isEnabled: true),
  User(
      id: 104,
      name: 'Ana Rojas',
      email: 'ana.r@cliente.com',
      role: 'Cliente',
      isEnabled: false),
  User(
      id: 105,
      name: 'Pedro Torres',
      email: 'pedro.t@cliente.com',
      role: 'Cliente',
      isEnabled: true),
  User(
      id: 106,
      name: 'Elena Soto',
      email: 'elena.s@admin.com',
      role: 'Administrador',
      isEnabled: true),
];

/// --- Pantalla principal para gestión de usuarios ---
class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  /// Texto actual ingresado en el campo de búsqueda
  String _searchQuery = '';

  /// Lista filtrada según coincidencias de nombre, email o rol
  List<User> _filteredUsers = mockUsers;

  @override
  void initState() {
    super.initState();
    _filterUsers();
  }

  /// Filtra los usuarios según el texto ingresado
  void _filterUsers() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _filteredUsers = mockUsers;
      } else {
        final query = _searchQuery.toLowerCase();
        _filteredUsers = mockUsers.where((user) {
          return user.name.toLowerCase().contains(query) ||
              user.email.toLowerCase().contains(query) ||
              user.role.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  /// Muestra un formulario para crear o editar un usuario
  /// Si [user] es null → creación, de lo contrario → edición
  void _showUserFormDialog([User? user]) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              user == null ? 'Nuevo Usuario' : 'Editar Usuario: ${user.name}'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                /// Campo para nombre completo
                TextFormField(
                  initialValue: user?.name,
                  decoration:
                      const InputDecoration(labelText: 'Nombre Completo'),
                ),

                /// Campo para correo electrónico
                TextFormField(
                  initialValue: user?.email,
                  decoration:
                      const InputDecoration(labelText: 'Correo Electrónico'),
                ),

                /// Selector de rol del usuario
                DropdownButtonFormField<String>(
                  initialValue: user?.role ?? 'Cliente',
                  decoration: const InputDecoration(labelText: 'Rol'),
                  items: ['Administrador', 'Mecánico', 'Cliente', 'Vendedor']
                      .map((role) =>
                          DropdownMenuItem(value: role, child: Text(role)))
                      .toList(),
                  onChanged: (value) {},
                ),

                /// Espacio para incluir más campos (teléfono, contraseña, etc.)
              ],
            ),
          ),

          /// Botones de acción del formulario
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text(user == null ? 'Crear Usuario' : 'Guardar Cambios'),
              onPressed: () {
                // Acción simulada de guardado
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          '${user == null ? 'Usuario Creado' : 'Usuario Actualizado'} exitosamente.')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  /// Cambia el estado del usuario (activo / inactivo)
  void _toggleUserStatus(User user) {
    setState(() {
      final index = mockUsers.indexWhere((u) => u.id == user.id);

      if (index != -1) {
        // Se simula la actualización del estado en la lista mock
        mockUsers[index] = User(
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role,
          isEnabled: !user.isEnabled,
        );

        _filterUsers(); // Refresca la lista mostrada

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Estado de ${user.name} cambiado a ${user.isEnabled ? 'Inactivo' : 'Activo'}.')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Barra superior de la pantalla
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        elevation: 0,
      ),

      /// Contenido principal
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Búsqueda + botón de creación
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// Campo para buscar usuarios
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Buscar Usuarios por nombre, email o rol...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onChanged: (value) {
                      _searchQuery = value;
                      _filterUsers();
                    },
                  ),
                ),

                const SizedBox(width: 16),

                /// Botón para abrir el formulario de nuevo usuario
                ElevatedButton.icon(
                  onPressed: () => _showUserFormDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo Usuario'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// Tabla paginada con información de usuarios
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView(
                    children: [
                      PaginatedDataTable(
                        header: const Text('Listado de Usuarios'),
                        rowsPerPage: 5,
                        columns: const [
                          DataColumn(label: Text('Nombre')),
                          DataColumn(label: Text('Email')),
                          DataColumn(label: Text('Rol')),
                          DataColumn(label: Text('Estado')),
                          DataColumn(label: Text('Acciones')),
                        ],

                        /// Fuente de datos personalizada para la tabla
                        source: _UserDataSource(
                          _filteredUsers,
                          context,
                          _showUserFormDialog,
                          _toggleUserStatus,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fuente de datos encargada de construir las filas de la tabla
class _UserDataSource extends DataTableSource {
  final List<User> users;
  final BuildContext context;
  final Function(User?) onEdit;
  final Function(User) onToggleStatus;

  _UserDataSource(
      this.users, this.context, this.onEdit, this.onToggleStatus);

  @override
  DataRow? getRow(int index) {
    if (index >= users.length) return null;
    final user = users[index];

    return DataRow(cells: [
      /// Nombre del usuario
      DataCell(Text(user.name)),

      /// Email del usuario
      DataCell(Text(user.email)),

      /// Rol asignado
      DataCell(Text(user.role)),

      /// Estado visual del usuario (activo/inactivo)
      DataCell(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: user.isEnabled
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            user.isEnabled ? 'Activo' : 'Inactivo',
            style: TextStyle(
              color: user.isEnabled ? Colors.green[800] : Colors.red[800],
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),

      /// Acciones rápidas: editar / activar-desactivar
      DataCell(
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => onEdit(user),
              tooltip: 'Editar Usuario',
            ),
            IconButton(
              icon: Icon(
                user.isEnabled ? Icons.toggle_on : Icons.toggle_off,
                color: user.isEnabled ? Colors.green : Colors.grey,
              ),
              onPressed: () => onToggleStatus(user),
              tooltip:
                  user.isEnabled ? 'Desactivar Usuario' : 'Activar Usuario',
            ),
          ],
        ),
      ),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => users.length;

  @override
  int get selectedRowCount => 0;
}

/// --- Previsualización opcional para ejecución independiente ---
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rafa Motos Admin',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const UsuariosScreen(),
    );
  }
}
