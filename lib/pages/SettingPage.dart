import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import 'LoginPage.dart';
import 'UserProfilePage.dart';
import '../features/auth/data/services/auth_service.dart';
import '../main.dart';

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

  Future<void> _saveNotificationSetting(
      bool value, AppLocalizations l10n) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);
    setState(() {
      _notificationsEnabled = value;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value ? l10n.notificationsEnabled : l10n.notificationsDisabled,
            style: GoogleFonts.poppins(),
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _saveLocationSharingSetting(
      bool value, AppLocalizations l10n) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('locationSharing', value);
    setState(() {
      _locationSharing = value;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value ? l10n.locationSharingEnabled : l10n.locationSharingDisabled,
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
    final l10n = AppLocalizations.of(context)!;
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFD32F2F),
          centerTitle: true,
          title: Text(
            l10n.settings,
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
          l10n.settings,
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
          _buildSectionTitle(l10n.general),
          _buildCard(
            children: [
              _buildLanguageSelector(l10n),
            ],
          ),
          const SizedBox(height: 12),
          _buildSectionTitle(l10n.notifications),
          _buildCard(
            children: [
              _buildSwitchTile(
                title: l10n.enableNotifications,
                value: _notificationsEnabled,
                onChanged: (val) => _saveNotificationSetting(val, l10n),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSectionTitle(l10n.privacy),
          _buildCard(
            children: [
              _buildSwitchTile(
                title: l10n.locationSharing,
                value: _locationSharing,
                onChanged: (val) => _saveLocationSharingSetting(val, l10n),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSectionTitle(l10n.account),
          _buildCard(
            children: [
              ListTile(
                leading: const Icon(Icons.lock),
                title: Text(l10n.changePassword,
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
                title: Text(l10n.logout,
                    style:
                        GoogleFonts.poppins(fontSize: 14, color: Colors.red)),
                onTap: () => _confirmLogout(l10n),
              ),
              const Divider(height: 1),
              ListTile(
                leading:
                    const Icon(Icons.delete_forever, color: Colors.redAccent),
                title: Text(l10n.deleteAccount,
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: Colors.redAccent)),
                onTap: () => _confirmAccountDeletion(l10n),
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

  Widget _buildLanguageSelector(AppLocalizations l10n) {
    final List<Map<String, String>> languages = [
      {'code': 'English', 'name': l10n.english},
      {'code': 'বাংলা (Bangla)', 'name': l10n.bangla},
    ];

    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(l10n.language, style: GoogleFonts.poppins(fontSize: 14)),
      trailing: DropdownButton<String>(
        value: _selectedLanguage,
        onChanged: (String? newValue) async {
          if (newValue != null) {
            await _saveLanguageSetting(newValue);
            setState(() {
              _selectedLanguage = newValue;
            });

            // Change app locale
            if (mounted) {
              Locale newLocale;
              if (newValue.contains('Bangla') || newValue.contains('বাংলা')) {
                newLocale = const Locale('bn');
              } else {
                newLocale = const Locale('en');
              }
              RescueNetApp.setLocale(context, newLocale);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l10n.languageSetTo(_selectedLanguage),
                    style: GoogleFonts.poppins(),
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            }
          }
        },
        items: languages.map<DropdownMenuItem<String>>((lang) {
          return DropdownMenuItem<String>(
            value: lang['code'],
            child: Text(lang['name']!),
          );
        }).toList(),
      ),
    );
  }

  void _confirmLogout(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.confirmLogout,
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(l10n.confirmLogoutMessage, style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            child: Text(l10n.cancel),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(l10n.logout, style: const TextStyle(color: Colors.red)),
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
                      final newL10n = AppLocalizations.of(context)!;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(newL10n.loggedOutSuccess,
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
                  final newL10n = AppLocalizations.of(context)!;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(newL10n.logoutFailed(e.toString()),
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

  void _confirmAccountDeletion(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.deleteAccountTitle),
        content: Text(l10n.deleteAccountMessage),
        actions: [
          TextButton(
            child: Text(l10n.cancel),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(l10n.delete,
                style: const TextStyle(color: Colors.redAccent)),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.accountDeleted)),
              );
              // TODO: Add actual deletion logic
            },
          ),
        ],
      ),
    );
  }
}
