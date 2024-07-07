import 'package:flutter/material.dart';

InputDecoration inputDecoration(
        {required String hintText,
        Widget? suffixIcon,
        Widget? prefixIcon,
        bool? filled,
        Color fillColor = Colors.white,
        double contPadTop = 2,
        double contPadBottom = 2,
        double contPadRight = 15,
        double contPadLeft = 25,
        BoxConstraints? prefixConstrainst,
        BoxConstraints? suffixConstrainst}) =>
    InputDecoration(
      filled: filled,
      fillColor: fillColor,
      hintText: hintText,
      hintStyle: const TextStyle(
          color: Colors.cyan, fontSize: 14, fontWeight: FontWeight.w400),
      contentPadding: EdgeInsets.only(
          right: contPadRight,
          left: contPadLeft,
          top: contPadTop,
          bottom: contPadBottom),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.white.withOpacity(.5))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.white)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.red)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.red)),
      suffixIconConstraints: suffixConstrainst,
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
      prefixIconConstraints: prefixConstrainst,
    );
