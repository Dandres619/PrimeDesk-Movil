import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';

/// Modelo que representa un horario laboral para un mecánico.
/// Contiene días activos, hora de inicio y fin, y un estado general de habilitación.
class WorkSchedule {
  final Map<String, bool> days; // Días seleccionados (mon, tue, etc.)
  final TimeOfDay start;        // Hora de inicio
  final TimeOfDay end;          // Hora de finalización
  final bool enabled;           // Indica si el mecánico está disponible

  WorkSchedule({
    required this.days,
    required this.start,
    required this.end,
    required this.enabled,
  });

  /// Convierte el modelo en un mapa para simular almacenamiento.
  Map<String, dynamic> toMap() => {
        'days': days,
        'startHour': start.hour,
        'startMinute': start.minute,
        'endHour': end.hour,
        'endMinute': end.minute,
        'enabled': enabled,
      };

  /// Crea un WorkSchedule desde un mapa (útil para mock o persistencia).
  factory WorkSchedule.fromMap(Map<String, dynamic> m) {
    final daysMap = Map<String, bool>.from(m['days'] as Map);
    return WorkSchedule(
      days: daysMap,
      start: TimeOfDay(
          hour: m['startHour'] as int, minute: m['startMinute'] as int),
      end: TimeOfDay(hour: m['endHour'] as int, minute: m['endMinute'] as int),
      enabled: m['enabled'] as bool,
    );
  }
}

/// Modelo simple para representar un mecánico dentro del mock.
class Mechanic {
  final String id;
  final String name;

  Mechanic({required this.id, required this.name});

  factory Mechanic.fromMap(Map<String, dynamic> m) =>
      Mechanic(id: m['id'] as String, name: m['name'] as String);
}

/// Servicio simulado para obtener mecánicos y administrar horarios (mock).
/// Sirve para pruebas sin backend real.
class MockScheduleService {
  // Lista estática de mecánicos simulados
  static final List<Map<String, String>> _mockMechanics = [
    {'id': 'm1', 'name': 'Juan Pérez'},
    {'id': 'm2', 'name': 'María López'},
    {'id': 'm3', 'name': 'Carlos Ruiz'},
  ];

  // Base de datos mock de horarios por mecánico
  static final Map<String, Map<String, dynamic>> _schedules = {
    'm1': {
      'days': {
        'mon': true,
        'tue': true,
        'wed': true,
        'thu': true,
        'fri': true,
        'sat': false,
        'sun': false,
      },
      'startHour': 9,
      'startMinute': 0,
      'endHour': 17,
      'endMinute': 0,
      'enabled': true,
    },
    'm2': {
      'days': {
        'mon': false,
        'tue': true,
        'wed': true,
        'thu': true,
        'fri': true,
        'sat': false,
        'sun': false,
      },
      'startHour': 10,
      'startMinute': 0,
      'endHour': 18,
      'endMinute': 0,
      'enabled': true,
    },
    'm3': {
      'days': {
        'mon': true,
        'tue': true,
        'wed': false,
        'thu': false,
        'fri': true,
        'sat': false,
        'sun': false,
      },
      'startHour': 8,
      'startMinute': 30,
      'endHour': 16,
      'endMinute': 30,
      'enabled': true,
    },
  };

  /// Retorna la lista de mecánicos simulados.
  Future<List<Mechanic>> getMechanics() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockMechanics.map((m) => Mechanic.fromMap(m)).toList();
  }

  /// Obtiene el horario asociado a un mecánico.
  /// Si no existe, devuelve el primero como fallback para fines de prueba.
  Future<WorkSchedule> getScheduleFor(String mechanicId) async {
    await Future.delayed(const Duration(milliseconds: 350));
    final m = _schedules[mechanicId];
    if (m == null) {
      return WorkSchedule.fromMap(
          Map<String, dynamic>.from(_schedules.values.first));
    }
    return WorkSchedule.fromMap(Map<String, dynamic>.from(m));
  }

  /// Guarda el horario en el mock. Siempre retorna true para simular éxito.
  Future<bool> saveScheduleFor(String mechanicId, WorkSchedule s) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _schedules[mechanicId] = s.toMap();
    return true;
  }
}

/// Pantalla principal para gestionar los horarios laborales de mecánicos.
class HorariosScreen extends StatefulWidget {
  const HorariosScreen({super.key});

  @override
  State<HorariosScreen> createState() => _HorariosScreenState();
}

class _HorariosScreenState extends State<HorariosScreen> {
  /// Lista de días disponibles con abreviatura y nombre completo.
  final List<Map<String, String>> _days = const [
    {'key': 'mon', 'short': 'Lun', 'full': 'Lunes'},
    {'key': 'tue', 'short': 'Mar', 'full': 'Martes'},
    {'key': 'wed', 'short': 'Mié', 'full': 'Miércoles'},
    {'key': 'thu', 'short': 'Jue', 'full': 'Jueves'},
    {'key': 'fri', 'short': 'Vie', 'full': 'Viernes'},
    {'key': 'sat', 'short': 'Sáb', 'full': 'Sábado'},
    {'key': 'sun', 'short': 'Dom', 'full': 'Domingo'},
  ];

  // Estado interno del formulario de horario
  final Map<String, bool> _selected = {};     // Días seleccionados
  bool _availabilityEnabled = true;           // Disponibilidad general
  TimeOfDay _start = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 17, minute: 0);

  // Servicio simulado
  final MockScheduleService _service = MockScheduleService();

  // Estados de carga
  bool _isLoading = true;
  bool _isSaving = false;

  // Mecánicos disponibles
  List<Mechanic> _mechanics = [];
  String? _selectedMechanicId;

  @override
  void initState() {
    super.initState();

    // Inicializa todos los días como no seleccionados
    for (var d in _days) {
      _selected[d['key']!] = false;
    }

    // Carga inicial de mecánicos y su horario
    _loadMockMechanicsAndSchedule();
  }

  /// Carga mecánicos y asigna el horario del primero disponible.
  Future<void> _loadMockMechanicsAndSchedule() async {
    setState(() => _isLoading = true);
    try {
      final mechs = await _service.getMechanics();
      if (!mounted) return;
      setState(() {
        _mechanics = mechs;
        _selectedMechanicId = mechs.isNotEmpty ? mechs.first.id : null;
      });

      if (_selectedMechanicId != null) {
        await _loadMockScheduleFor(_selectedMechanicId!);
      }
    } catch (_) {
      // Sin manejo de errores para demo
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Carga el horario asociado al mecánico seleccionado.
  Future<void> _loadMockScheduleFor(String mechanicId) async {
    setState(() => _isLoading = true);
    try {
      final s = await _service.getScheduleFor(mechanicId);
      if (!mounted) return;

      // Actualiza UI con datos obtenidos
      setState(() {
        for (var k in _selected.keys) {
          _selected[k] = s.days[k] ?? false;
        }
        _start = s.start;
        _end = s.end;
        _availabilityEnabled = s.enabled;
      });
    } catch (_) {
      // Ignorado en entorno de prueba
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Abre un selector de hora para modificar inicio o fin de jornada.
  Future<void> _pickTime(BuildContext context, bool isStart) async {
    final initial = isStart ? _start : _end;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child ?? const SizedBox.shrink(),
      ),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _start = picked;
        } else {
          _end = picked;
        }
      });
    }
  }

  /// Formatea la hora con ceros a la izquierda.
  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Guarda el horario actual en el mock, validando reglas básicas.
  Future<void> _saveSchedule() async {
    if (_selectedMechanicId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Selecciona un mecánico antes de guardar.')),
      );
      return;
    }

    final selectedDays =
        _selected.entries.where((e) => e.value).map((e) => e.key).toList();

    if (!_availabilityEnabled) {
      // Caso: disponibilidad deshabilitada (se guarda igualmente el horario mock)
      final schedule = WorkSchedule(
          days: Map.from(_selected), start: _start, end: _end, enabled: false);

      setState(() => _isSaving = true);
      final ok = await _service.saveScheduleFor(_selectedMechanicId!, schedule);
      if (!mounted) return;

      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok
              ? 'Disponibilidad desactivada. Cambios guardados (mock).'
              : 'Error guardando (mock).'),
        ),
      );
      return;
    }

    if (selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un día laboral.')),
      );
      return;
    }

    // Validación: la hora de inicio debe ser menor que la de fin
    final startMinutes = _start.hour * 60 + _start.minute;
    final endMinutes = _end.hour * 60 + _end.minute;

    if (startMinutes >= endMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('La hora de inicio debe ser anterior a la hora de fin.')),
      );
      return;
    }

    // Construcción final del modelo para guardar
    final schedule = WorkSchedule(
        days: Map.from(_selected),
        start: _start,
        end: _end,
        enabled: _availabilityEnabled);

    setState(() => _isSaving = true);

    final ok = await _service.saveScheduleFor(_selectedMechanicId!, schedule);
    if (!mounted) return;

    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(ok ? 'Horario guardado (mock).' : 'Error guardando (mock).'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar personalizado reutilizado
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: CustomAppBar(title: 'Gestión de Horarios'),
      ),

      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),

            child: Column(
              children: [
                /// --- SECCIÓN: Selección de mecánico ---
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Mecánico',
                      style: Theme.of(context).textTheme.titleMedium),
                ),

                const SizedBox(height: 8),

                // Dropdown con lista mock de mecánicos
                DropdownButtonFormField<String>(
                  initialValue: _selectedMechanicId,
                  items: _mechanics
                      .map((m) => DropdownMenuItem(
                            value: m.id,
                            child: Text(m.name),
                          ))
                      .toList(),
                  onChanged: (id) {
                    if (id == null) return;
                    setState(() => _selectedMechanicId = id);
                    _loadMockScheduleFor(id);
                  },
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),

                const SizedBox(height: 12),

                /// --- SECCIÓN: Toggle disponibilidad ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Habilitar disponibilidad',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    Switch(
                      value: _availabilityEnabled,
                      onChanged: (v) =>
                          setState(() => _availabilityEnabled = v),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// --- SECCIÓN: Selección de días laborales ---
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Días laborales',
                      style: Theme.of(context).textTheme.titleMedium),
                ),

                const SizedBox(height: 8),

                // Chips para seleccionar días activos
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _days.map((d) {
                    final key = d['key']!;
                    final selected = _selected[key] ?? false;

                    return ChoiceChip(
                      label: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(d['short']!,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text(d['full']!,
                              style: const TextStyle(fontSize: 10)),
                        ],
                      ),
                      selected: selected,
                      onSelected: _availabilityEnabled
                          ? (s) => setState(() => _selected[key] = s)
                          : null,
                      selectedColor:
                          Theme.of(context).colorScheme.primary.withAlpha(51),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                /// --- SECCIÓN: Horas de trabajo ---
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Horas de trabajo',
                      style: Theme.of(context).textTheme.titleMedium),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    // Botón para hora de inicio
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _availabilityEnabled
                            ? () => _pickTime(context, true)
                            : null,
                        child: Text('Inicio: ${_formatTime(_start)}'),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Botón para hora de finalización
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _availabilityEnabled
                            ? () => _pickTime(context, false)
                            : null,
                        child: Text('Fin: ${_formatTime(_end)}'),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                /// --- SECCIÓN: Resumen y acciones finales ---
                Card(
                  color: Colors.grey[50],
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _availabilityEnabled
                            ? Text(
                                'Activo • ${_formatTime(_start)} — ${_formatTime(_end)}')
                            : const Text('No disponible',
                                style: TextStyle(color: Colors.red)),

                        const SizedBox(height: 8),

                        // Lista de días seleccionados (chips)
                        Wrap(
                          spacing: 6,
                          children: _days
                              .where((d) => _selected[d['key']!] == true)
                              .map((d) => Chip(label: Text(d['short']!)))
                              .toList(),
                        ),

                        const SizedBox(height: 8),

                        // Botones de acción: resetear y guardar
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  // Restablece datos al estado por defecto
                                  setState(() {
                                    for (var k in _selected.keys) {
                                      _selected[k] = false;
                                    }
                                    _start =
                                        const TimeOfDay(hour: 9, minute: 0);
                                    _end = const TimeOfDay(hour: 17, minute: 0);
                                    _availabilityEnabled = true;
                                  });
                                },
                                child: const Text('Restablecer'),
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _saveSchedule,
                                child: _isSaving
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2))
                                    : const Text('Guardar horario'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// --- Overlay de carga mientras se obtiene información del mock ---
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.35),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}
