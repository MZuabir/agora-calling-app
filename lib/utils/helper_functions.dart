
import 'package:get/get.dart';

// Future<XFile?> pickImage() async {
//   final ImagePicker picker = ImagePicker();
//   return await picker.pickImage(source: ImageSource.gallery);
// }

// ImageProvider<Object> getProfileImage(String? imageLink) {
//   if (imageLink == null || imageLink.isEmpty) {
//     return const AssetImage('assets/png/man.png');
//   } else {
//     return CachedNetworkImageProvider(imageLink);
//   }
// }

String handleException(e) {
  String errorMessage = 'An error occurred';

  switch (e.code) {
    // signInWithEmailAndPassword
    case "wrong-password":
      errorMessage = "Incorrect email or password".tr;
      break;
    case "invalid-email":
      errorMessage = "Invalid email address".tr;
      break;
    case "user-disabled":
      errorMessage = "This account has been disabled".tr;
      break;
    case "user-not-found":
      errorMessage = "Account not found. Please check your email or sign up".tr;
      break;

    // createUserWithEmailAndPassword
    case "email-already-in-use":
      errorMessage =
          "Email is already registered. Please use another email or sign in.".tr;
      break;
    case "operation-not-allowed":
      errorMessage =
          "Email/password accounts are not enabled. Please contact support.".tr;
      break;
    case "weak-password":
      errorMessage = "Password is too weak. Choose a stronger password.".tr;
      break;

    // signInWithCredential
    case "account-exists-with-different-credential":
      errorMessage =
          "An account with the same email address exists with a different sign-in method. Please sign in using the correct provider.".tr;
      break;
    case "invalid-credential":
      errorMessage =
          "Invalid sign-in credential. Please check your email or password.".tr;
      break;
    case "invalid-verification-code":
      errorMessage = "Invalid verification code. Please check your input.".tr;
      break;
    case "invalid-verification-id":
      errorMessage = "Invalid verification ID. Please try again.".tr;
      break;

    // reauthenticateWithCredential
    case "user-mismatch":
      errorMessage = "The provided credentials do not match the current user".tr;
      break;
  }

  return errorMessage;
}

bool isLeftAllignLang() {
  return (Get.locale?.languageCode == "en" ||
      Get.locale?.languageCode == "tr" ||
      Get.locale?.languageCode == "es");
}
