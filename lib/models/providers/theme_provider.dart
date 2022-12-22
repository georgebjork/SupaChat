
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class ThemeProvider extends ChangeNotifier{

  late ThemeData _themeData;
  late String key; 

  ThemeProvider({required String key}){
    setTheme(key);
  }


  void setTheme(String theme){
    if(theme == "dark") {
      _themeData = appThemeDark;
    } else {
      _themeData = appThemeLight;
    }
    notifyListeners();
  }

  ThemeData getTheme(){
    return _themeData;
  }


  // Light theme, but not as loved.
  static final appThemeLight = ThemeData.light().copyWith(
    primaryColorDark: HexColor('#00b530'),
    appBarTheme: const AppBarTheme(
      elevation: 1,
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 18,
      ),
    ),
    primaryColor: HexColor('#00b530'),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: HexColor('#00b530'),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: HexColor('#00b530'),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      floatingLabelStyle: TextStyle(
        color: HexColor('#00b530'),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.grey,
          width: 2,
        ),
      ),
      focusColor: HexColor('#00b530'),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: HexColor('#00b530'),
          width: 2,
        ),
      ),
    ),
  );

  //Dark theme because we love that!
  static final appThemeDark = ThemeData.dark().copyWith(
    primaryColorDark: HexColor('#00b530'),
    appBarTheme: AppBarTheme(
      elevation: 1,
      backgroundColor: HexColor('#353333'),
      iconTheme: const IconThemeData(color: Colors.black),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 18,
      ),
    ),
    primaryColor: HexColor('#00b530'),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: HexColor('#00b530'),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: HexColor('#353333'),
        backgroundColor: HexColor('#00b530'),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      floatingLabelStyle: TextStyle(
        color: HexColor('#00b530'),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.grey,
          width: 2,
        ),
      ),
      focusColor: HexColor('#00b530'),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: HexColor('#00b530'),
          width: 2,
        ),
      ),
    ),
  );
}