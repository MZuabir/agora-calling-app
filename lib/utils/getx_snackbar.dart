import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Snack {
  static void showSuccessSnackBar(dynamic message) {
    Get.snackbar(
      'Success',
      message.toString(),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      backgroundColor: Colors.green,
      colorText: Colors.white,
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }

  static void showInfoSnackBar(dynamic message) {
    Get.snackbar(
      'Info',
      message.toString(),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }

  static showErrorSnackBar(dynamic message) async {
    Get.snackbar(
      'Error',
      message.toString(),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      backgroundColor: Colors.red,
      colorText: Colors.white,
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }
}
