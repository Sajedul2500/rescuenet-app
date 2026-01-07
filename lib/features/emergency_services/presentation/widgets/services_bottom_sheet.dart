import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/emergency_service.dart';
import '../screens/emergency_service_list_screen.dart';
import 'service_category_tile.dart';

/// Modal bottom sheet for displaying emergency service categories.
/// Lightweight launcher that opens service listing pages.
class ServicesBottomSheet extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String? placeName;

  const ServicesBottomSheet({
    super.key,
    required this.latitude,
    required this.longitude,
    this.placeName,
  });

  /// Shows the services bottom sheet
  static void show(
    BuildContext context, {
    required double latitude,
    required double longitude,
    String? placeName,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => ServicesBottomSheet(
        latitude: latitude,
        longitude: longitude,
        placeName: placeName,
      ),
    );
  }

  void _navigateToServiceList(
    BuildContext context,
    String serviceType,
    String title,
  ) {
    Navigator.pop(context); // Close bottom sheet first
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmergencyServiceListScreen(
          serviceType: serviceType,
          latitude: latitude,
          longitude: longitude,
          placeName: placeName,
          title: title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.8,
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Emergency Services',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (placeName != null)
                          Text(
                            'Near $placeName',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
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
              // Service categories
              Expanded(
                child: GridView.count(
                  controller: scrollController,
                  crossAxisCount: 3,
                  padding: const EdgeInsets.all(16),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.95,
                  children: [
                    // Primary Categories
                    ServiceCategoryTile(
                      icon: Icons.local_police,
                      label: 'Police Stations',
                      iconColor: Colors.blue[700],
                      onTap: () => _navigateToServiceList(
                        context,
                        ServiceType.police,
                        'Police Stations',
                      ),
                    ),
                    ServiceCategoryTile(
                      icon: Icons.local_fire_department,
                      label: 'Fire Stations',
                      iconColor: Colors.red[700],
                      onTap: () => _navigateToServiceList(
                        context,
                        ServiceType.fire,
                        'Fire Stations',
                      ),
                    ),
                    ServiceCategoryTile(
                      icon: Icons.local_hospital,
                      label: 'Medical / Hospitals',
                      iconColor: Colors.green[700],
                      onTap: () => _navigateToServiceList(
                        context,
                        ServiceType.medical,
                        'Medical / Hospitals',
                      ),
                    ),
                    ServiceCategoryTile(
                      icon: Icons.home,
                      label: 'Emergency Shelters',
                      iconColor: Colors.orange[700],
                      onTap: () => _navigateToServiceList(
                        context,
                        ServiceType.shelter,
                        'Emergency Shelters',
                      ),
                    ),
                    // Secondary Categories (can be loaded dynamically based on preferences)
                    ServiceCategoryTile(
                      icon: Icons.bloodtype,
                      label: 'Blood Banks',
                      iconColor: Colors.red[900],
                      onTap: () => _navigateToServiceList(
                        context,
                        ServiceType.bloodBank,
                        'Blood Banks',
                      ),
                    ),
                    ServiceCategoryTile(
                      icon: Icons.volunteer_activism,
                      label: 'NGOs',
                      iconColor: Colors.purple[700],
                      onTap: () => _navigateToServiceList(
                        context,
                        ServiceType.ngo,
                        'NGOs',
                      ),
                    ),
                    ServiceCategoryTile(
                      icon: Icons.campaign,
                      label: 'Relief Centers',
                      iconColor: Colors.teal[700],
                      onTap: () => _navigateToServiceList(
                        context,
                        ServiceType.reliefCenter,
                        'Relief Centers',
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
