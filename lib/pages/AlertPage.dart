import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:RescueNetBD/features/resource_sharing/data/local/resource_share_history_storage.dart';
import 'package:RescueNetBD/features/resource_sharing/domain/models/resource_share_history_item.dart';

class AlertPage extends StatefulWidget {
  const AlertPage({super.key});

  @override
  State<AlertPage> createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage> {
  final ResourceShareHistoryStorage _shareHistoryStorage =
      ResourceShareHistoryStorage();

  final List<Map<String, dynamic>> _advanceAlerts = const [
    {
      'type': 'Flood Advance Alert',
      'icon': Icons.water_damage,
      'severity': 'High',
      'color': Colors.blue,
      'time': '12 hours before risk',
      'area': 'Sylhet, Sunamganj',
      'tips': [
        'Move valuables to higher ground.',
        'Keep emergency kit ready.',
        'Avoid walking or driving through floodwater.'
      ]
    },
    {
      'type': 'Cyclone Advance Alert',
      'icon': Icons.cloud,
      'severity': 'High',
      'color': Colors.deepPurple,
      'time': '24 hours before landfall',
      'area': 'Cox’s Bazar, Chattogram coast',
      'tips': [
        'Secure doors and windows early.',
        'Prepare dry food, water, and medicine.',
        'Move to nearest cyclone shelter if instructed.'
      ]
    },
    {
      'type': 'Earthquake Advance Alert',
      'icon': Icons.crisis_alert,
      'severity': 'High',
      'color': Colors.orange,
      'time': 'Seismic activity watch',
      'area': 'Dhaka, Sylhet region',
      'tips': [
        'Keep drop-cover-hold space ready.',
        'Keep flashlight and emergency contact list accessible.',
        'Stay away from weak walls and heavy hanging objects.'
      ]
    },
  ];

  List<Map<String, dynamic>> _visibleAlerts = [];
  List<ResourceShareHistoryItem> _recentShareHistory = [];
  bool _isRescuer = false;

  @override
  void initState() {
    super.initState();
    _visibleAlerts = List<Map<String, dynamic>>.from(_advanceAlerts);
    _loadRescuerHistory();
  }

  Future<void> _loadRescuerHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('userRole')?.toLowerCase() ?? '';
    final rescuerRoles = {
      'police',
      'ambulance',
      'ambulance_service',
      'volunteer',
      'fire',
      'fire_service',
    };
    final isRescuer = rescuerRoles.contains(role);
    final history =
        isRescuer ? await _shareHistoryStorage.getHistory(limit: 3) : const [];

    if (!mounted) return;
    setState(() {
      _isRescuer = isRescuer;
      _recentShareHistory = history;
    });
  }

  void _executeVoiceCommand(String command) {
    final normalized = command.toLowerCase();
    setState(() {
      if (normalized.contains('flood')) {
        _visibleAlerts = _advanceAlerts
            .where((alert) => alert['type'].toString().toLowerCase().contains('flood'))
            .toList();
      } else if (normalized.contains('cyclone')) {
        _visibleAlerts = _advanceAlerts
            .where((alert) =>
                alert['type'].toString().toLowerCase().contains('cyclone'))
            .toList();
      } else if (normalized.contains('earthquake')) {
        _visibleAlerts = _advanceAlerts
            .where((alert) =>
                alert['type'].toString().toLowerCase().contains('earthquake'))
            .toList();
      } else {
        _visibleAlerts = List<Map<String, dynamic>>.from(_advanceAlerts);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Voice command applied: $command'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showVoiceCommandDialog() async {
    final controller = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Voice Command',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Try: "show flood alerts", "show cyclone alerts", or "show earthquake alerts".',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Speak or type command',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              final command = controller.text.trim();
              Navigator.pop(context);
              if (command.isNotEmpty) {
                _executeVoiceCommand(command);
              }
            },
            child: const Text('Run'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        centerTitle: true,
        title: Text(
          'Emergency Alerts',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic),
            tooltip: 'Voice command',
            onPressed: _showVoiceCommandDialog,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_isRescuer)
            _RescuerShareHistorySection(history: _recentShareHistory),
          ..._visibleAlerts.map((alert) => _AlertCard(alert: alert)),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final Map<String, dynamic> alert;

  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (alert['color'] as Color).withOpacity(0.2),
          child: Icon(alert['icon'] as IconData, color: alert['color'] as Color),
        ),
        title: Text(
          alert['type'].toString(),
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          '${alert['area']} • ${alert['severity']} severity • ${alert['time']}',
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(
              '${alert['type']} - Preparation Tips',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (alert['tips'] as List<String>)
                  .map(
                    (tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontSize: 14)),
                          Expanded(
                            child: Text(
                              tip,
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
            actions: [
              TextButton(
                child: const Text('Close'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RescuerShareHistorySection extends StatelessWidget {
  final List<ResourceShareHistoryItem> history;

  const _RescuerShareHistorySection({required this.history});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last resource share history',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            if (history.isEmpty)
              Text(
                'No recent shared resources.',
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
              ),
            ...history.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '• ${item.requestType} by ${item.requestedBy}\n  ${item.location}\n  Shared: ${item.sharedAt.toLocal()}',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[800]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}