import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


import 'Step1.dart';



void main() {

  runApp(StravaWrappedApp());
}

class StravaWrappedApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: UploadScreen(),
    );
  }
}