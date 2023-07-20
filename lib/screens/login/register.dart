import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:document_saver_app/provider/auth_provider.dart';
import 'package:document_saver_app/routes/routes.dart';
import 'package:document_saver_app/screens/login/widgets/custom_button.dart';
import 'package:document_saver_app/screens/login/widgets/custom_text_form_field.dart';
import 'package:document_saver_app/widgets/gradient_background.dart';
import 'package:provider/provider.dart';

class Register extends StatefulWidget {
  static String routeName = '/register';

  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: GradientBackground(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Image.asset(
                  "lib/assets/register.png",
                  height: 100,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  keyboardType: TextInputType.name,
                  validator: (String? value) {
                    if (value!.isEmpty) return "Please enter an username";
                    return null;
                  },
                  controller: usernameController,
                  hintText: "Enter your username",
                  labelText: "Username",
                  prefixIconData: Icons.person,
                ),
                const SizedBox(height: 17),
                CustomTextField(
                  keyboardType: TextInputType.emailAddress,
                  validator: (String? value) {
                    if (value!.isEmpty) return "Please enter a valid e-mail";
                    return null;
                  },
                  controller: emailController,
                  hintText: "Enter your e-mail",
                  labelText: "E-mail",
                  prefixIconData: Icons.email,
                ),
                const SizedBox(height: 17),
                CustomTextField(
                  keyboardType: TextInputType.visiblePassword,
                  validator: (String? value) {
                    if (value!.isEmpty) return "Please enter a password";
                    if (value.length < 8) {
                      return "Your password needs to be at least 8 characters";
                    }
                    return null;
                  },
                  controller: passwordController,
                  hintText: "Enter your password",
                  labelText: "Password",
                  prefixIconData: Icons.password,
                  enableVisibilityToggle: true,
                ),
                const SizedBox(height: 17),
                CustomTextField(
                  keyboardType: TextInputType.visiblePassword,
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return "Please confirm your password";
                    }
                    if (value != passwordController.text) {
                      return "Your passwords do not match";
                    }
                    return null;
                  },
                  controller: passwordConfirmController,
                  hintText: "Confirm your password",
                  labelText: "Password",
                  prefixIconData: Icons.password,
                  enableVisibilityToggle: true,
                ),
                const SizedBox(height: 17),
                CustomButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      authProvider.signUp(
                        email: emailController.text,
                        password: passwordController.text,
                        username: usernameController.text,
                        context: context,
                      );
                    }
                  },
                  label: "Register",
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, loginPageRoute);
                  },
                  child: const Text("Already have an account? Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
