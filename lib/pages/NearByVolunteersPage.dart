import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NearByVolunteersPage extends StatefulWidget {
  NearByVolunteersPage({super.key});

  @override
  State<NearByVolunteersPage> createState() => _NearByVolunteersPageState();
}

class _NearByVolunteersPageState extends State<NearByVolunteersPage> {
  final List<Map<String, dynamic>> _volunteers = [
    {
      'name': 'Afsana Rahman',
      'type': 'Medical Assistant',
      'icon': FontAwesomeIcons.userNurse,
      'eta': '5 mins',
      'distance': '1.2 km',
      'details': 'Available for medical emergencies with first-aid training.',
      'available': true,
      'rating': 4.8,
    },
    {
      'name': 'Rafiq Uddin',
      'type': 'Fire Response',
      'icon': FontAwesomeIcons.fireExtinguisher,
      'eta': '7 mins',
      'distance': '2.0 km',
      'details': 'Can assist in fire-related emergencies. Equipped with extinguisher.',
      'available': false,
      'rating': 4.1,
    },
    {
      'name': 'Jahanara Begum',
      'type': 'Food & Relief Volunteer',
      'icon': FontAwesomeIcons.handHoldingHeart,
      'eta': '4 mins',
      'distance': '0.9 km',
      'details': 'Provides food, water and shelter info during crisis.',
      'available': true,
      'rating': 4.9,
    },
  ];

  String _selectedType = 'All';
  bool _onlineOnly = false;

  List<String> get _volunteerTypes => ['All', ...{
    for (var v in _volunteers) v['type']
  }];

  List<Map<String, dynamic>> get _filteredAndSortedVolunteers {
    final filtered = _volunteers.where((v) {
      return (_selectedType == 'All' || v['type'] == _selectedType) &&
          (!_onlineOnly || v['available'] == true);
    }).toList();

    filtered.sort((a, b) {
      int etaA = int.tryParse(a['eta'].toString().split(' ').first) ?? 999;
      int etaB = int.tryParse(b['eta'].toString().split(' ').first) ?? 999;
      return etaA.compareTo(etaB);
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        centerTitle: true,
        title: Text(
          'Nearby Volunteers',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _filteredAndSortedVolunteers.isEmpty
                ? Center(
              child: Text(
                'No volunteers found for selected type.',
                style: GoogleFonts.poppins(),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredAndSortedVolunteers.length,
              itemBuilder: (context, index) {
                final volunteer = _filteredAndSortedVolunteers[index];
                return _buildVolunteerCard(volunteer, context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.filter_list, color: Colors.black87),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedType,
                  isExpanded: true,
                  items: _volunteerTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type, style: GoogleFonts.poppins(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value ?? 'All';
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  const Text("Online Only"),
                  Switch(
                    value: _onlineOnly,
                    onChanged: (val) {
                      setState(() => _onlineOnly = val);
                    },
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVolunteerCard(Map<String, dynamic> volunteer, BuildContext context) {
    final bool available = volunteer['available'] == true;
    return Opacity(
      opacity: available ? 1.0 : 0.5,
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(volunteer['icon'] as IconData, size: 30, color: Colors.black87),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              volunteer['name'],
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            _buildStatusDot(available),
                          ],
                        ),
                        Text(volunteer['type'],
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: Colors.grey[700])),
                        Row(
                          children: [
                            Icon(Icons.star, size: 14, color: Colors.amber[800]),
                            const SizedBox(width: 4),
                            Text('${volunteer['rating']}',
                                style: GoogleFonts.poppins(fontSize: 13)),
                          ],
                        )
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('📍 ${volunteer['distance']}',
                          style: GoogleFonts.poppins(fontSize: 13)),
                      Text('🕒 ETA: ${volunteer['eta']}',
                          style: GoogleFonts.poppins(fontSize: 13)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('ℹ️ About:',
                  style: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
              const SizedBox(height: 4),
              Text(volunteer['details'],
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87)),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.handshake, color: Colors.white),
                  label: Text(
                    available ? 'Request Help' : 'Unavailable',
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: available ? const Color(0xFFD32F2F) : Colors.grey,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  onPressed: available
                      ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Help request sent to ${volunteer['name']}'),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusDot(bool available) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: available ? Colors.green : Colors.red,
          ),
        ),
        Text(
          available ? 'Online' : 'Offline',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: available ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }
}
