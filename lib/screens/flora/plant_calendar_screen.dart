import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class PlantCalendarScreen extends StatefulWidget {
  final String cartItemId;
  const PlantCalendarScreen({super.key, required this.cartItemId});

  @override
  State<PlantCalendarScreen> createState() => _PlantCalendarScreenState();
}

class _PlantCalendarScreenState extends State<PlantCalendarScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Map<DateTime, List<String>> _events = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, dynamic>? _cartData;
  // Mostrar u ocultar días de riego en el calendario
  bool _showWateringDays = true;
  // Lista calculada de próximas fechas de riego
  List<DateTime> _wateringDates = [];
  // Fechas que ya han sido registradas como regadas
  Set<DateTime> _wateredDates = {};

  DateTime _stripTime(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();
    _loadCartAndBuildEvents();
  }

  Future<void> _loadCartAndBuildEvents() async {
    final doc = await _db.collection('cart').doc(widget.cartItemId).get();
    if (!doc.exists) return;
    final data = doc.data()!;
    setState(() {
      _cartData = data;
    });

    final Timestamp createdTs = data['created_at'] ?? Timestamp.now();
    final createdAt = createdTs.toDate();
    final int interval = (data['watering_interval_days'] is int)
        ? data['watering_interval_days'] as int
        : int.tryParse(data['watering_interval_days']?.toString() ?? '') ?? 7;
    final Timestamp? lastWateredTs = data['last_watered'] as Timestamp?;
    final DateTime base = lastWateredTs?.toDate() ?? createdAt;

    final Map<DateTime, List<String>> events = {};

    // marcar created_at
    events[_stripTime(createdAt)] = ['Agregado al carrito'];

    // generar proximos riegos (ej: 12 ocurrencias)
    var current = _stripTime(base);
    _wateringDates = [];
    for (int i = 0; i < 12; i++) {
      events.putIfAbsent(current, () => []);
      events[current]!.add('Regar');
      _wateringDates.add(current);
      current = current.add(Duration(days: interval));
    }

    // Procesar historial de riego si existe
    _wateredDates = {};
    if (data['watering_history'] != null && data['watering_history'] is List) {
      for (var entry in data['watering_history']) {
        try {
          if (entry is Map && entry['date'] is Timestamp) {
            final dt = (entry['date'] as Timestamp).toDate();
            _wateredDates.add(_stripTime(dt));
          }
        } catch (_) {}
      }
    }

    setState(() {
      _events = events;
    });
  }

  List<String> _getEventsForDay(DateTime day) {
    final key = _stripTime(day);
    final all = _events[key] ?? [];
    if (!_showWateringDays) {
      // Filtrar eventos Regar si el usuario no quiere verlos
      return all.where((e) => e != 'Regar').toList();
    }
    return all;
  }

  // helper removed: using _wateringDates and _wateredDates directly

  int _countWateredInMonth(DateTime month) {
    int count = 0;
    for (var d in _wateringDates) {
      if (d.year == month.year && d.month == month.month) {
        if (_wateredDates.contains(_stripTime(d))) count++;
      }
    }
    return count;
  }

  int _countPendingInMonth(DateTime month) {
    int count = 0;
    for (var d in _wateringDates) {
      if (d.year == month.year && d.month == month.month) {
        if (!_wateredDates.contains(_stripTime(d))) count++;
      }
    }
    return count;
  }

  void _showMonthDetails(DateTime month, bool showWatered) {
    final dates = _wateringDates.where((d) => d.year == month.year && d.month == month.month).toList();
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                showWatered ? 'Días regados' : 'Días por regar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (dates.isEmpty) Text('No hay registros para este mes') else ...[
                SizedBox(
                  height: 300,
                  child: ListView.separated(
                    itemCount: dates.length,
                    separatorBuilder: (_, __) => Divider(),
                    itemBuilder: (context, idx) {
                      final d = dates[idx];
                      final watered = _wateredDates.contains(_stripTime(d));
                      if (showWatered && !watered) return SizedBox.shrink();
                      if (!showWatered && watered) return SizedBox.shrink();
                      return ListTile(
                        leading: Icon(watered ? Icons.check_circle : Icons.water_drop, color: watered ? Colors.green : Colors.blue),
                        title: Text('${d.toLocal().toIso8601String().split('T').first}'),
                        subtitle: Text(watered ? 'Regado' : 'Pendiente'),
                        trailing: !watered
                            ? ElevatedButton(
                                onPressed: () async {
                                  await _markAsWatered(d);
                                  Navigator.of(ctx).pop();
                                },
                                child: Text('Marcar como regado'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[600]),
                              )
                            : null,
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _markAsWatered(DateTime day) async {
    // Actualizar last_watered y watering_history
    final now = DateTime(day.year, day.month, day.day);
    final docRef = _db.collection('cart').doc(widget.cartItemId);

    await docRef.update({
      'last_watered': Timestamp.fromDate(now),
      'watering_history': FieldValue.arrayUnion([
        {'date': Timestamp.fromDate(now), 'note': 'Regado desde calendario'}
      ])
    });

    // Rebuild events from the new last_watered
    await _loadCartAndBuildEvents();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Marcado como regado: ${now.toLocal().toIso8601String().split('T').first}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de riego'),
        backgroundColor: Colors.green[600],
      ),
      body: Column(
        children: [
          // Toggle para mostrar/ocultar días de riego
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('Mostrar días de riego', style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(width: 8),
                    Switch(
                      value: _showWateringDays,
                      activeColor: Colors.green[600],
                      onChanged: (v) => setState(() => _showWateringDays = v),
                    ),
                  ],
                ),
                // Chips resumen
                Row(
                  children: [
                    ActionChip(
                      label: Text('Regados: ${_countWateredInMonth(_focusedDay)}'),
                      onPressed: () => _showMonthDetails(_focusedDay, true),
                      backgroundColor: Colors.green[50],
                    ),
                    SizedBox(width: 8),
                    ActionChip(
                      label: Text('Faltan: ${_countPendingInMonth(_focusedDay)}'),
                      onPressed: () => _showMonthDetails(_focusedDay, false),
                      backgroundColor: Colors.orange[50],
                    ),
                  ],
                ),
              ],
            ),
          ),

          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
            eventLoader: _getEventsForDay,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Eventos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_selectedDay == null) ...[
                    Text('Selecciona un día para ver eventos')
                  ] else ...[
                    ..._getEventsForDay(_selectedDay!).map((e) => ListTile(
                          title: Text(e),
                          trailing: e == 'Regar'
                              ? ElevatedButton(
                                  onPressed: () => _markAsWatered(_selectedDay!),
                                  child: Text('Marcar como regado'),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green[600]),
                                )
                              : null,
                        ))
                  ],
                  const SizedBox(height: 16),
                  if (_cartData != null) ...[
                    Divider(),
                    Text('Plant info', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Name: ${_cartData!['plant_name'] ?? _cartData!['name'] ?? ''}'),
                    Text('Category: ${_cartData!['category'] ?? ''}'),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
