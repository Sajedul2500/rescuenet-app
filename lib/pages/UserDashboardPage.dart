import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'AlertPage.dart';
import 'DonatePage.dart';
import 'EmergencyContactPage.dart';
import 'HelpRequestHistoryPage.dart';
import 'NearByRequestPage.dart';
import 'NearByVolunteersPage.dart';
import 'SettingPage.dart';
import 'UserProfilePage.dart';
import 'AIChatBotPage.dart';

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> with TickerProviderStateMixin {
  String _selectedSupport = 'Police';
  String? _selectedAttachmentType;
  final TextEditingController _descriptionController = TextEditingController();
  int _currentNewsIndex = 0;
  bool _isSending = false;
  final String userName = 'Sajedul';

  late AnimationController _headerController;
  late Animation<Offset> _headerSlide;
  late Animation<double> _headerFade;

  final List<String> newsItems = [
    '⛈️ Heavy rainfall warning in Chittagong. Avoid flood-prone areas.',
    '🔥 Fire alert in Mirpur 10 market area. Evacuate safely.',
    '🚨 Earthquake drill ongoing in Dhaka North area.',
    '💉 Emergency blood donation camp at City Hospital this Friday.'
  ];

  final List<Map<String, dynamic>> supportOptions = [
    {'label': 'Police', 'icon': FontAwesomeIcons.shieldHalved, 'color': Colors.blue},
    {'label': 'Fire', 'icon': FontAwesomeIcons.fireExtinguisher, 'color': Colors.red},
    {'label': 'Ambulance', 'icon': FontAwesomeIcons.truckMedical, 'color': Colors.green},
    {'label': 'Volunteer', 'icon': FontAwesomeIcons.userLarge, 'color': Colors.deepPurple},
  ];

  final List<Map<String, dynamic>> attachmentOptions = [
    {'label': 'Image', 'icon': Icons.image, 'color': Colors.teal},
    {'label': 'Audio', 'icon': Icons.audiotrack, 'color': Colors.deepOrange},
    {'label': 'Video', 'icon': Icons.videocam, 'color': Colors.indigo},
  ];

  final List<Map<String, dynamic>> moreOptions = [
    {'label': 'Request History', 'icon': Icons.history, 'color': Colors.indigo, 'page': const HelpRequestHistoryPage()},
    {'label': 'Nearby Volunteers', 'icon': Icons.group, 'color': Colors.orange, 'page': NearByVolunteersPage()},
    {'label': 'Nearby Requests', 'icon': Icons.map, 'color': Colors.brown, 'page': const NearByRequestPage()},
    {'label': 'AI Chat Bot', 'icon': Icons.smart_toy, 'color': Colors.deepOrange, 'page': const AIChatBotPage()},
    {'label': 'Alerts', 'icon': Icons.warning_amber, 'color': Colors.amber, 'page': const AlertPage()},
    {'label': 'Emergency Contact', 'icon': Icons.contact_emergency, 'color': Colors.teal, 'page': const EmergencyContactPage()},
    {'label': 'Donate', 'icon': Icons.volunteer_activism, 'color': Colors.pink, 'page': const DonatePage()},
    {'label': 'Settings', 'icon': Icons.settings, 'color': Colors.grey, 'page': const SettingPage()},
  ];

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerController, curve: Curves.easeOut));
    _headerFade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _headerController, curve: Curves.easeIn));
    _headerController.forward();

    Timer.periodic(const Duration(seconds: 4), (timer) {
      setState(() {
        _currentNewsIndex = (_currentNewsIndex + 1) % newsItems.length;
      });
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _headerController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 20),
          children: [
            _buildHeaderSection(),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildRotatingNewsCard(),
            ),
            const SizedBox(height: 20),
            _buildSection('🚨 Request Support', supportOptions, isSupport: true),
            _buildSection('📎 Attach Proof', attachmentOptions, isAttachment: true),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildDescriptionField(),
            ),
            const SizedBox(height: 10),
            _buildHelpButton(),
            const SizedBox(height: 30),
            _buildSection('➕ More Options', moreOptions),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return SlideTransition(
      position: _headerSlide,
      child: FadeTransition(
        opacity: _headerFade,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFFD32F2F),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_getGreeting(),
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(userName,
                    style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              ]),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const UserProfilePage()));
                },
                child: Hero(
                  tag: 'profileAvatar',
                  child: const CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage('assets/images/profile.JPG'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRotatingNewsCard() {
    return Container(
      height: 130,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.campaign, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              transitionBuilder: (child, animation) => SlideTransition(
                position: Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero).animate(animation),
                child: child,
              ),
              child: Text(
                newsItems[_currentNewsIndex],
                key: ValueKey(_currentNewsIndex),
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.red.shade900),
              ),
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.close, size: 18)),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Map<String, dynamic>> options, {bool isSupport = false, bool isAttachment = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
          ),
          child: _buildOptionsGrid(options, isSupport: isSupport, isAttachment: isAttachment),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
      ),
    );
  }

  Widget _buildOptionsGrid(List<Map<String, dynamic>> options, {bool isSupport = false, bool isAttachment = false}) {
    final crossAxisCount = isAttachment ? 3 : 4;
    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.75,
      children: options.map((option) {
        final label = option['label'];
        final icon = option['icon'] as IconData;
        final color = option['color'] as Color;
        final isSelected = isSupport
            ? label == _selectedSupport
            : isAttachment
            ? label == _selectedAttachmentType
            : false;

        return buildOptionItem(
          label: label,
          icon: icon,
          color: color,
          isSelected: isSelected,
          onTap: () {
            setState(() {
              if (isSupport) {
                _selectedSupport = label;
              } else if (isAttachment) {
                _selectedAttachmentType = label;
              } else {
                final page = option['page'];
                if (page != null) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => page));
                }
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget buildOptionItem({required String label, required IconData icon, required Color color, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? color : Colors.grey[100],
              border: Border.all(color: isSelected ? color : Colors.grey.shade300),
              boxShadow: isSelected
                  ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 3))]
                  : [],
            ),
            child: Icon(icon, color: isSelected ? Colors.white : color, size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? color : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextField(
      controller: _descriptionController,
      maxLines: 2,
      decoration: InputDecoration(
        hintText: 'Describe your situation briefly...',
        filled: true,
        fillColor: const Color(0xFFF0F0F0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildHelpButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _isSending ? null : _confirmSendHelp,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD32F2F),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isSending
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
            'SEND HELP REQUEST',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 16,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  void _confirmSendHelp() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Help Request'),
        content: Text(
          'Do you want to send a help request for $_selectedSupport'
              '${_selectedAttachmentType != null ? ' with $_selectedAttachmentType proof' : ''}?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _sendHelpRequest();
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _sendHelpRequest() async {
    setState(() => _isSending = true);
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    setState(() {
      _isSending = false;
      _descriptionController.clear();
      _selectedAttachmentType = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Help request sent to $_selectedSupport'),
    ));
  }
}
