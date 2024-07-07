import 'package:calling_app/controllers/auth_controller.dart';
import 'package:calling_app/utils/custom_extentions.dart';
import 'package:calling_app/utils/text_field_decoration.dart';
import 'package:calling_app/views/auth/login_screen.dart';
import 'package:calling_app/views/widgets/text_widget.dart';
import 'package:calling_app/views/widgets/wave_loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});
  static final authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan.withOpacity(0.5),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: authController.signUpKey,
            child: Column(children: [
              const SizedBox(height: 200),
              TextFormField(
                  controller: authController.name,
                  
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(color: Colors.cyan, fontSize: 16),
                  onTapOutside: (event) => context.hideKeyboard(),
                  decoration: inputDecoration(
                    hintText: "Name",
                    filled: true,
                  )),
              const SizedBox(height: 30),
              TextFormField(
                  controller: authController.email,
                  validator: authController.emailValidation,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(color: Colors.cyan, fontSize: 16),
                  onTapOutside: (event) => context.hideKeyboard(),
                  decoration: inputDecoration(
                      hintText: "Email",
                      filled: true,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(
                            top: 10, bottom: 10, left: 30, right: 15),
                        child: Icon(
                          Icons.mail,
                          color: Colors.cyan,
                        ),
                      ))),
              const SizedBox(height: 30),
              TextFormField(
                controller: authController.password,
                validator: authController.passwordValidation,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                textInputAction: TextInputAction.done,
                style: const TextStyle(color: Colors.cyan, fontSize: 16),
                onTapOutside: (event) => context.hideKeyboard(),
                decoration: inputDecoration(
                  hintText: "Password",
                  filled: true,
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: authController.confirmPassword,
                validator: authController.confirmPasswordValidation,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                textInputAction: TextInputAction.done,
                style: const TextStyle(color: Colors.cyan, fontSize: 16),
                onTapOutside: (event) => context.hideKeyboard(),
                decoration: inputDecoration(
                  hintText: "Confirm Password",
                  filled: true,
                ),
              ),
              const SizedBox(height: 40),
              Obx(
                () => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                       
                        fixedSize: const Size(232, 45)),
                    onPressed: () {
                      authController.onSignUp();
                    },
                    child: authController.isLoadingSignup.value
                        ? const WaveLoadingWidget()
                        : const CustomTextWidget(
                            text: "Sign up",
                            color: Colors.cyan,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          )),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Flexible(child: Image.asset("assets/png/left-line.png")),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: CustomTextWidget(
                      text: "OR",
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(child: Image.asset("assets/png/right-line.png")),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CustomTextWidget(
                    text: "Do you have an account?",
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  TextButton(
                      onPressed: () {
                        authController.clearControllers();
                        Get.off(() => const LoginScreen());
                      },
                      child: const CustomTextWidget(
                        text: "Sign in now",
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      )),
                ],
              ),
              const SizedBox(height: 50),
            ]),
          ),
        ),
      ),
    );
  }
}
