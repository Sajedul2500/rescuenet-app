import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final Map<String, List<Map<String, dynamic>>> _sections = {
    'Personal Info': [
      {'label': 'Full Name', 'icon': Icons.person, 'controller': TextEditingController()},
      {'label': 'Email', 'icon': Icons.email, 'type': TextInputType.emailAddress, 'controller': TextEditingController()},
      {'label': 'Phone Number', 'icon': Icons.phone, 'type': TextInputType.phone, 'controller': TextEditingController()},
    ],
    'Parents Info': [
      {'label': 'Father\'s Name', 'icon': Icons.person_outline, 'controller': TextEditingController()},
      {'label': 'Father\'s NID/Birth Certificate No.', 'icon': Icons.badge, 'controller': TextEditingController()},
      {'label': 'Mother\'s Name', 'icon': Icons.person_outline, 'controller': TextEditingController()},
      {'label': 'Mother\'s NID/Birth Certificate No.', 'icon': Icons.badge, 'controller': TextEditingController()},
    ],
    'Siblings Info': [
      {'label': 'Brother\'s Name', 'icon': Icons.male, 'controller': TextEditingController()},
      {'label': 'Brother\'s NID/Birth Certificate', 'icon': Icons.badge, 'controller': TextEditingController()},
      {'label': 'Sister\'s Name', 'icon': Icons.female, 'controller': TextEditingController()},
      {'label': 'Sister\'s NID/Birth Certificate', 'icon': Icons.badge, 'controller': TextEditingController()},
    ],
  };

  final Map<String, bool> _expandedSections = {};

  @override
  void initState() {
    super.initState();
    for (var key in _sections.keys) {
      _expandedSections[key] = true; // Start with all sections open
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.red.shade700;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        centerTitle: true,
        title: Text(
          'My Profile',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: CircleAvatar(
                radius: 45,
                backgroundColor: Colors.blue[300],
                child: const Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),

            ..._sections.entries.map(
                  (entry) => _buildExpandableSection(entry.key, entry.value),
            ),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile saved successfully!')),
                  );
                }
              },
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text('Save Info'),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white, // 👈 white text & icon
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSection(String title, List<Map<String, dynamic>> fields) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ExpansionTile(
        initiallyExpanded: _expandedSections[title] ?? true,
        onExpansionChanged: (value) => setState(() => _expandedSections[title] = value),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        children: fields.map((field) {
          return _buildTextField(
            controller: field['controller'],
            label: field['label'],
            icon: field['icon'],
            inputType: field['type'] ?? TextInputType.text,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Required field' : null,
      ),
    );
  }
}
