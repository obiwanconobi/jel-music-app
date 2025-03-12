
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';

ThemeData getLightTheme(){

  var font = GetStorage().read('font') ?? "Inconsolata";

  return ThemeData(
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromARGB(255, 204, 204, 204),
        foregroundColor:  Colors.black,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Color.fromARGB(255, 204, 204, 204),
        )
    ),
    cardTheme: const CardTheme(color: Color.fromARGB(255, 179, 179, 179)),
    scaffoldBackgroundColor:const Color.fromARGB(255, 204, 204, 204),
    primaryColor: Colors.teal, // Your primary color for dark mode
    canvasColor:const Color.fromARGB(255, 179, 179, 179),
    focusColor: Colors.red,
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.grey, // Use your primary color here
      accentColor: const Color.fromARGB(255, 69, 69, 69),
      backgroundColor: const Color.fromARGB(255, 204, 204, 204), // Your secondary color
    ), // Your accent color for dark mode
    popupMenuTheme: const PopupMenuThemeData(
      color: Color.fromARGB(255, 179, 179, 179),
      iconColor: Color.fromARGB(255, 179, 179, 179),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor:  WidgetStateProperty.all<Color>(const Color.fromARGB(255, 179, 179, 179)),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
            ),
          ),
        )
    ),
    textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(const Color.fromARGB(255, 179, 179, 179)),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
            ),
          ),
        )
    ),
    textTheme: TextTheme(
        displayLarge: TextStyle(color:Colors.black, fontSize:36, fontWeight: FontWeight.w600, fontFamily: font),
        displaySmall: TextStyle(color: Colors.black, fontSize:16, fontWeight: FontWeight.w600, fontFamily: font),
        labelLarge: TextStyle(color: Colors.black, fontSize:26, fontWeight: FontWeight.w600, fontFamily: font),
        bodyLarge: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600, fontFamily: font), // Text color for dark theme
        bodyMedium: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500, fontFamily: font),
        bodySmall: TextStyle(color: Colors.black, fontSize: 16,fontWeight: FontWeight.w500,fontFamily: font),
        labelSmall: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w500, fontFamily: font)
    ),
    // Add other dark theme properties here
  );
}
