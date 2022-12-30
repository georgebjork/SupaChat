
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class ThemeProvider extends ChangeNotifier{

  late ThemeData _themeData;
  late String key; 
  // True stands for dark and false stands for light
  late bool isDark;

  final _green = HexColor('#00b530');
  final _black = HexColor('#353333');
  final _grey = HexColor('#a6a6a6');
  

  ThemeProvider({required String key}){
    setTheme(key);
  }


  void setTheme(String theme){
    if(theme == "dark") {
      isDark = true;
      _themeData = appThemeDark;
    } else {
      isDark = false;
      _themeData = appThemeLight;
    }
    notifyListeners();
  }

  ThemeData getTheme(){
    return _themeData;
  }

  HexColor get green => _green;
  HexColor get black => _black;
  HexColor get grey => _grey;


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
    iconTheme: const IconThemeData(color: Colors.white),
    primaryColorDark: HexColor('#00b530'),
    appBarTheme: AppBarTheme(
      actionsIconTheme: const IconThemeData(color: Colors.white),
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
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: HexColor('#00b530')
    )
  );
}