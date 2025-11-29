import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/proveedor_model.dart';
import '../../domain/providers/proveedor_notifier.dart';
import '../widgets/custom_app_bar.dart';

/// Pantalla de Gestión de Proveedores.
/// Permite registrar, editar, buscar y activar/inactivar proveedores.
class ProveedoresScreen extends ConsumerWidget {
  const ProveedoresScreen({super.key});

  /// Muestra el formulario en un modal inferior para registrar o editar proveedores.
  void _showProveedorForm(
    BuildContext context,
    ProveedorNotifier notifier, {
    ProveedorModel? proveedorToEdit,
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
          child: _ProveedorForm(
            proveedorNotifier: notifier,
            proveedorToEdit: proveedorToEdit,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Estado que contiene el listado de proveedores filtrados.
    final proveedores = ref.watch(proveedorProvider);

    // Notifier con las funciones de registrar, editar, buscar, inactivar, etc.
    final proveedorNotifier = ref.read(proveedorProvider.notifier);

    // Handler para abrir el formulario con o sin proveedor a editar.
    void showFormHandler({ProveedorModel? proveedorToEdit}) {
      _showProveedorForm(context, proveedorNotifier,
          proveedorToEdit: proveedorToEdit);
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Gestión de Proveedores',
        actions: [
          // Botón para registrar un nuevo proveedor
          IconButton(
            icon: const Icon(Icons.add_business),
            onPressed: () => showFormHandler(proveedorToEdit: null),
            tooltip: 'Registrar Nuevo Proveedor',
          ),
        ],
      ),

      // ================================
      // CUERPO PRINCIPAL DE LA PANTALLA
      // Incluye búsqueda y listado
      // ================================
      body: Column(
        children: [
          // -------------------------------
          // Barra de búsqueda
          // -------------------------------
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: proveedorNotifier.searchProveedores,
              decoration: const InputDecoration(
                labelText: 'Buscar Proveedor (Nombre, Contacto, Teléfono)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
          ),

          // -------------------------------
          // LISTADO DE PROVEEDORES
          // -------------------------------
          Expanded(
            child: proveedores.isEmpty
                ? const Center(child: Text('No se encontraron proveedores.'))
                : ListView.builder(
                    itemCount: proveedores.length,
                    itemBuilder: (context, index) {
                      final proveedor = proveedores[index];
                      return _ProveedorListItem(
                        proveedor: proveedor,
                        proveedorNotifier: proveedorNotifier,
                        onEdit: showFormHandler,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ITEM INDIVIDUAL DE LA LISTA DE PROVEEDORES
// Muestra información básica y permite acciones rápidas.
// ============================================================================
class _ProveedorListItem extends StatelessWidget {
  final ProveedorModel proveedor;
  final ProveedorNotifier proveedorNotifier;
  final Function({ProveedorModel? proveedorToEdit}) onEdit;

  const _ProveedorListItem({
    required this.proveedor,
    required this.proveedorNotifier,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      elevation: 3,
      child: ListTile(
        // Ícono según estado activo/inactivo
        leading: Icon(
          Icons.warehouse,
          color: proveedor.isActive ? Colors.green : Colors.grey,
        ),

        // Nombre comercial
        title: Text(
          proveedor.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        // Información detallada del proveedor
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contacto: ${proveedor.contacto} - ${proveedor.telefono}'),
            Text('Email: ${proveedor.email} | Dir: ${proveedor.direccion}'),
          ],
        ),

        // Acciones: Editar y Activar/Inactivar
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Editar proveedor
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => onEdit(proveedorToEdit: proveedor),
              tooltip: 'Editar Proveedor',
            ),

            // Cambiar estado (activo/inactivo)
            IconButton(
              icon: Icon(
                proveedor.isActive ? Icons.toggle_on : Icons.toggle_off,
                color: proveedor.isActive ? Colors.green : Colors.red,
              ),
              onPressed: () async {
                final result = await proveedorNotifier.toggleStatus(
                  proveedor,
                  !proveedor.isActive,
                );

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result)),
                );
              },
              tooltip: proveedor.isActive ? 'Inactivar' : 'Activar',
            ),
          ],
        ),

        // Tocarlo también abre edición
        onTap: () => onEdit(proveedorToEdit: proveedor),
      ),
    );
  }
}

// ============================================================================
// FORMULARIO DE REGISTRO Y EDICIÓN DE PROVEEDORES
// Utiliza el mismo formulario para ambas operaciones.
// ============================================================================
class _ProveedorForm extends StatefulWidget {
  final ProveedorNotifier proveedorNotifier;
  final ProveedorModel? proveedorToEdit;

  const _ProveedorForm({
    required this.proveedorNotifier,
    this.proveedorToEdit,
  });

  @override
  State<_ProveedorForm> createState() => _ProveedorFormState();
}

class _ProveedorFormState extends State<_ProveedorForm> {
  final _formKey = GlobalKey<FormState>();

  // Campos del formulario
  late String _nombre;
  late String _contacto;
  late String _telefono;
  late String _email;
  late String _direccion;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Cargar datos del proveedor si es edición
    _nombre = widget.proveedorToEdit?.nombre ?? '';
    _contacto = widget.proveedorToEdit?.contacto ?? '';
    _telefono = widget.proveedorToEdit?.telefono ?? '';
    _email = widget.proveedorToEdit?.email ?? '';
    _direccion = widget.proveedorToEdit?.direccion ?? '';
  }

  /// Maneja el registro o edición según corresponda.
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    String resultMessage;

    // Registrar proveedor nuevo
    if (widget.proveedorToEdit == null) {
      resultMessage = await widget.proveedorNotifier.registerProveedor(
        _nombre,
        _contacto,
        _telefono,
        _email,
        _direccion,
      );
    } else {
      // Editar proveedor existente
      resultMessage = await widget.proveedorNotifier.editProveedor(
        widget.proveedorToEdit!,
        _nombre,
        _contacto,
        _telefono,
        _direccion,
      );
    }

    if (!mounted) return;

    setState(() => _isLoading = false);

    // Mostrar resultado
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(resultMessage)));

    // Si todo salió bien, cerrar el modal
    if (!resultMessage.startsWith('Error')) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Título según operación
            Text(
              widget.proveedorToEdit == null
                  ? 'Registrar Proveedor'
                  : 'Editar Proveedor',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            // -------------------------------
            // Campos del formulario
            // -------------------------------
            TextFormField(
              initialValue: _nombre,
              decoration:
                  const InputDecoration(labelText: 'Nombre Comercial'),
              validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              onSaved: (v) => _nombre = v!,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 10),

            TextFormField(
              initialValue: _contacto,
              decoration:
                  const InputDecoration(labelText: 'Persona de Contacto'),
              validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              onSaved: (v) => _contacto = v!,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 10),

            TextFormField(
              initialValue: _telefono,
              decoration: const InputDecoration(labelText: 'Teléfono'),
              keyboardType: TextInputType.phone,
              validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              onSaved: (v) => _telefono = v!,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 10),

            // Email editable solo en registro (no edición)
            TextFormField(
              initialValue: _email,
              decoration: InputDecoration(
                labelText: 'Email '
                    '${widget.proveedorToEdit != null ? '(No editable)' : ''}',
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              onSaved: (v) => _email = v!,
              enabled:
                  widget.proveedorToEdit == null && !_isLoading,
            ),
            const SizedBox(height: 10),

            TextFormField(
              initialValue: _direccion,
              decoration: const InputDecoration(labelText: 'Dirección'),
              validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              onSaved: (v) => _direccion = v!,
              enabled: !_isLoading,
            ),

            const SizedBox(height: 30),

            // -------------------------------
            // Botón de guardar
            // -------------------------------
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
                        widget.proveedorToEdit == null
                            ? 'Registrar Proveedor'
                            : 'Guardar Cambios',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
