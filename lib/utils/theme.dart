import 'package:flutter/widgets.dart';

const borderRad = BorderRadius.all(Radius.circular(15));
const weatherBlurColor = Color.fromARGB(70, 69, 69, 69);

const theader = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    fontFamily: "Outfit",
    color: Color(0xff000000));
const twathertext = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontFamily: "Montserrat",
    color: Color(0xffffffff));

const twardrobedatetext = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    fontFamily: "Montserrat",
    color: Color(0xff8F8F8F));

const taddingfieldname = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    fontFamily: "Montserrat",
    color: Color(0xff000000));

const twardrobetext = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFamily: "Montserrat",
    color: Color(0xff101010));

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

const twardrobeTabs = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontFamily: "Montserrat",
    color: Color(0xff000000));

const twardrobeTabsGray = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontFamily: "Montserrat",
    color: Color(0xff8F8F8F));

const tforecastHourly = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    fontFamily: "Outfit",
    color: Color(0xff000000));

const twardrobeoutfitname = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    fontFamily: "Montserrat",
    color: Color(0xffffffff));

const taddingtopbar = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    fontFamily: "Montserrat",
    color: Color(0xff101010));

const weatherBlur = SizedBox(
  width: 220,
  height: 220,
  child: DecoratedBox(
      decoration:
          BoxDecoration(borderRadius: borderRad, color: weatherBlurColor)),
);
