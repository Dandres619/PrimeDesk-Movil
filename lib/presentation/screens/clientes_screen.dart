import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../domain/providers/client_notifier.dart';
import '../widgets/custom_app_bar.dart';

/// Pantalla para la gestión completa de clientes.
/// Permite registrar, buscar, editar y eliminar clientes,
/// apoyándose en Riverpod mediante [clientProvider].
class ClientesScreen extends ConsumerStatefulWidget {
  const ClientesScreen({super.key});

  @override
  ConsumerState<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends ConsumerState<ClientesScreen> {
  /// Abre el formulario en un modal inferior para registrar o editar un cliente.
  /// Si [clientToEdit] no es nulo, el formulario se mostrará con datos precargados.
  void _showClientForm(
    BuildContext context,
    ClientNotifier notifier, {
    UserModel? clientToEdit,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: _ClientForm(
            clientNotifier: notifier,
            clientToEdit: clientToEdit,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    /// Estado reactivo de la lista de clientes.
    /// Se actualiza automáticamente cuando el notifier emite cambios.
    final clients = ref.watch(clientProvider);

    /// Acceso al notifier para ejecutar acciones sobre los clientes.
    final clientNotifier = ref.read(clientProvider.notifier);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Gestión de Clientes',
        actions: [
          /// Acción para registrar un nuevo cliente.
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showClientForm(context, clientNotifier),
            tooltip: 'Agregar Nuevo Cliente',
          ),
        ],
      ),

      /// Contenido principal de la pantalla.
      body: Column(
        children: [
          /// Campo de búsqueda que filtra resultados según nombre, email o teléfono.
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: clientNotifier.searchClients,
              decoration: const InputDecoration(
                labelText: 'Buscar Cliente (Nombre, Email, Teléfono)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
          ),

          /// Lista reactiva de clientes o mensaje si no hay resultados.
          Expanded(
            child: clients.isEmpty
                ? const Center(child: Text('No se encontraron clientes.'))
                : ListView.builder(
                    itemCount: clients.length,
                    itemBuilder: (context, index) {
                      final client = clients[index];

                      return _ClientListItem(
                        client: client,
                        clientNotifier: clientNotifier,
                        onEdit: () => _showClientForm(
                          context,
                          clientNotifier,
                          clientToEdit: client,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Formulario para registrar o editar clientes.
/// Incluye validación, manejo de estado local y retroalimentación visual.
class _ClientForm extends StatefulWidget {
  final ClientNotifier clientNotifier;
  final UserModel? clientToEdit;

  const _ClientForm({
    required this.clientNotifier,
    this.clientToEdit,
  });

  @override
  State<_ClientForm> createState() => _ClientFormState();
}

class _ClientFormState extends State<_ClientForm> {
  final _formKey = GlobalKey<FormState>();

  late String _name;
  late String _email;
  late String _phone;

  /// Indicador de proceso en ejecución para deshabilitar acciones.
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    /// Inicialización de campos según si es registro o edición.
    _name = widget.clientToEdit?.name ?? '';
    _email = widget.clientToEdit?.email ?? '';
    _phone = widget.clientToEdit?.telefono ?? '';
  }

  /// Procesa el envío del formulario ya sea para registrar o editar un cliente.
  /// Incluye validación, llamadas al notifier y gestión segura del contexto.
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    String resultMessage;

    if (widget.clientToEdit == null) {
      /// Registro de un nuevo cliente.
      resultMessage = await widget.clientNotifier.registerClient(
        _name,
        _email,
        _phone,
      );
    } else {
      /// Actualización de un cliente existente.
      resultMessage = await widget.clientNotifier.editClient(
        widget.clientToEdit!,
        _name,
        _phone,
      );
    }

    /// Evita usar [context] si el widget fue desmontado durante la operación asíncrona.
    if (!mounted) return;

    setState(() => _isLoading = false);

    /// Retroalimentación visual con resultado de la operación.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          resultMessage,
          style: TextStyle(
            color: resultMessage.startsWith('Error')
                ? Colors.red.shade900
                : Colors.white,
          ),
        ),
        backgroundColor: resultMessage.startsWith('Error')
            ? Colors.red.shade100
            : Colors.green,
      ),
    );

    /// Cierra el formulario solo si la acción fue exitosa.
    if (!resultMessage.startsWith('Error')) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    /// Formulario estructurado con validación por campo.
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Encabezado dinámico según sea registro o edición.
          Text(
            widget.clientToEdit == null
                ? 'Registrar Nuevo Cliente'
                : 'Editar Cliente: ${widget.clientToEdit!.name}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          /// Campo: nombre completo.
          TextFormField(
            initialValue: _name,
            decoration: const InputDecoration(labelText: 'Nombre Completo'),
            validator: (value) =>
                value!.isEmpty ? 'Ingrese un nombre válido' : null,
            onSaved: (value) => _name = value!,
            enabled: !_isLoading,
          ),
          const SizedBox(height: 10),

          /// Campo: email (solo editable en creación).
          TextFormField(
            initialValue: _email,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            validator: (value) =>
                value!.isEmpty ? 'Ingrese un email válido' : null,
            onSaved: (value) => _email = value!,
            enabled: widget.clientToEdit == null && !_isLoading,
          ),
          const SizedBox(height: 10),

          /// Campo: teléfono.
          TextFormField(
            initialValue: _phone,
            decoration: const InputDecoration(labelText: 'Teléfono'),
            keyboardType: TextInputType.phone,
            validator: (value) =>
                value!.isEmpty ? 'Ingrese un teléfono válido' : null,
            onSaved: (value) => _phone = value!,
            enabled: !_isLoading,
          ),
          const SizedBox(height: 20),

          /// Botón principal del formulario.
          Center(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      widget.clientToEdit == null
                          ? 'Registrar Cliente'
                          : 'Guardar Cambios',
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Elemento de lista que representa visualmente un cliente.
/// Incluye acciones rápidas: editar y eliminar con confirmación.
class _ClientListItem extends ConsumerWidget {
  final UserModel client;
  final ClientNotifier clientNotifier;
  final VoidCallback onEdit;

  const _ClientListItem({
    required this.client,
    required this.clientNotifier,
    required this.onEdit,
  });

  /// Muestra un diálogo de confirmación antes de eliminar un cliente.
  /// La eliminación es irreversible desde esta interfaz.
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text(
          '¿Está seguro de eliminar al cliente ${client.name}? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final result = await clientNotifier.deleteClient(client.id);

              /// Verifica que el contexto siga siendo válido antes de mostrar el resultado.
              if (!context.mounted) return;

              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(result)));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      elevation: 3,
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),

        /// Nombre principal del cliente.
        title: Text(
          client.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        /// Información complementaria: email, teléfono e ID.
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${client.email}'),
            Text('Teléfono: ${client.telefono}'),
            Text(
              'ID: ${client.id}',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),

        /// Acciones rápidas: editar y eliminar.
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Acción: editar cliente.
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
              tooltip: 'Editar Cliente',
            ),

            /// Acción: eliminar cliente con confirmación.
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context),
              tooltip: 'Eliminar Cliente',
            ),
          ],
        ),

        /// Placeholder para futuros detalles del cliente.
        onTap: () {
          // Implementación futura de historial o vista de detalle.
        },
      ),
    );
  }
}
