import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NearByRequestPage extends StatelessWidget {
  const NearByRequestPage({super.key});

  final List<Map<String, dynamic>> _helpRequests = const [
    {
      'name': 'Rafiq Hossain',
      'type': 'Medical',
      'icon': FontAwesomeIcons.userDoctor,
      'distance': '0.9 km',
      'eta': '2 mins',
      'urgency': 'High',
      'description': 'Child fainted, urgent help needed.',
      'lastHelp': {
        'time': 'Today at 10:15 AM',
        'items': ['Paracetamol', 'Doctor visit']
      }
    },
    {
      'name': 'Sharmin Akter',
      'type': 'Fire',
      'icon': FontAwesomeIcons.fireExtinguisher,
      'distance': '1.5 km',
      'eta': '5 mins',
      'urgency': 'Medium',
      'description': 'Fire near kitchen, minor smoke visible.',
      'lastHelp': {
        'time': 'Yesterday at 4:30 PM',
        'items': ['Fire extinguisher', 'Safety advice']
      }
    },
    {
      'name': 'Jahidul Alam',
      'type': 'Relief',
      'icon': FontAwesomeIcons.handHoldingDroplet,
      'distance': '2.3 km',
      'eta': '7 mins',
      'urgency': 'Low',
      'description': 'Need food and water supply for family.',
      'lastHelp': {
        'time': '2 days ago',
        'items': ['Rice', 'Water bottles', 'Lentils']
      }
    },
  ];

  Color _urgencyColor(String urgency) {
    switch (urgency) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  List<Map<String, dynamic>> get _sortedRequests {
    final sorted = [..._helpRequests];
    sorted.sort((a, b) {
      int etaA = int.tryParse(a['eta'].toString().split(' ').first) ?? 999;
      int etaB = int.tryParse(b['eta'].toString().split(' ').first) ?? 999;
      return etaA.compareTo(etaB);
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        centerTitle: true,
        title: Text(
          'Nearby Help Requests',
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
        itemCount: _sortedRequests.length,
        itemBuilder: (context, index) {
          final request = _sortedRequests[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: icon, name, urgency badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(request['icon'], size: 30, color: Colors.black87),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              request['name'],
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${request['type']} Request',
                              style: GoogleFonts.poppins(
                                  fontSize: 13, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _urgencyColor(request['urgency']).withOpacity(0.1),
                          border: Border.all(color: _urgencyColor(request['urgency'])),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          request['urgency'],
                          style: GoogleFonts.poppins(
                            color: _urgencyColor(request['urgency']),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Location & ETA
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Distance: ${request['distance']}',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.timer, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'ETA: ${request['eta']}',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Description
                  Text(
                    '📝 ${request['description']}',
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                  ),

                  // Last Help Info
                  if (request.containsKey('lastHelp')) ...[
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.history, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Last Help: ${request['lastHelp']['time']}',
                                style: GoogleFonts.poppins(
                                    fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                'Items: ${List<String>.from(request['lastHelp']['items']).join(', ')}',
                                style: GoogleFonts.poppins(
                                    fontSize: 13, color: Colors.grey[800]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 14),

                  // Offer Help Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.volunteer_activism, color: Colors.white),
                      label: const Text(
                        'Offer Help',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('You offered help to ${request['name']}'),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(double.infinity, 45),
                      ),
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
