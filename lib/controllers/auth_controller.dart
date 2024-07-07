import 'package:calling_app/models/user_model.dart';
import 'package:calling_app/services/db_services.dart';
import 'package:calling_app/utils/getx_snackbar.dart';
import 'package:calling_app/utils/helper_functions.dart';
import 'package:calling_app/utils/logger.dart';
import 'package:calling_app/views/app/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final RxBool isLoadingLogin = false.obs;
  final RxBool isLoadingSignup = false.obs;
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  TextEditingController name = TextEditingController();

  GlobalKey<FormState> signUpKey = GlobalKey<FormState>();
  GlobalKey<FormState> loginKey = GlobalKey<FormState>();
  FirebaseAuth get _auth => FirebaseAuth.instance;
  DBServices dbServices = DBServices();

  onSignUp() async {
    if (!isLoadingSignup.value &&
        (signUpKey.currentState?.validate() ?? false)) {
      try {
        isLoadingSignup.value = true;
        await _auth.createUserWithEmailAndPassword(
            email: email.text.trim(), password: password.text.trim());
        dbServices.addUser(UserModel(
          email: email.text.trim(),
          username: name.text.trim(),
        ));
        isLoadingSignup.value = false;
        clearControllers();
        Get.off(() => const HomeScreen());
      } on FirebaseAuthException catch (e, s) {
        isLoadingSignup.value = false;
        Logger.error(e, stackTrace: s);
        Snack.showErrorSnackBar(handleException(e));
      }
    }
  }

  onLogin() async {
    if (!isLoadingLogin.value && (loginKey.currentState?.validate() ?? false)) {
      try {
        isLoadingLogin.value = true;
        await _auth.signInWithEmailAndPassword(
            email: email.text.trim(), password: password.text.trim());
        isLoadingLogin.value = false;
        Get.off(() => const HomeScreen());
        clearControllers();
      } on FirebaseAuthException catch (e, s) {
        isLoadingLogin.value = false;
        Logger.error(e, stackTrace: s);
        Snack.showErrorSnackBar(handleException(e));
      }
    }
  }

  clearControllers() {
    loginKey = GlobalKey<FormState>();
    signUpKey = GlobalKey<FormState>();
    loginKey.currentState?.reset();
    signUpKey.currentState?.reset();
    email.clear();
    name.clear();
    password.clear();
    confirmPassword.clear();
  }

  String? confirmPasswordValidation(String? val) {
    if (val?.isEmpty ?? true) {
      return "Required*";
    } else if (confirmPassword.text != password.text) {
      return "Password should be same";
    }
    return null;
  }

  String? emailValidation(String? val) {
    if (val?.isEmpty ?? true) {
      return "Required*";
    } else if (!isValidEmail(val ?? "")) {
      return "Invalid email";
    }
    return null;
  }

  bool isValidEmail(String email) {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  String? passwordValidation(String? val) {
    if (val?.isEmpty ?? true) {
      return "Required*";
    } else if ((val?.length ?? 0) < 8) {
      return "Password should be at least 8 characters long";
    }
    return null;
  }
}
