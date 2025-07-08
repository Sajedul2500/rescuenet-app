import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HelpRequestHistoryPage extends StatelessWidget {
  const HelpRequestHistoryPage({super.key});

  final List<Map<String, dynamic>> _sampleHistory = const [
    {
      'type': 'Police',
      'icon': FontAwesomeIcons.shieldHalved,
      'time': '2025-06-30 14:10',
      'resources': '2 Officers, 1 Vehicle',
      'status': 'Resolved',
      'notes': 'Quick response. Local station supported.',
      'relief': '',
    },
    {
      'type': 'Fire',
      'icon': FontAwesomeIcons.fireExtinguisher,
      'time': '2025-06-25 02:30',
      'resources': '1 Fire Truck, 4 Personnel',
      'status': 'Resolved',
      'notes': 'Fire contained. Property damage minimized.',
      'relief': '',
    },
    {
      'type': 'Ambulance',
      'icon': FontAwesomeIcons.truckMedical,
      'time': '2025-06-10 09:20',
      'resources': '1 Ambulance, 2 Paramedics',
      'status': 'Resolved',
      'notes': 'Patient transported to nearby hospital.',
      'relief': '',
    },
    {
      'type': 'Volunteer',
      'icon': FontAwesomeIcons.handHoldingHeart,
      'time': '2025-05-29 17:45',
      'resources': '3 Volunteers',
      'status': 'Assisted',
      'notes': 'Flood relief package delivered by NGO team.',
      'relief': '20 Bottles of Water, 5 Blankets, 10kg Rice',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        centerTitle: true,
        title: Text(
          'My Help Request History',
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
        itemCount: _sampleHistory.length,
        itemBuilder: (context, index) {
          final entry = _sampleHistory[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(entry['icon'] as IconData, size: 30, color: Colors.black87),
                      const SizedBox(width: 10),
                      Text(
                        entry['type'],
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(entry['status'],
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: entry['status'] == 'Resolved' ? Colors.green : Colors.orange,
                          )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('🕒 Time: ${entry['time']}', style: GoogleFonts.poppins(fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('📦 Resources Received: ${entry['resources']}', style: GoogleFonts.poppins(fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('📍 Notes: ${entry['notes']}', style: GoogleFonts.poppins(fontSize: 14)),
                  if ((entry['relief'] as String).isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '🏱 Relief Items: ${entry['relief']}',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
