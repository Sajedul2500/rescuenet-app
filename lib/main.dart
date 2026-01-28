import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/guards/registration_guard.dart';
import 'core/connectivity/connectivity_wrapper.dart';
import 'l10n/app_localizations.dart';

void main() => runApp(const RescueNetApp());

class RescueNetApp extends StatefulWidget {
  const RescueNetApp({super.key});

  @override
  State<RescueNetApp> createState() => _RescueNetAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _RescueNetAppState? state =
        context.findAncestorStateOfType<_RescueNetAppState>();
    state?.setLocale(newLocale);
  }
}

class _RescueNetAppState extends State<RescueNetApp> {
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('selectedLanguage');
    if (languageCode != null) {
      setState(() {
        // Map the stored language string to locale code
        if (languageCode.contains('Bangla') || languageCode.contains('বাংলা')) {
          _locale = const Locale('bn');
        } else {
          _locale = const Locale('en');
        }
      });
    }
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RescueNet',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('bn'), // Bangla
      ],
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
