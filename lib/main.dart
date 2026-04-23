import 'package:flutter/material.dart';
import 'dart:async';

void main() => runApp(const SmartClockApp());

class SmartClockApp extends StatelessWidget {
  const SmartClockApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Clock',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0f0f1a),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF7a7aff),
          surface: Color(0xFF1e1e3f),
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Map<String, dynamic>> _alarms = [];

  void _addAlarm(int hour, int minute) {
    setState(() {
      _alarms.add({'hour': hour, 'minute': minute, 'on': true});
    });
  }

  void _toggleAlarm(int index) {
    setState(() => _alarms[index]['on'] = !_alarms[index]['on']);
  }

  void _deleteAlarm(int index) {
    setState(() => _alarms.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      ClockPage(alarms: _alarms),
      AlarmPage(
          alarms: _alarms,
          onAdd: _addAlarm,
          onToggle: _toggleAlarm,
          onDelete: _deleteAlarm),
      const WatchPage(),
    ];
    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF1e1e3f),
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.access_time_outlined),
              selectedIcon: Icon(Icons.access_time_filled),
              label: 'Clock'),
          NavigationDestination(
              icon: Icon(Icons.alarm_outlined),
              selectedIcon: Icon(Icons.alarm),
              label: 'Alarm'),
          NavigationDestination(
              icon: Icon(Icons.watch_outlined),
              selectedIcon: Icon(Icons.watch),
              label: 'Watch'),
        ],
      ),
    );
  }
}

// ── CLOCK PAGE ──────────────────────────────────────────
class ClockPage extends StatefulWidget {
  final List<Map<String, dynamic>> alarms;
  const ClockPage({super.key, required this.alarms});
  @override
  State<ClockPage> createState() => _ClockPageState();
}

class _ClockPageState extends State<ClockPage> {
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1),
        (_) => setState(() => _now = DateTime.now()));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    int h = _now.hour, m = _now.minute, s = _now.second;
    final ampm = h >= 12 ? 'PM' : 'AM';
    int h12 = h % 12 == 0 ? 12 : h % 12;
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final dateStr =
        '${days[_now.weekday % 7]}, ${months[_now.month - 1]} ${_now.day}';
    final activeAlarms = widget.alarms.where((a) => a['on'] == true).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Clock',
            style: TextStyle(color: Color(0xFF7a7aff), letterSpacing: 2)),
        backgroundColor: const Color(0xFF0f0f1a),
        centerTitle: true,
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF7a7aff), width: 3),
              color: const Color(0xFF1e1e3f),
            ),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('${_pad(h12)}:${_pad(m)}:${_pad(s)}',
                  style: const TextStyle(
                      fontSize: 34,
                      color: Color(0xFFe0e0ff),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2)),
              Text(ampm,
                  style:
                      const TextStyle(fontSize: 16, color: Color(0xFF7a7aff))),
              const SizedBox(height: 4),
              Text(dateStr,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ]),
          ),
          const SizedBox(height: 30),
          if (activeAlarms.isEmpty)
            const Text('No active alarms', style: TextStyle(color: Colors.grey))
          else ...[
            const Text('ACTIVE ALARMS',
                style: TextStyle(
                    color: Colors.grey, fontSize: 11, letterSpacing: 1)),
            const SizedBox(height: 10),
            ...activeAlarms.map((a) => Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1e1e3f),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: const Color(0xFF3a3a6a), width: 0.5),
                  ),
                  child: Row(children: [
                    const Icon(Icons.alarm, color: Color(0xFF7a7aff), size: 18),
                    const SizedBox(width: 10),
                    Text('${_pad(a['hour'])}:${_pad(a['minute'])}',
                        style: const TextStyle(
                            color: Color(0xFFe0e0ff), fontSize: 18)),
                  ]),
                )),
          ],
        ]),
      ),
    );
  }
}

// ── ALARM PAGE ──────────────────────────────────────────
class AlarmPage extends StatelessWidget {
  final List<Map<String, dynamic>> alarms;
  final Function(int, int) onAdd;
  final Function(int) onToggle;
  final Function(int) onDelete;

  const AlarmPage(
      {super.key,
      required this.alarms,
      required this.onAdd,
      required this.onToggle,
      required this.onDelete});

  Future<void> _pick(BuildContext context) async {
    final picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) => Theme(
            data: ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(
                    primary: Color(0xFF7a7aff), surface: Color(0xFF1e1e3f))),
            child: child!));
    if (picked != null) onAdd(picked.hour, picked.minute);
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
              const Text('Alarms', style: TextStyle(color: Color(0xFF7a7aff))),
          backgroundColor: const Color(0xFF0f0f1a),
          centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _pick(context),
          backgroundColor: const Color(0xFF7a7aff),
          icon: const Icon(Icons.add),
          label: const Text('Add Alarm')),
      body: alarms.isEmpty
          ? const Center(
              child: Text('No alarms.\nTap + to add one.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: alarms.length,
              itemBuilder: (context, i) {
                final a = alarms[i];
                return Card(
                  color: const Color(0xFF1e1e3f),
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(
                          color: Color(0xFF3a3a6a), width: 0.5)),
                  child: ListTile(
                    leading: const Icon(Icons.alarm, color: Color(0xFF7a7aff)),
                    title: Text('${_pad(a['hour'])}:${_pad(a['minute'])}',
                        style: const TextStyle(
                            color: Color(0xFFe0e0ff),
                            fontSize: 26,
                            fontWeight: FontWeight.w500)),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      Switch(
                          value: a['on'],
                          activeColor: const Color(0xFF7a7aff),
                          onChanged: (_) => onToggle(i)),
                      IconButton(
                          icon:
                              const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => onDelete(i)),
                    ]),
                  ),
                );
              }),
    );
  }
}

// ── WATCH PAGE ──────────────────────────────────────────
class WatchPage extends StatefulWidget {
  const WatchPage({super.key});
  @override
  State<WatchPage> createState() => _WatchPageState();
}

class _WatchPageState extends State<WatchPage> {
  final List<Map<String, String>> _devices = [
    {'name': 'SmartWatch Pro', 'status': 'disconnected'},
    {'name': 'Galaxy Watch 6', 'status': 'disconnected'},
    {'name': 'Xiaomi Mi Watch', 'status': 'disconnected'},
    {'name': 'Apple Watch SE', 'status': 'disconnected'},
  ];

  bool _scanning = false;
  bool _scanned = false;

  void _scan() async {
    setState(() {
      _scanning = true;
      _scanned = false;
    });
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      _scanning = false;
      _scanned = true;
    });
  }

  void _connect(int i) async {
    setState(() => _devices[i]['status'] = 'connecting');
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _devices[i]['status'] = 'connected');
  }

  void _disconnect(int i) {
    setState(() => _devices[i]['status'] = 'disconnected');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Smartwatch',
              style: TextStyle(color: Color(0xFF7a7aff))),
          backgroundColor: const Color(0xFF0f0f1a),
          centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _scanning ? null : _scan,
                icon: _scanning
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.bluetooth_searching),
                label: Text(_scanning ? 'Scanning...' : 'Scan for Devices'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7a7aff),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
              )),
          const SizedBox(height: 16),
          if (!_scanned && !_scanning)
            const Expanded(
                child: Center(
                    child: Text('Tap Scan to find your smartwatch',
                        style: TextStyle(color: Colors.grey))))
          else if (_scanning)
            const Expanded(
                child: Center(
                    child: Text('Searching for devices...',
                        style: TextStyle(color: Colors.grey))))
          else
            Expanded(
                child: ListView.builder(
                    itemCount: _devices.length,
                    itemBuilder: (context, i) {
                      final d = _devices[i];
                      final isConnected = d['status'] == 'connected';
                      final isConnecting = d['status'] == 'connecting';
                      return Card(
                        color: const Color(0xFF1e1e3f),
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                                color: isConnected
                                    ? const Color(0xFF4aff90)
                                    : const Color(0xFF3a3a6a),
                                width: 0.5)),
                        child: ListTile(
                          leading: Icon(Icons.watch,
                              color: isConnected
                                  ? const Color(0xFF4aff90)
                                  : const Color(0xFF7a7aff)),
                          title: Text(d['name']!,
                              style: const TextStyle(color: Color(0xFFe0e0ff))),
                          subtitle: Text(
                              isConnected
                                  ? 'Connected via BLE'
                                  : isConnecting
                                      ? 'Connecting...'
                                      : 'Not connected',
                              style: TextStyle(
                                  color: isConnected
                                      ? const Color(0xFF4aff90)
                                      : isConnecting
                                          ? Colors.orange
                                          : Colors.grey,
                                  fontSize: 12)),
                          trailing: isConnecting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2))
                              : TextButton(
                                  onPressed: () => isConnected
                                      ? _disconnect(i)
                                      : _connect(i),
                                  child: Text(
                                      isConnected ? 'Disconnect' : 'Connect',
                                      style: TextStyle(
                                          color: isConnected
                                              ? Colors.redAccent
                                              : const Color(0xFF7a7aff)))),
                        ),
                      );
                    })),
        ]),
      ),
    );
  }
}
