import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:outfy/utils/theme.dart';

const container_padding =
    const EdgeInsets.symmetric(vertical: 11, horizontal: 16);
const container_decoration = const BoxDecoration(
    boxShadow: [
      BoxShadow(blurRadius: 4, offset: Offset(0, 4), color: Color(0x1a000000))
    ],
    color: Color(0xffF8F8F8),
    borderRadius: BorderRadius.all(Radius.circular(12)));

class WeatherCard extends StatelessWidget {
  final String MaxAndMin, text_date, icon_path;
  final DateTime date;
  const WeatherCard(
      {super.key,
      this.MaxAndMin = "",
      required this.date,
      this.text_date = "",
      this.icon_path = "assets/images/cloudy-icon2.png"});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: container_decoration,
        margin: const EdgeInsets.all(10),
        child: Padding(
          padding: container_padding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Column(
                children: [
                  Text(text_date, style: twardrobetext),
                  Text(MaxAndMin, style: twardrobetext)
                ],
              ),
              Text(DateFormat('d LLLL', 'ru').format(date),
                  style: twardrobedatetext),
              Center(
                  child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Image.asset(
                  icon_path,
                  width: 36,
                ),
              ))
            ],
          ),
        ));
  }
}
