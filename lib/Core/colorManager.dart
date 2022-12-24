import 'package:flutter/material.dart';

class ColorManager {
  static Color primary = Colors.orange[600];
  static Color backGroundColor = Colors.white;
  static Color accentColor = Colors.black;
  static Color darkGrey = HexColor.fromHex("#525252");
  static Color grey = HexColor.fromHex("#737477");
  static Color lightGrey = HexColor.fromHex("#9E9E9E");
  static Color primaryOpacity70 = HexColor.fromHex("#B3ED9728");
  static Color googleRed = const Color(0xffE34233);
  static Color googleGreen = const Color(0xff4DB749);
  static Color googleYellow = const Color(0xffF7C83F);
  static Color googleBlue = const Color(0xff1A73E8);
}

extension HexColor on Color {
  static Color fromHex(String hexColorString) {
    hexColorString = hexColorString.replaceAll('#', '');
    if (hexColorString.length == 6) {
      hexColorString = "FF" + hexColorString; // 8 char with opacity 100%
    }
    return Color(int.parse(hexColorString, radix: 16));
  }
}
