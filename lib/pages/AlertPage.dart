import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AlertPage extends StatelessWidget {
  const AlertPage({super.key});

  final List<Map<String, dynamic>> alerts = const [
    {
      'type': 'Flood Warning',
      'icon': Icons.water_damage,
      'severity': 'High',
      'color': Colors.blue,
      'time': '10:30 AM',
      'area': 'Sylhet, Sunamganj',
      'tips': [
        'Move valuables to higher ground.',
        'Keep emergency kit ready.',
        'Avoid walking or driving through floodwater.'
      ]
    },
    {
      'type': 'Fire Alert',
      'icon': Icons.local_fire_department,
      'severity': 'Medium',
      'color': Colors.red,
      'time': '11:15 AM',
      'area': 'Mirpur 10, Dhaka',
      'tips': [
        'Stay away from fire-affected zones.',
        'Keep fire extinguishers nearby.',
        'Call 999 in case of emergency.'
      ]
    },
    {
      'type': 'Storm Warning',
      'icon': Icons.cloud,
      'severity': 'High',
      'color': Colors.deepPurple,
      'time': '9:00 AM',
      'area': 'Cox’s Bazar coast',
      'tips': [
        'Secure windows and doors.',
        'Charge mobile devices and power banks.',
        'Avoid traveling during storm hours.'
      ]
    },
    {
      'type': 'Heatwave Alert',
      'icon': Icons.wb_sunny,
      'severity': 'Low',
      'color': Colors.orange,
      'time': '12:00 PM',
      'area': 'Rajshahi',
      'tips': [
        'Stay hydrated and avoid outdoor activities at noon.',
        'Wear light-colored, loose clothing.',
        'Check on elderly and children frequently.'
      ]
    },
  ];

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
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          final alert = alerts[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 14),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: alert['color'].withOpacity(0.2),
                child: Icon(alert['icon'], color: alert['color']),
              ),
              title: Text(
                alert['type'],
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
                    children: (alert['tips'] as List<String>).map((tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontSize: 14)),
                          Expanded(child: Text(tip, style: GoogleFonts.poppins(fontSize: 14))),
                        ],
                      ),
                    )).toList(),
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
        },
      ),
    );
  }
}