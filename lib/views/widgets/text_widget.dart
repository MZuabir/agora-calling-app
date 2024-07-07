import 'package:flutter/material.dart';

class CustomTextWidget extends StatelessWidget {
  const CustomTextWidget(
      {Key? key,
      this.wordSpace,
      required this.text,
      this.color = Colors.black,
      this.fontSize = 16,
      this.maxLines = 100,
      this.softWrap = true,
      this.textOverflow = TextOverflow.ellipsis,
      this.font,
      this.fontWeight = FontWeight.normal,
      this.textAlign,
      this.textDecorationStyle,
      this.textDecoration,
      this.letterSpace})
      : super(key: key);
  final dynamic text;
  final Color color;
  final double fontSize;
  final bool softWrap;
  final FontWeight fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? textOverflow;
  final double? wordSpace, letterSpace;
  final TextStyle? font;
  final TextDecorationStyle? textDecorationStyle;
  final TextDecoration? textDecoration;

  @override
  Widget build(BuildContext context) {
    double size = fontSize;
    
    return Text(text.toString(),
        textAlign: textAlign,
        softWrap: softWrap,
        maxLines: maxLines,
        overflow: textOverflow,
        textScaleFactor: 1.0,
        style: font ??
            TextStyle(
                color: color,
                fontSize: size,
                fontWeight: fontWeight,
                decoration: textDecoration,
                decorationStyle: textDecorationStyle,
                letterSpacing: letterSpace,
                wordSpacing: wordSpace)
       
        );
  }
}
