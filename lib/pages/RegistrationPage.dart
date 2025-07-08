import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'General User';
  final Map<String, TextEditingController> _controllers = {};
  final List<String> _genders = ['Male', 'Female', 'Other'];

  late AnimationController _formController;
  late Animation<Offset> _formSlideAnimation;
  late AnimationController _buttonController;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();

    _formController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _formSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeInOut,
    ));

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _buttonScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.elasticOut,
    ));

    // Trigger animations after short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      _formController.forward();
      _buttonController.forward();
    });
  }

  @override
  void dispose() {
    _formController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  TextEditingController _controller(String key) {
    return _controllers.putIfAbsent(key, () => TextEditingController());
  }

  Widget _buildTextField(String key, String label, {bool obscure = false, TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _controller(key),
        obscureText: obscure,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Please enter $label';
          return null;
        },
      ),
    );
  }

  Widget _buildDateField(String key, String label) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime(2000),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          _controller(key).text = picked.toString().split(" ")[0];
        }
      },
      child: AbsorbPointer(
        child: _buildTextField(key, label, type: TextInputType.datetime),
      ),
    );
  }

  Widget _buildDropdownField(String key, String label, List<String> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _controller(key).text.isEmpty ? null : _controller(key).text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
        onChanged: (val) {
          if (val != null) _controller(key).text = val;
        },
        validator: (value) => value == null || value.isEmpty ? 'Select $label' : null,
      ),
    );
  }

  Widget _buildUploadNote(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.attachment, color: Colors.grey),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return ExpansionTile(
      initiallyExpanded: true,
      title: Text(
        title,
        style: GoogleFonts.poppins(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
      children: children,
    );
  }

  Widget _buildGeneralUserForm() {
    return Column(
      children: [
        _section("Personal Information", [
          _buildTextField('fullName', 'Full Name'),
          _buildDropdownField('gender', 'Gender', _genders),
          _buildDateField('dob', 'Date of Birth'),
          _buildTextField('nid', 'NID Number'),
          _buildUploadNote('Upload NID (Front Side)'),
          _buildUploadNote('Upload NID (Back Side) (Optional)'),
          _buildUploadNote('Upload Selfie Holding NID (Optional)'),
        ]),
        _section("Contact Information", [
          _buildTextField('mobile', 'Mobile Number', type: TextInputType.phone),
          _buildTextField('otp', 'OTP Verification'),
          _buildTextField('email', 'Email Address', type: TextInputType.emailAddress),
          _buildTextField('address', 'Present Address'),
          _buildTextField('district', 'District / Division'),
        ]),
        _section("Account Information", [
          _buildTextField('username', 'Username'),
          _buildTextField('password', 'Password', obscure: true),
        ]),
      ],
    );
  }

  Widget _buildOrganizationForm() {
    return Column(
      children: [
        _section("Organization Information", [
          _buildTextField('orgName', 'Organization Name'),
          _buildTextField('orgType', 'Type of Organization'),
          _buildTextField('orgReg', 'Registration Number'),
          _buildTextField('orgAuthority', 'Registration Authority'),
          _buildTextField('orgYear', 'Year of Establishment', type: TextInputType.number),
        ]),
        _section("Contact Details", [
          _buildTextField('orgAddress', 'Head Office Address'),
          _buildTextField('orgDistrict', 'District / Division'),
          _buildTextField('orgEmail', 'Official Email', type: TextInputType.emailAddress),
          _buildTextField('orgPhone', 'Phone Number'),
          _buildTextField('orgWebsite', 'Website/Social Media Page'),
        ]),
        _section("Responsible Person", [
          _buildTextField('resPerson', 'Authorized Person Name'),
          _buildTextField('resRole', 'Designation/Role'),
          _buildTextField('resNID', 'NID or Passport Number'),
          _buildTextField('resPhone', 'Phone Number'),
          _buildTextField('resEmail', 'Email Address'),
        ]),
        _section("Document Uploads", [
          _buildUploadNote('Registration Certificate'),
          _buildUploadNote('NID/Passport of Responsible Person'),
          _buildUploadNote('Office Address Proof'),
          _buildUploadNote('TIN Certificate (Optional)'),
          _buildUploadNote('Recent Activity Proof (Optional)'),
        ]),
        _section("Account Information", [
          _buildTextField('orgUsername', 'Username'),
          _buildTextField('orgPassword', 'Password', obscure: true),
        ]),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Form submitted successfully!'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
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
          'User Registration',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: SlideTransition(
            position: _formSlideAnimation,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Registration Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'General User', child: Text('General User')),
                    DropdownMenuItem(value: 'Organization', child: Text('Organization')),
                  ],
                  onChanged: (value) => setState(() => _selectedType = value!),
                ),
                const SizedBox(height: 16),
                _selectedType == 'General User'
                    ? _buildGeneralUserForm()
                    : _buildOrganizationForm(),
                const SizedBox(height: 20),
                ScaleTransition(
                  scale: _buttonScaleAnimation,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    ),
                    child: const Text('Submit'),
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
