import 'package:flutter/material.dart';
import 'pages/login_page.dart';

void main() {
  // Good practice when using plugins (geolocator, recorder, etc.)
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ClientTrackingApp());
}

class ClientTrackingApp extends StatelessWidget {
  const ClientTrackingApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Start from the built-in dark theme + Material 3
    final base = ThemeData.dark(useMaterial3: true);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Client Tracking App',
      theme: base.copyWith(
        scaffoldBackgroundColor: const Color(0xFF050816), // deep dark bg

        colorScheme: base.colorScheme.copyWith(
          primary: const Color(0xFF7C3AED),   // purple accent
          secondary: const Color(0xFF22C55E), // green accent
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),

        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF111827),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Color(0xFF374151)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Color(0xFF374151)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Color(0xFF7C3AED), width: 1.6),
          ),
          labelStyle: TextStyle(color: Color(0xFF9CA3AF)),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7C3AED),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}
