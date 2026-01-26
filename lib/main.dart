import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/guards/registration_guard.dart';
import 'core/connectivity/connectivity_wrapper.dart';

void main() => runApp(const RescueNetApp());

class RescueNetApp extends StatelessWidget {
  const RescueNetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RescueNet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: GoogleFonts.poppins().fontFamily,
        primaryColor: const Color(0xFFD32F2F),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const ConnectivityWrapper(
        child: RegistrationGuard(), // Guard checks backend registration status
      ),
    );
  }
}
