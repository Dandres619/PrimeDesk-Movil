import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/moto_model.dart';
import '../../data/models/user_model.dart';
import '../../domain/providers/moto_notifier.dart';
import '../../domain/providers/client_notifier.dart';
import '../../data/mock_data/mock_data.dart';
import '../widgets/custom_app_bar.dart';

/// Pantalla principal para gestionar motocicletas.
/// Permite registrar, editar y buscar motos.
class MotosScreen extends ConsumerWidget {
  const MotosScreen({super.key});

  /// Obtiene la lista de clientes válidos para asignar como dueños.
  List<UserModel> get _clients =>
      mockUsers.where((u) => u.role == 'Cliente').toList();

  /// Muestra el formulario de registro/edición dentro de un modal.
  void _showMotoForm(
    BuildContext context,
    MotoNotifier notifier,
    ClientNotifier clientNotifier, {
    MotoModel? motoToEdit,
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
          child: _MotoForm(
            motoNotifier: notifier,
            motoToEdit: motoToEdit,
            clients: _clients,
            clientNotifier: clientNotifier,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Estado reactivo de motos
    final motos = ref.watch(motoProvider);

    // Notifiers para realizar operaciones CRUD
    final motoNotifier = ref.read(motoProvider.notifier);
    final clientNotifier = ref.read(clientProvider.notifier);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Gestión de Motocicletas',
        actions: [
          // Botón para abrir el formulario de creación
          IconButton(
            icon: const Icon(Icons.add_road),
            onPressed: () =>
                _showMotoForm(context, motoNotifier, clientNotifier),
            tooltip: 'Registrar Nueva Moto',
          ),
        ],
      ),
      body: Column(
        children: [
          // Buscador por placa o VIN
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: motoNotifier.searchMotos,
              decoration: const InputDecoration(
                labelText: 'Buscar Moto (Placa o VIN)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
          ),

          // Listado de motos o mensaje vacío
          Expanded(
            child: motos.isEmpty
                ? const Center(child: Text('No se encontraron motos activas.'))
                : ListView.builder(
                    itemCount: motos.length,
                    itemBuilder: (context, index) {
                      final moto = motos[index];
                      return _MotoListItem(
                        moto: moto,
                        motoNotifier: motoNotifier,
                        clientNotifier: clientNotifier,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Ítem visual para cada moto dentro del listado.
/// Incluye los datos principales y permite abrir el formulario de edición.
class _MotoListItem extends StatelessWidget {
  final MotoModel moto;
  final MotoNotifier motoNotifier;
  final ClientNotifier clientNotifier;

  const _MotoListItem({
    required this.moto,
    required this.motoNotifier,
    required this.clientNotifier,
  });

  @override
  Widget build(BuildContext context) {
    // Obtiene el nombre del cliente para mostrarlo
    final clientName = clientNotifier.getClientName(moto.clientId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      elevation: 3,
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.two_wheeler)),
        title: Text(
          '${moto.marca} ${moto.modelo} (${moto.placa})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dueño: $clientName'),
            Text('Año: ${moto.anio} | Color: ${moto.color}'),
            Text(
              'VIN: ${moto.vin}',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        // Abre el formulario de edición
        onTap: () {
          // Obtiene la referencia al widget padre para acceder al método
          final parent = context.findAncestorWidgetOfExactType<MotosScreen>();
          parent?._showMotoForm(
            context,
            motoNotifier,
            clientNotifier,
            motoToEdit: moto,
          );
        },
      ),
    );
  }
}

/// Formulario para registrar o editar motos.
/// Incluye validación, control de estado de carga y envíos seguros.
class _MotoForm extends StatefulWidget {
  final MotoNotifier motoNotifier;
  final ClientNotifier clientNotifier;
  final MotoModel? motoToEdit;
  final List<UserModel> clients;

  const _MotoForm({
    required this.motoNotifier,
    required this.motoToEdit,
    required this.clients,
    required this.clientNotifier,
  });

  @override
  State<_MotoForm> createState() => _MotoFormState();
}

class _MotoFormState extends State<_MotoForm> {
  final _formKey = GlobalKey<FormState>();

  // Campos del formulario
  late String _placa;
  late String _marca;
  late String _modelo;
  late int _anio;
  late String _color;
  late String _vin;
  late int? _selectedClientId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inicialización dependiendo de si es registro o edición
    _placa = widget.motoToEdit?.placa ?? '';
    _marca = widget.motoToEdit?.marca ?? '';
    _modelo = widget.motoToEdit?.modelo ?? '';
    _anio = widget.motoToEdit?.anio ?? DateTime.now().year;
    _color = widget.motoToEdit?.color ?? '';
    _vin = widget.motoToEdit?.vin ?? '';
    _selectedClientId = widget.motoToEdit?.clientId;
  }

  /// Maneja el envío del formulario, incluyendo validación,
  /// actualización o registro y manejo de errores.
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    String message;

    if (widget.motoToEdit == null) {
      // Registro
      if (_selectedClientId == null) {
        message = 'Error: Debe seleccionar un cliente dueño.';
      } else {
        message = await widget.motoNotifier.registerMoto(
          _selectedClientId!,
          _placa,
          _marca,
          _modelo,
          _anio,
          _color,
          _vin,
        );
      }
    } else {
      // Edición
      message = await widget.motoNotifier.editMoto(
        widget.motoToEdit!,
        _marca,
        _modelo,
        _anio,
        _color,
      );
    }

    // Evita errores de contexto después de operaciones async.
    if (!mounted) return;

    setState(() => _isLoading = false);

    // Notificación visual del resultado
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: message.startsWith('Error')
                ? Colors.red.shade900
                : Colors.white,
          ),
        ),
        backgroundColor: message.startsWith('Error')
            ? Colors.red.shade100
            : Colors.green,
      ),
    );

    // Cierra el modal si la operación fue exitosa
    if (!message.startsWith('Error')) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título dinámico del formulario
            Text(
              widget.motoToEdit == null
                  ? 'Registrar Nueva Motocicleta'
                  : 'Editar Moto: ${widget.motoToEdit!.placa}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Selección de dueño (solo en registro)
            if (widget.motoToEdit == null) ...[
              DropdownButtonFormField<int>(
                initialValue: _selectedClientId,
                decoration: const InputDecoration(labelText: 'Cliente Dueño'),
                items: widget.clients.map((c) {
                  return DropdownMenuItem<int>(
                    value: c.id,
                    child: Text('${c.name} (${c.telefono})'),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedClientId = v),
                validator: (v) => v == null ? 'Seleccione un cliente' : null,
              ),
              const SizedBox(height: 10),
            ] else ...[
              Text(
                'Dueño Actual: ${widget.clientNotifier.getClientName(widget.motoToEdit!.clientId)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
            ],

            // Campos del formulario -----------------------------
            TextFormField(
              initialValue: _placa,
              decoration: InputDecoration(
                labelText: 'Placa ${widget.motoToEdit != null ? '(No editable)' : ''}',
                enabled: widget.motoToEdit == null && !_isLoading,
              ),
              validator: (v) => v!.isEmpty ? 'Ingrese la placa' : null,
              onSaved: (v) => _placa = v!,
            ),
            const SizedBox(height: 10),

            TextFormField(
              initialValue: _marca,
              decoration: const InputDecoration(labelText: 'Marca'),
              validator: (v) => v!.isEmpty ? 'Ingrese la marca' : null,
              onSaved: (v) => _marca = v!,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 10),

            TextFormField(
              initialValue: _modelo,
              decoration: const InputDecoration(labelText: 'Modelo'),
              validator: (v) => v!.isEmpty ? 'Ingrese el modelo' : null,
              onSaved: (v) => _modelo = v!,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 10),

            TextFormField(
              initialValue: _anio.toString(),
              decoration: const InputDecoration(labelText: 'Año'),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty || int.tryParse(v) == null) {
                  return 'Ingrese un año válido';
                }
                return null;
              },
              onSaved: (v) => _anio = int.parse(v!),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 10),

            TextFormField(
              initialValue: _color,
              decoration: const InputDecoration(labelText: 'Color'),
              validator: (v) => v!.isEmpty ? 'Ingrese el color' : null,
              onSaved: (v) => _color = v!,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 10),

            TextFormField(
              initialValue: _vin,
              decoration: InputDecoration(
                labelText: 'VIN ${widget.motoToEdit != null ? '(No editable)' : ''}',
                enabled: widget.motoToEdit == null && !_isLoading,
              ),
              validator: (v) => v!.isEmpty ? 'Ingrese el VIN' : null,
              onSaved: (v) => _vin = v!,
            ),
            const SizedBox(height: 30),

            // Botón principal del formulario
            Center(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        widget.motoToEdit == null
                            ? 'Registrar Moto'
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
