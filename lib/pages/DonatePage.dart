import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DonatePage extends StatefulWidget {
  const DonatePage({super.key});

  @override
  State<DonatePage> createState() => _DonatePageState();
}

class _DonatePageState extends State<DonatePage> {
  String _selectedType = 'Money';
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  final List<String> donationTypes = [
    'Money',
    'Clothes',
    'Medicine',
    'Mineral Water',
    'Water Purification Tablets',
    'Dry Food',
    'Blankets'
  ];

  final List<String> paymentMethods = ['bKash', 'Nagad', 'Bank Transfer'];
  String _selectedPaymentMethod = 'bKash';
  final List<String> _donationHistory = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        centerTitle: true,
        title: Text(
          'Donate to Help',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Select Donation Type', style: _sectionTitleStyle()),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: _inputDecoration(),
              items: donationTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (val) => setState(() => _selectedType = val!),
            ),
            const SizedBox(height: 16),
            if (_selectedType == 'Money') ...[
              Text('Amount (BDT)', style: _sectionTitleStyle()),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(hint: 'Enter amount'),
              ),
              const SizedBox(height: 12),
              Text('Payment Method', style: _sectionTitleStyle()),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedPaymentMethod,
                decoration: _inputDecoration(),
                items: paymentMethods.map((method) {
                  return DropdownMenuItem(value: method, child: Text(method));
                }).toList(),
                onChanged: (val) => setState(() => _selectedPaymentMethod = val!),
              ),
            ] else ...[
              Text('Quantity / Description', style: _sectionTitleStyle()),
              const SizedBox(height: 8),
              TextField(
                controller: _quantityController,
                decoration: _inputDecoration(hint: 'e.g., 10 bottles, 5 packets'),
              ),
            ],
            const SizedBox(height: 16),
            Text('Note (optional)', style: _sectionTitleStyle()),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: _inputDecoration(hint: 'Any specific instruction'),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.volunteer_activism, color: Colors.white),
              label: const Text('Submit Donation', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: _submitDonation,
            ),
            const SizedBox(height: 24),
            if (_donationHistory.isNotEmpty) ...[
              Text('Donation History', style: _sectionTitleStyle()),
              const SizedBox(height: 8),
              ..._donationHistory.map((entry) => ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text(entry, style: GoogleFonts.poppins()),
              )),
            ]
          ],
        ),
      ),
    );
  }

  void _submitDonation() {
    String summary = _selectedType == 'Money'
        ? 'Donated ৳${_amountController.text} via $_selectedPaymentMethod'
        : 'Donated ${_quantityController.text} of $_selectedType';

    setState(() {
      _donationHistory.insert(0, summary);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Donation submitted! $summary')),
    );
    _amountController.clear();
    _quantityController.clear();
    _noteController.clear();
  }

  TextStyle _sectionTitleStyle() =>
      GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600);

  InputDecoration _inputDecoration({String hint = ''}) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}
