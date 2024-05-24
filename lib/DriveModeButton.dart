import 'package:flutter/material.dart';
import 'dart:ui';

class DriveModeButton extends StatelessWidget {
  final String driveMode;
  final bool isSelected;
  final VoidCallback onPressed;

  const DriveModeButton(
      {Key? key,
      required this.driveMode,
      required this.isSelected,
      required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size_Height = MediaQuery.of(context).size.height;
    final Size_Width = MediaQuery.of(context).size.width;

    return Container(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(
          sigmaX: -2,
          sigmaY: -2,
        ),
        child: Container(
          width: ((Size_Height * 0.13)),
          height: ((Size_Height * 0.13)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular((Size_Height * 0.13)),
            gradient: RadialGradient(
              center: Alignment(0, 0),
              radius: 0.5,
              colors: <Color>[
                isSelected ? Color(0xFF748FC2) : Color(0xFF2A2A2A),
                Color(0xFF2A2A2A)
              ],
              stops: <double>[0.775, 1],
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected ? Color(0xFF748FC2) : Color(0xFF2A2A2A),
                spreadRadius: 1,
                blurRadius: 1,
                offset: Offset(
                  0,
                  0,
                ), // changes position of shadow
              ),
            ],
          ),
          alignment: Alignment.center,
          child: TextButton(
            onPressed: onPressed,
            child: Text(
              driveMode,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: (Size_Width * 0.03),
                color: Color(0xFFFFFFFF),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
