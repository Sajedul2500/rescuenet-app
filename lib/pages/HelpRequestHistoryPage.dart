import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../features/dashboard/data/services/dashboard_service.dart';
import '../core/api/api_service.dart';
import '../core/api/api_response.dart';

class HelpRequestHistoryPage extends StatefulWidget {
  const HelpRequestHistoryPage({super.key});

  @override
  State<HelpRequestHistoryPage> createState() => _HelpRequestHistoryPageState();
}

class _HelpRequestHistoryPageState extends State<HelpRequestHistoryPage> {
  final ApiService _apiService = ApiService();
  List<HelpRequest> _requests = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/help-requests',
        parser: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final helpRequests = (response.data!['help_requests'] as List?)
                ?.map((e) => HelpRequest.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];

        setState(() {
          _requests = helpRequests;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message ?? 'Failed to load history';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'fire':
        return FontAwesomeIcons.fireExtinguisher;
      case 'ambulance':
      case 'medical':
        return FontAwesomeIcons.truckMedical;
      case 'police':
        return FontAwesomeIcons.shieldHalved;
      case 'rescue':
        return FontAwesomeIcons.personSwimming;
      case 'food':
        return FontAwesomeIcons.bowlFood;
      case 'shelter':
        return FontAwesomeIcons.houseChimney;
      default:
        return FontAwesomeIcons.handHoldingHeart;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
      case 'in_progress':
        return Colors.blue;
      case 'resolved':
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchHistory,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFFD32F2F),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading your history...',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to Load',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchHistory,
                icon: const Icon(Icons.refresh),
                label: Text(
                  'Retry',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_requests.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history,
                size: 80,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'No History Yet',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your help request history will appear here.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchHistory,
      color: const Color(0xFFD32F2F),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          final request = _requests[index];
          return _buildHistoryCard(request);
        },
      ),
    );
  }

  Widget _buildHistoryCard(HelpRequest request) {
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
                Icon(
                  _getCategoryIcon(request.category),
                  size: 30,
                  color: Colors.black87,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    request.category.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(request.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    request.status.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(request.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '📝 ${request.description}',
              style: GoogleFonts.poppins(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 8),
            if (request.location != null)
              Text(
                '📍 ${request.location}',
                style:
                    GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
              ),
            const SizedBox(height: 4),
            Text(
              '🕒 ${request.timeAgo}',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
            ),
            const SizedBox(height: 4),
            Text(
              '👤 Requested by: ${request.userName}',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}
