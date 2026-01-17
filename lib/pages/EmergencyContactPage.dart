import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/more_service.dart';

class EmergencyContactPage extends StatefulWidget {
  const EmergencyContactPage({super.key});

  @override
  State<EmergencyContactPage> createState() => _EmergencyContactsPageState();
}

class _EmergencyContactsPageState extends State<EmergencyContactPage> {
  final MoreService _moreService = MoreService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _relationshipController = TextEditingController();

  List<EmergencyContact> _contacts = [];
  bool _isLoading = true;
  String? _errorMessage;

  final _phoneRegex = RegExp(r'^(?:\+88)?01[3-9]\d{8}$');

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _moreService.getEmergencyContacts();

      if (response.success && response.data != null) {
        setState(() {
          _contacts = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message ?? 'Failed to load contacts';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

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

  Future<void> _showAddContactDialog() async {
    _nameController.clear();
    _phoneController.clear();
    _relationshipController.clear();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Add Emergency Contact',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name *',
                  labelStyle: GoogleFonts.poppins(fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone *',
                  labelStyle: GoogleFonts.poppins(fontSize: 14),
                  hintText: '01XXXXXXXXX',
                  hintStyle: GoogleFonts.poppins(fontSize: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.phone),
                ),
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _relationshipController,
                decoration: InputDecoration(
                  labelText: 'Relationship (Optional)',
                  labelStyle: GoogleFonts.poppins(fontSize: 14),
                  hintText: 'e.g., Father, Mother, Friend',
                  hintStyle: GoogleFonts.poppins(fontSize: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.people),
                ),
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Add',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await _addContact();
    }
  }

  Future<void> _addContact() async {
    final name = _nameController.text.trim();
    final phone = autoFormatPhone(_phoneController.text);
    final relationship = _relationshipController.text.trim();

    if (name.isEmpty) {
      _showSnackBar('Please enter a name', Colors.orange);
      return;
    }

    if (!isValidPhone(phone)) {
      _showSnackBar('Invalid phone number format', Colors.orange);
      return;
    }

    if (_contacts.length >= 5) {
      _showSnackBar('You can add up to 5 contacts only', Colors.orange);
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );

    try {
      final response = await _moreService.addEmergencyContact(
        name: name,
        phone: phone,
        relationship: relationship.isNotEmpty ? relationship : null,
      );

      if (mounted) Navigator.pop(context);

      if (response.success) {
        await _loadContacts();
        _showSnackBar('Contact added successfully', Colors.green);
      } else {
        _showSnackBar(
          response.message ?? 'Failed to add contact',
          Colors.red,
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showSnackBar('Error: $e', Colors.red);
    }
  }

  Future<void> _deleteContact(EmergencyContact contact) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Contact',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete ${contact.name}?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );

    try {
      final response = await _moreService.deleteEmergencyContact(contact.id);

      if (mounted) Navigator.pop(context);

      if (response.success) {
        await _loadContacts();
        _showSnackBar('Contact deleted successfully', Colors.green);
      } else {
        _showSnackBar(
          response.message ?? 'Failed to delete contact',
          Colors.red,
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showSnackBar('Error: $e', Colors.red);
    }
  }

  Future<void> _callNumber(String number) async {
    final Uri uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showSnackBar('Unable to launch dialer', Colors.red);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
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
          'Emergency Contacts',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadContacts,
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _contacts.length < 5 && !_isLoading
          ? FloatingActionButton.extended(
              onPressed: _showAddContactDialog,
              backgroundColor: const Color(0xFFD32F2F),
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                'Add Contact',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFD32F2F)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Failed to Load',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: GoogleFonts.poppins(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadContacts,
                icon: const Icon(Icons.refresh),
                label: Text(
                  'Retry',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_contacts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.contact_phone,
                size: 80,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'No Contacts Yet',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add emergency contacts to quickly reach them in critical situations.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _showAddContactDialog,
                icon: const Icon(Icons.add),
                label: Text(
                  'Add First Contact',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _contacts.length,
      itemBuilder: (context, index) {
        final contact = _contacts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFD32F2F).withOpacity(0.1),
              child: const Icon(
                Icons.person,
                color: Color(0xFFD32F2F),
              ),
            ),
            title: Text(
              contact.name,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  contact.phone,
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                if (contact.relationship != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    contact.relationship!,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.call, color: Colors.green),
                  onPressed: () => _callNumber(contact.phone),
                  tooltip: 'Call',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteContact(contact),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
