import 'package:flutter/widgets.dart';

const borderRad = BorderRadius.all(Radius.circular(15));
const weatherBlurColor = Color(0x32454545);

const theader =
    TextStyle(fontSize: 36, fontWeight: FontWeight.w800, fontFamily: "Outfit");
const twathertext = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontFamily: "Montserrat",
    color: Color(0xffffffff));

const twatherheader = TextStyle(
    fontSize: 64,
    fontWeight: FontWeight.w800,
    fontFamily: "Outfit",
    color: Color(0xffffffff));

const twardrobeTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    fontFamily: "Outfit",
    color: Color(0xff000000));

const weatherBlur = SizedBox(
  width: 220,
  height: 220,
  child: DecoratedBox(
      decoration:
          BoxDecoration(borderRadius: borderRad, color: weatherBlurColor)),
);
