import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';

ThemeData getDarkTheme(){


  var font = GetStorage().read('font') ?? "Inconsolata";


  return ThemeData(
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1C1B1B),
          foregroundColor:  Colors.white,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Color(0xFF1C1B1B),
          )
      ),
      cardTheme: const CardThemeData(color: Color.fromARGB(255, 37, 37, 37)),
      scaffoldBackgroundColor: const Color(0xFF1C1B1B),
      primaryColor: Colors.teal, // Your primary color for dark mode
      canvasColor:const Color.fromARGB(255, 37, 37, 37),
      focusColor: Colors.red,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.grey, // Use your primary color here
        accentColor: Colors.blueGrey,
        errorColor: Colors.blueGrey,
        backgroundColor: const Color(0xFF1C1B1B), // Your secondary color
      ), // Your accent color for dark mode
      textTheme: TextTheme(

          displayLarge: TextStyle(color:Colors.black, fontSize:36, fontWeight: FontWeight.w600, fontFamily: font),
          displaySmall: TextStyle(color: Colors.white, fontSize:16, fontWeight: FontWeight.w600, fontFamily: font),
          labelLarge: TextStyle(color: Colors.white, fontSize:26, fontWeight: FontWeight.w600,fontFamily: font),
          bodyLarge: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600,fontFamily: font), // Text color for dark theme
          bodyMedium: TextStyle(color: Colors.white, fontSize: 18,fontWeight: FontWeight.w500,fontFamily: font),
          bodySmall: TextStyle(color: Colors.white, fontSize: 16,fontWeight: FontWeight.w500,fontFamily: font),
          labelSmall: TextStyle(color: Colors.white, fontSize: 13,fontWeight: FontWeight.w500,fontFamily: font)
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(const Color.fromARGB(255, 37, 37, 37)),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
              ),
            ),
          )
      ),
      textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(const Color.fromARGB(255, 37, 37, 37)),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
              ),
            ),
          )
      ),
      popupMenuTheme: const PopupMenuThemeData(
        color: Color.fromARGB(255, 37, 37, 37),
        iconColor: Color.fromARGB(255, 37, 37, 37),
      ),
      iconTheme: const IconThemeData(color: Colors.blueGrey)
    // Add other dark theme properties here
  );
}