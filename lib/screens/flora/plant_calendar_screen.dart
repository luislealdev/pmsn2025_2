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
    for (int i = 0; i < 12; i++) {
      events.putIfAbsent(current, () => []);
      events[current]!.add('Regar');
      current = current.add(Duration(days: interval));
    }

    setState(() {
      _events = events;
    });
  }

  List<String> _getEventsForDay(DateTime day) {
    return _events[_stripTime(day)] ?? [];
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
