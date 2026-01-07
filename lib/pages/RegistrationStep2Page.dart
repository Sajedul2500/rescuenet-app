import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'RegistrationStep3Page.dart';
import '../features/registration/data/services/registration_service.dart';
import '../features/registration/domain/models/registration_models.dart';

class RegistrationStep2Page extends StatefulWidget {
  final Map<String, dynamic> registrationData;

  const RegistrationStep2Page({super.key, required this.registrationData});

  @override
  State<RegistrationStep2Page> createState() => _RegistrationStep2PageState();
}

class _RegistrationStep2PageState extends State<RegistrationStep2Page>
    with TickerProviderStateMixin {
  final RegistrationService _registrationService = RegistrationService();
  final ImagePicker _picker = ImagePicker();

  File? _nidFrontImage;
  File? _nidBackImage;
  File? _selfieWithNidImage;
  bool _isSubmitting = false;

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
    try {
      // Show source selection dialog
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Select Image Source',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFFD32F2F)),
                title: Text('Camera', style: GoogleFonts.poppins()),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading:
                    const Icon(Icons.photo_library, color: Color(0xFFD32F2F)),
                title: Text('Gallery', style: GoogleFonts.poppins()),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      // Pick image
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      // Validate file size (max 5MB = 5120 KB)
      final File file = File(pickedFile.path);
      final int fileSizeInBytes = await file.length();
      final double fileSizeInKB = fileSizeInBytes / 1024;
      final double fileSizeInMB = fileSizeInKB / 1024;

      if (fileSizeInKB > 5120) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Image size (${fileSizeInMB.toStringAsFixed(2)} MB) exceeds 5 MB limit',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validate file type
      final String extension = pickedFile.path.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png'].contains(extension)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Invalid file type. Only JPEG and PNG are allowed',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Update state with selected image
      setState(() {
        if (type == 'front') {
          _nidFrontImage = file;
        } else if (type == 'back') {
          _nidBackImage = file;
        } else if (type == 'selfie') {
          _selfieWithNidImage = file;
        }
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Image selected (${fileSizeInMB.toStringAsFixed(2)} MB)',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error picking image: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
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

  void _proceedToNextStep() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      // Prepare Step 2 data with File objects directly
      final step2Data = Step2Data(
        nidFrontImage: _nidFrontImage,
        nidBackImage: _nidBackImage,
        selfieWithNidImage: _selfieWithNidImage,
      );

      // Submit to backend
      final response = await _registrationService.submitStep2(step2Data);

      if (!mounted) return;

      if (response.success) {
        // Success - Navigate to Step 3
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(response.message ?? 'Verification documents submitted!'),
            backgroundColor: Colors.green,
          ),
        );

        final updatedData = {
          ...widget.registrationData,
          'verificationSkipped': false,
          'verificationCompleted': true,
        };

        Navigator.pushReplacement(
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Failed to submit verification'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _skipVerification() async {
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
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              navigator.pop(); // Close dialog

              setState(() {
                _isSubmitting = true;
              });

              try {
                // Call skip API
                final response = await _registrationService.skipStep2();

                if (!mounted) return;

                if (response.success) {
                  final updatedData = {
                    ...widget.registrationData,
                    'verificationSkipped': true,
                  };

                  // Navigate without calling setState after
                  navigator.pushReplacement(
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 600),
                      pageBuilder: (_, __, ___) =>
                          RegistrationStep3Page(registrationData: updatedData),
                      transitionsBuilder: (_, animation, __, child) {
                        return SlideTransition(
                          position:
                              Tween(begin: const Offset(1, 0), end: Offset.zero)
                                  .chain(CurveTween(curve: Curves.easeOut))
                                  .animate(animation),
                          child: child,
                        );
                      },
                    ),
                  );
                } else {
                  if (mounted) {
                    setState(() {
                      _isSubmitting = false;
                    });
                  }
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                          response.message ?? 'Failed to skip verification'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  setState(() {
                    _isSubmitting = false;
                  });
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
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
    required File? imagePath,
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
              FutureBuilder<int>(
                future: imagePath.length(),
                builder: (context, snapshot) {
                  final sizeText = snapshot.hasData
                      ? '${(snapshot.data! / 1024 / 1024).toStringAsFixed(2)} MB'
                      : 'Loading...';
                  return Container(
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                imagePath.path.split('/').last,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.green[900],
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                sizeText,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: onRemoveImage,
                          icon: const Icon(Icons.close, color: Colors.red),
                          tooltip: 'Remove',
                        ),
                      ],
                    ),
                  );
                },
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
                  onPressed: _isSubmitting ? null : _proceedToNextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
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
                  onPressed: _isSubmitting ? null : _skipVerification,
                  child: Text(
                    'Skip for Now',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color:
                          _isSubmitting ? Colors.grey[400] : Colors.grey[700],
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
