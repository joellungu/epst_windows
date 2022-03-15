import 'package:flutter/material.dart';
//import 'package:google_fonts/google_fonts.dart';

class ThemeClass {
  Map<int, Color> wB = {
    50: Color.fromRGBO(126, 212, 250, .1),
    100: Color.fromRGBO(126, 212, 250, .1),
    200: Color.fromRGBO(126, 212, 250, .1),
    300: Color.fromRGBO(126, 212, 250, .1),
    400: Color.fromRGBO(126, 212, 250, .1),
    500: Color.fromRGBO(126, 212, 250, .1),
    600: Color.fromRGBO(126, 212, 250, .1),
    700: Color.fromRGBO(126, 212, 250, .1),
    800: Color.fromRGBO(126, 212, 250, .1),
    900: Color.fromRGBO(126, 212, 250, .1),
  };

  var couleurB;

  ThemeClass() {
    couleurB = MaterialColor(Color.fromRGBO(126, 212, 250, .1).value, couleurB);
  }

  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.blue),
      ),
    ),
    //tabBarTheme: TabBarTheme(),
    textTheme: TextTheme(
        /*
      bodyText1: GoogleFonts.lato(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      subtitle1: GoogleFonts.lato(
        color: Colors.grey.shade500,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      */
        //
        // b: GoogleFonts.roboto(
        //   color: Colors.grey.shade700,
        //   fontSize: 14,
        //   fontWeight: FontWeight.bold,
        // ),
        ),
    colorScheme: ColorScheme.light(),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue.shade700,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.grey.shade700,
    textTheme: TextTheme(
        /*
      bodyText1: GoogleFonts.lato(
        color: Colors.grey.shade200,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      subtitle1: GoogleFonts.lato(
        color: Colors.grey.shade500,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      */
        //
        // titleMedium: GoogleFonts.lato(
        //   color: Colors.grey.shade500,
        //   fontSize: 14,
        //   fontWeight: FontWeight.bold,
        // ),
        ),
    colorScheme: ColorScheme.dark(),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey.shade900,
    ),
  );
}
