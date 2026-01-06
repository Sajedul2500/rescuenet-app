import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'RegistrationStep3Page.dart';

class RegistrationStep2Page extends StatefulWidget {
  final Map<String, dynamic> registrationData;

  const RegistrationStep2Page({super.key, required this.registrationData});

  @override
  State<RegistrationStep2Page> createState() => _RegistrationStep2PageState();
}

class _RegistrationStep2PageState extends State<RegistrationStep2Page>
    with TickerProviderStateMixin {
  String? _nidFrontImage;
  String? _nidBackImage;
  String? _selfieWithNidImage;

  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeIn,
      ),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String type) async {
    // TODO: Implement image picker
    // For now, we'll simulate image selection
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Image Picker'),
        content: const Text(
            'Image picker will be implemented with image_picker package.\nFor now, this is a placeholder.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                if (type == 'front') {
                  _nidFrontImage =
                      'nid_front_${DateTime.now().millisecondsSinceEpoch}.jpg';
                } else if (type == 'back') {
                  _nidBackImage =
                      'nid_back_${DateTime.now().millisecondsSinceEpoch}.jpg';
                } else if (type == 'selfie') {
                  _selfieWithNidImage =
                      'selfie_nid_${DateTime.now().millisecondsSinceEpoch}.jpg';
                }
              });
            },
            child: const Text('Simulate Image Selected'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _removeImage(String type) {
    setState(() {
      if (type == 'front') {
        _nidFrontImage = null;
      } else if (type == 'back') {
        _nidBackImage = null;
      } else if (type == 'selfie') {
        _selfieWithNidImage = null;
      }
    });
  }

  void _proceedToNextStep() {
    // Add verification data to registration data
    final updatedData = {
      ...widget.registrationData,
      'nidFrontImage': _nidFrontImage,
      'nidBackImage': _nidBackImage,
      'selfieWithNidImage': _selfieWithNidImage,
      'verificationSkipped': _nidFrontImage == null,
    };

    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) =>
            RegistrationStep3Page(registrationData: updatedData),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween(begin: const Offset(1, 0), end: Offset.zero)
                .chain(CurveTween(curve: Curves.easeOut))
                .animate(animation),
            child: child,
          );
        },
      ),
    );
  }

  void _skipVerification() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Skip Verification?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'You can complete verification later from your profile settings. Some features may be limited until verified.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _proceedToNextStep();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
            ),
            child: const Text('Skip for Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadCard({
    required String title,
    required String description,
    required String? imagePath,
    required VoidCallback onPickImage,
    required VoidCallback onRemoveImage,
    bool isRequired = false,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isRequired)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Recommended',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.orange[900],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            if (imagePath == null)
              OutlinedButton.icon(
                onPressed: onPickImage,
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Upload Image'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFD32F2F),
                  side: const BorderSide(color: Color(0xFFD32F2F)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Image uploaded',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.green[900],
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onRemoveImage,
                      icon: const Icon(Icons.close, color: Colors.red),
                      tooltip: 'Remove',
                    ),
                  ],
                ),
              ),
          ],
        ),
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
          'Registration - Step 2 of 3',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  'Identity Verification',
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload your NID documents for verification (Optional)',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Verification helps us ensure the safety of our community. You can skip this step and verify later.',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // NID Front Image Upload
                _buildImageUploadCard(
                  title: 'NID Front Side',
                  description: 'Upload the front side of your National ID card',
                  imagePath: _nidFrontImage,
                  onPickImage: () => _pickImage('front'),
                  onRemoveImage: () => _removeImage('front'),
                  isRequired: true,
                ),
                const SizedBox(height: 16),

                // NID Back Image Upload
                _buildImageUploadCard(
                  title: 'NID Back Side',
                  description: 'Upload the back side of your National ID card',
                  imagePath: _nidBackImage,
                  onPickImage: () => _pickImage('back'),
                  onRemoveImage: () => _removeImage('back'),
                ),
                const SizedBox(height: 16),

                // Selfie with NID Upload
                _buildImageUploadCard(
                  title: 'Selfie Holding NID',
                  description:
                      'Take a selfie while holding your NID card next to your face',
                  imagePath: _selfieWithNidImage,
                  onPickImage: () => _pickImage('selfie'),
                  onRemoveImage: () => _removeImage('selfie'),
                  isRequired: true,
                ),
                const SizedBox(height: 32),

                // Continue Button
                ElevatedButton(
                  onPressed: _proceedToNextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Skip Button
                TextButton(
                  onPressed: _skipVerification,
                  child: Text(
                    'Skip for Now',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
