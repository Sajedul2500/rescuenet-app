import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'LoginPage.dart';
import 'UserProfilePage.dart';
import '../features/auth/data/services/auth_service.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingPage> {
  final AuthService _authService = AuthService();
  bool _notificationsEnabled = true;
  bool _locationSharing = true;
  String _selectedLanguage = 'English';
  bool _isLoading = true;

  final List<String> _languages = ['English', 'বাংলা (Bangla)'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _locationSharing = prefs.getBool('locationSharing') ?? true;
      _selectedLanguage = prefs.getString('selectedLanguage') ?? 'English';
      _isLoading = false;
    });
  }

  Future<void> _saveNotificationSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);
    setState(() {
      _notificationsEnabled = value;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value ? 'Notifications enabled' : 'Notifications disabled',
            style: GoogleFonts.poppins(),
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _saveLocationSharingSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('locationSharing', value);
    setState(() {
      _locationSharing = value;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value ? 'Location sharing enabled' : 'Location sharing disabled',
            style: GoogleFonts.poppins(),
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _saveLanguageSetting(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', language);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFD32F2F),
          centerTitle: true,
          title: Text(
            'Settings',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        centerTitle: true,
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('General'),
          _buildCard(
            children: [
              _buildLanguageSelector(),
            ],
          ),
          const SizedBox(height: 12),
          _buildSectionTitle('Notifications'),
          _buildCard(
            children: [
              _buildSwitchTile(
                title: 'Enable Notifications',
                value: _notificationsEnabled,
                onChanged: (val) => _saveNotificationSetting(val),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSectionTitle('Privacy'),
          _buildCard(
            children: [
              _buildSwitchTile(
                title: 'Location Sharing',
                value: _locationSharing,
                onChanged: (val) => _saveLocationSharingSetting(val),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSectionTitle('Account'),
          _buildCard(
            children: [
              ListTile(
                leading: const Icon(Icons.lock),
                title: Text('Change Password',
                    style: GoogleFonts.poppins(fontSize: 14)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserProfilePage(),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text('Logout',
                    style:
                        GoogleFonts.poppins(fontSize: 14, color: Colors.red)),
                onTap: () => _confirmLogout(),
              ),
              const Divider(height: 1),
              ListTile(
                leading:
                    const Icon(Icons.delete_forever, color: Colors.redAccent),
                title: Text('Delete Account',
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: Colors.redAccent)),
                onTap: () => _confirmAccountDeletion(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: GoogleFonts.poppins(fontSize: 14)),
      value: value,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _buildLanguageSelector() {
    return ListTile(
      leading: const Icon(Icons.language),
      title: Text('Language', style: GoogleFonts.poppins(fontSize: 14)),
      trailing: DropdownButton<String>(
        value: _selectedLanguage,
        onChanged: (String? newValue) async {
          if (newValue != null) {
            await _saveLanguageSetting(newValue);
            setState(() {
              _selectedLanguage = newValue;
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Language set to $_selectedLanguage',
                    style: GoogleFonts.poppins(),
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            }
          }
        },
        items: _languages.map<DropdownMenuItem<String>>((String lang) {
          return DropdownMenuItem<String>(
            value: lang,
            child: Text(lang),
          );
        }).toList(),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Confirm Logout',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to logout?',
            style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              // Show loading
              Navigator.pop(context); // Close dialog

              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );

              try {
                // Call logout API
                await _authService.logout();

                // Clear SharedPreferences
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                if (context.mounted) {
                  // Close loading dialog
                  Navigator.pop(context);

                  // Navigate to login page and clear all previous routes
                  Navigator.of(context).pushAndRemoveUntil(
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 500),
                      pageBuilder: (_, __, ___) => const LoginPage(),
                      transitionsBuilder: (_, animation, __, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                    ),
                    (route) => false,
                  );

                  // Show success message after navigation
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Logged out successfully',
                              style: GoogleFonts.poppins()),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  });
                }
              } catch (e) {
                if (context.mounted) {
                  // Close loading dialog
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Logout failed: $e',
                          style: GoogleFonts.poppins()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _confirmAccountDeletion() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'This action is irreversible. Are you sure you want to delete your account?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child:
                const Text('Delete', style: TextStyle(color: Colors.redAccent)),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deleted.')),
              );
              // TODO: Add actual deletion logic
            },
          ),
        ],
      ),
    );
  }
}
