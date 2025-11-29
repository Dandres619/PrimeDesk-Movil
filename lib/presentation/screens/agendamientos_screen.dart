import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/appointment_model.dart';
import '../../domain/providers/appointment_notifier.dart';
import '../../domain/providers/client_notifier.dart';
import '../../domain/providers/moto_notifier.dart';
import '../../domain/providers/employee_notifier.dart';
import '../widgets/custom_app_bar.dart';

/// Pantalla principal para la gestión de agendamientos.
/// Permite listar, buscar, crear, modificar y confirmar citas de servicio.
class AgendamientosScreen extends ConsumerWidget {
  const AgendamientosScreen({super.key});

  /// Muestra el formulario de creación/edición de un agendamiento dentro
  /// de un modal inferior. Se utiliza para mantener consistencia visual
  /// y permitir edición sin abandonar la pantalla principal.
  void _showAppointmentForm(
      BuildContext context,
      AppointmentNotifier aNotifier,
      ClientNotifier cNotifier,
      MotoNotifier mNotifier,
      EmployeeNotifier eNotifier,
      {AppointmentModel? appointmentToEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            // Asegura que el teclado no cubra el formulario
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: _AppointmentForm(
            appointmentNotifier: aNotifier,
            clientNotifier: cNotifier,
            motoNotifier: mNotifier,
            employeeNotifier: eNotifier,
            appointmentToEdit: appointmentToEdit,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// Estado reactivo de los agendamientos.
    /// Se actualiza automáticamente al confirmar, buscar o editar.
    final appointments = ref.watch(appointmentProvider);

    /// Notifiers usados para acciones (crear, editar, buscar, etc.)
    final aNotifier = ref.read(appointmentProvider.notifier);
    final cNotifier = ref.read(clientProvider.notifier);
    final mNotifier = ref.read(motoProvider.notifier);
    final eNotifier = ref.read(employeeProvider.notifier);

    /// Handler común para mostrar el formulario tanto en modo creación
    /// como en modo edición.
    void showFormHandler({AppointmentModel? appointmentToEdit}) {
      _showAppointmentForm(context, aNotifier, cNotifier, mNotifier, eNotifier,
          appointmentToEdit: appointmentToEdit);
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Gestión de Agendamientos',
        actions: [
          /// Botón para abrir directamente el formulario en modo "nuevo servicio".
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => showFormHandler(appointmentToEdit: null),
            tooltip: 'Agendar Nuevo Servicio',
          ),
        ],
      ),

      /// Lista con buscador y resultados reactivos.
      body: Column(
        children: [
          /// Buscador por tipo de servicio o fecha.
          /// La lógica interna vive en appointmentNotifier.searchAppointments().
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: aNotifier.searchAppointments,
              decoration: const InputDecoration(
                labelText: 'Buscar Agendamiento (Servicio, Fecha)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
          ),

          /// Lista reactiva de agendamientos.
          Expanded(
            child: appointments.isEmpty
                ? const Center(child: Text('No hay agendamientos pendientes.'))
                : ListView.builder(
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      final appointment = appointments[index];
                      return _AppointmentListItem(
                        appointment: appointment,
                        aNotifier: aNotifier,
                        cNotifier: cNotifier,
                        mNotifier: mNotifier,
                        eNotifier: eNotifier,
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

/// Item individual de la lista.
/// Resume cliente, moto, servicio y permite confirmar o editar.
class _AppointmentListItem extends StatelessWidget {
  final AppointmentModel appointment;
  final AppointmentNotifier aNotifier;
  final ClientNotifier cNotifier;
  final MotoNotifier mNotifier;
  final EmployeeNotifier eNotifier;
  final Function({AppointmentModel? appointmentToEdit}) onEdit;

  const _AppointmentListItem({
    required this.appointment,
    required this.aNotifier,
    required this.cNotifier,
    required this.mNotifier,
    required this.eNotifier,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    /// Obtención de datos relacionados para mostrar información completa
    /// sin necesidad de estructuras complejas.
    final clientName = cNotifier.getClientName(appointment.clientId);
    final moto = mNotifier.getMoto(appointment.motoId);
    final employee =
        eNotifier.getEmployeeName(int.tryParse(appointment.employeeId) ?? 0);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      elevation: 3,
      color:
          appointment.isConfirmed ? Colors.blue.shade50 : Colors.grey.shade100,

      /// Acciones principales: confirmar/pendiente — editar.
      child: ListTile(
        leading: Icon(
          appointment.isConfirmed ? Icons.verified : Icons.help_outline,
          color: appointment.isConfirmed
              ? Colors.blue.shade700
              : Colors.grey.shade700,
        ),

        title: Text(
          appointment.serviceType,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cliente: $clientName | Empleado: $employee'),
            Text('Moto: ${moto?.marca ?? 'N/A'} - ${moto?.placa ?? 'N/A'}'),
            Text('Fecha/Hora: ${appointment.dateTime.toString().substring(0, 16)}'),
          ],
        ),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Alterna estado confirmado/pendiente.
            IconButton(
              icon: Icon(
                appointment.isConfirmed ? Icons.close : Icons.check,
                color: appointment.isConfirmed ? Colors.red : Colors.green,
              ),
              onPressed: () async {
                final result = await aNotifier.toggleConfirmation(
                    appointment, !appointment.isConfirmed);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(result)));
              },
              tooltip: appointment.isConfirmed
                  ? 'Marcar como Pendiente'
                  : 'Confirmar Agendamiento',
            ),

            /// Lanza el formulario en modo edición.
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => onEdit(appointmentToEdit: appointment),
              tooltip: 'Editar Agendamiento',
            ),
          ],
        ),

        onTap: () => onEdit(appointmentToEdit: appointment),
      ),
    );
  }
}

/// Formulario para crear o editar agendamientos.
/// Su estado se maneja internamente porque los campos pertenecen
/// a un único formulario aislado.
class _AppointmentForm extends StatefulWidget {
  final AppointmentNotifier appointmentNotifier;
  final ClientNotifier clientNotifier;
  final MotoNotifier motoNotifier;
  final EmployeeNotifier employeeNotifier;
  final AppointmentModel? appointmentToEdit;

  const _AppointmentForm({
    required this.appointmentNotifier,
    required this.clientNotifier,
    required this.motoNotifier,
    required this.employeeNotifier,
    this.appointmentToEdit,
  });

  @override
  State<_AppointmentForm> createState() => _AppointmentFormState();
}

class _AppointmentFormState extends State<_AppointmentForm> {
  /// Control del formulario y campos seleccionados.
  final _formKey = GlobalKey<FormState>();
  int? _selectedClientId;
  int? _selectedMotoId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? _selectedServiceType;
  int? _selectedEmployeeId;
  bool _isLoading = false;

  /// Servicios disponibles en el taller (simples para demo).
  final List<String> _serviceTypes = [
    'Cambio de Aceite',
    'Revisión General',
    'Cambio de Llantas',
    'Reparación de Motor'
  ];

  @override
  void initState() {
    super.initState();

    /// Si se está editando, cargar valores previos.
    if (widget.appointmentToEdit != null) {
      final app = widget.appointmentToEdit!;
      _selectedClientId = app.clientId;
      _selectedMotoId = app.motoId;
      _selectedServiceType = app.serviceType;
      _selectedEmployeeId = int.tryParse(app.employeeId);
      _selectedDate = app.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(app.dateTime);

    } else {
      /// Valores por defecto en nuevo agendamiento.
      _selectedServiceType = _serviceTypes.first;

      /// Por defecto seleccionar el primer mecánico disponible.
      final mecanicos = widget.employeeNotifier.getMecanicos();
      if (mecanicos.isNotEmpty) {
        _selectedEmployeeId = mecanicos.first.id;
      }
    }
  }

  /// Selector conjunto de fecha + hora para el servicio.
  Future<void> _pickDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedTime,
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDate = pickedDate;
          _selectedTime = pickedTime;
        });
      }
    }
  }

  /// Valida y envía el formulario para crear o actualizar un agendamiento.
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final appointmentDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    setState(() => _isLoading = true);

    String resultMessage;

    /// Diferenciamos entre creación y edición.
    if (widget.appointmentToEdit == null) {
      resultMessage = await widget.appointmentNotifier.registerAppointment(
        _selectedClientId!,
        _selectedMotoId!,
        appointmentDateTime,
        _selectedServiceType!,
        _selectedEmployeeId!.toString(),
      );
    } else {
      resultMessage = await widget.appointmentNotifier.editAppointment(
        widget.appointmentToEdit!,
        appointmentDateTime,
        _selectedServiceType!,
        _selectedEmployeeId!.toString(),
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(resultMessage)));

    /// Cerramos el modal solo si no hubo errores.
    if (!resultMessage.startsWith('Error')) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    /// Datos necesarios para llenar los dropdowns.
    final availableClients =
        widget.clientNotifier.state.where((c) => c.role == 'Cliente').toList();
    final availableMotos = widget.motoNotifier.state;
    final availableEmployees = widget.employeeNotifier.getMecanicos();

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.appointmentToEdit == null
                  ? 'Agendar Nuevo Servicio'
                  : 'Editar Agendamiento',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            /// Campos mostrados solo al crear nuevo agendamiento.
            if (widget.appointmentToEdit == null) ...[
              DropdownButtonFormField<int>(
                initialValue: _selectedClientId,
                decoration: const InputDecoration(labelText: 'Cliente'),
                items: availableClients
                    .map((c) =>
                        DropdownMenuItem(value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: (newValue) =>
                    setState(() => _selectedClientId = newValue),
                validator: (v) => v == null ? 'Seleccione cliente' : null,
              ),
              const SizedBox(height: 10),
            ],

            if (widget.appointmentToEdit == null) ...[
              DropdownButtonFormField<int>(
                initialValue: _selectedMotoId,
                decoration:
                    const InputDecoration(labelText: 'Motocicleta a Revisar'),
                items: availableMotos
                    .where((m) => m.clientId == _selectedClientId)
                    .map((m) => DropdownMenuItem(
                        value: m.id,
                        child: Text('${m.marca} ${m.modelo} (${m.placa})')))
                    .toList(),
                onChanged: (newValue) =>
                    setState(() => _selectedMotoId = newValue),
                validator: (v) => v == null ? 'Seleccione moto' : null,
              ),
              const SizedBox(height: 10),
            ],

            DropdownButtonFormField<String>(
              initialValue: _selectedServiceType,
              decoration: const InputDecoration(labelText: 'Tipo de Servicio'),
              items: _serviceTypes
                  .map(
                      (service) => DropdownMenuItem(value: service, child: Text(service)))
                  .toList(),
              onChanged: (newValue) =>
                  setState(() => _selectedServiceType = newValue),
              validator: (v) => v == null ? 'Seleccione servicio' : null,
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<int>(
              initialValue: _selectedEmployeeId,
              decoration: const InputDecoration(labelText: 'Mecánico Asignado'),
              items: availableEmployees
                  .map((e) => DropdownMenuItem(value: e.id, child: Text(e.name)))
                  .toList(),
              onChanged: (newValue) =>
                  setState(() => _selectedEmployeeId = newValue),
              validator: (v) => v == null ? 'Seleccione un empleado' : null,
            ),

            const SizedBox(height: 20),

            /// Campo de fecha y hora editable.
            ListTile(
              title: Text(
                'Fecha y Hora: ${_selectedDate.toString().substring(0, 10)} ${_selectedTime.format(context)}',
              ),
              trailing: const Icon(Icons.edit_calendar),
              onTap: _pickDateTime,
            ),

            const SizedBox(height: 30),

            /// Botón de acción con indicador de carga.
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
                    : Text(widget.appointmentToEdit == null
                        ? 'Agendar Servicio'
                        : 'Guardar Cambios'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
