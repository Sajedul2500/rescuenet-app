import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:RescueNetApp/pages/HelpRequestHistoryPage.dart';
import 'package:RescueNetApp/pages/NearByVolunteersPage.dart';
import 'package:RescueNetApp/pages/NearByRequestPage.dart';
import 'package:RescueNetApp/pages/EmergencyContactPage.dart';
import 'package:RescueNetApp/pages/AIChatBotPage.dart';
import 'package:RescueNetApp/pages/DonatePage.dart';
import 'package:RescueNetApp/pages/SettingPage.dart';
import 'more_menu_item.dart';

/// Modal bottom sheet that displays secondary (non-emergency) actions.
/// Moved AI Chat and Contacts here as part of emergency-first UX refactor.
class MoreBottomSheet extends StatelessWidget {
  const MoreBottomSheet({super.key});

  /// Shows the bottom sheet with slide animation from bottom.
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => const MoreBottomSheet(),
    );
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.pop(context); // Close bottom sheet first
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'More Options',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Scrollable menu items
              Expanded(
                child: GridView.count(
                  controller: scrollController,
                  crossAxisCount: 3,
                  padding: const EdgeInsets.all(16),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.95,
                  children: [
                    MoreMenuItem(
                      icon: Icons.chat_bubble_outline,
                      label: 'AI Chat',
                      iconColor: Colors.blue,
                      onTap: () => _navigateToPage(
                        context,
                        const AIChatBotPage(),
                      ),
                    ),
                    MoreMenuItem(
                      icon: Icons.contact_emergency,
                      label: 'Contacts',
                      iconColor: Colors.teal,
                      onTap: () => _navigateToPage(
                        context,
                        const EmergencyContactPage(),
                      ),
                    ),
                    MoreMenuItem(
                      icon: Icons.history,
                      label: 'Request History',
                      onTap: () => _navigateToPage(
                        context,
                        const HelpRequestHistoryPage(),
                      ),
                    ),
                    MoreMenuItem(
                      icon: Icons.people,
                      label: 'Nearby Volunteers',
                      iconColor: Colors.orange,
                      onTap: () => _navigateToPage(
                        context,
                        const NearByVolunteersPage(),
                      ),
                    ),
                    MoreMenuItem(
                      icon: Icons.map,
                      label: 'Nearby Requests',
                      iconColor: Colors.brown,
                      onTap: () => _navigateToPage(
                        context,
                        const NearByRequestPage(),
                      ),
                    ),
                    MoreMenuItem(
                      icon: Icons.favorite,
                      label: 'Donate',
                      iconColor: Colors.pink,
                      onTap: () => _navigateToPage(
                        context,
                        const DonatePage(),
                      ),
                    ),
                    MoreMenuItem(
                      icon: Icons.settings,
                      label: 'Settings',
                      iconColor: Colors.grey[700],
                      onTap: () => _navigateToPage(
                        context,
                        const SettingPage(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
