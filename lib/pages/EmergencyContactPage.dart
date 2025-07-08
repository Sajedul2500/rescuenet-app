import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContactPage extends StatefulWidget {
  const EmergencyContactPage({super.key});

  @override
  State<EmergencyContactPage> createState() => _EmergencyContactsPageState();
}

class _EmergencyContactsPageState extends State<EmergencyContactPage> {
  final TextEditingController _controller = TextEditingController();

  final List<String> _contacts = [
    '+8801712345678',
    '+8801811223344',
    '+8801933445566',
  ];

  final _phoneRegex = RegExp(r'^(?:\+88)?01[3-9]\d{8}$');

  bool isValidPhone(String number) {
    return _phoneRegex.hasMatch(number.trim());
  }

  String autoFormatPhone(String number) {
    number = number.trim();
    if (number.startsWith('01') && number.length == 11) {
      return '+88$number';
    }
    return number;
  }

  void _addContact() {
    String input = autoFormatPhone(_controller.text);

    if (!isValidPhone(input)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid phone number format.")),
      );
      return;
    }

    if (_contacts.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can add up to 5 contacts only.")),
      );
      return;
    }

    if (_contacts.contains(input)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("This number is already added.")),
      );
      return;
    }

    setState(() {
      _contacts.add(input);
      _controller.clear();
    });
  }

  void _removeContact(int index) {
    setState(() => _contacts.removeAt(index));
  }

  void _editContact(int index) async {
    TextEditingController editController =
    TextEditingController(text: _contacts[index]);

    final edited = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Contact"),
        content: TextField(
          controller: editController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(hintText: "Enter phone number"),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, editController.text),
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (edited != null) {
      String formatted = autoFormatPhone(edited);
      if (isValidPhone(formatted)) {
        setState(() => _contacts[index] = formatted);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid phone number format.")),
        );
      }
    }
  }

  Future<void> _callNumber(String number) async {
    final Uri uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to launch dialer.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        centerTitle: true,
        title: Text(
          'Emergency Contacts',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "Enter mobile number",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add, color: Colors.green),
                  onPressed: _addContact,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _contacts.isEmpty
                  ? const Center(child: Text("No contacts added yet."))
                  : ListView.builder(
                itemCount: _contacts.length,
                itemBuilder: (context, index) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    title: Text(
                      _contacts[index],
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.call, color: Colors.green),
                          onPressed: () => _callNumber(_contacts[index]),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editContact(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeContact(index),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
