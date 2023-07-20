import 'package:document_saver_app/provider/auth_provider.dart';
import 'package:document_saver_app/routes/routes.dart';
import 'package:document_saver_app/screens/login/widgets/custom_button.dart';
import 'package:document_saver_app/screens/login/widgets/custom_text_form_field.dart';
import 'package:document_saver_app/widgets/gradient_background.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

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
                  "lib/assets/document.png",
                  height: 110,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                    keyboardType: TextInputType.emailAddress,
                    validator: (String? value) {
                      if (value!.isEmpty) {
                        return "Please enter your E-mail";
                      }
                      return null;
                    },
                    controller: emailController,
                    hintText: "Enter your E-mail",
                    labelText: "E-mail",
                    prefixIconData: Icons.email),
                const SizedBox(height: 17),
                CustomTextField(
                  keyboardType: TextInputType.visiblePassword,
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return "Please enter your password";
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
                CustomButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        authProvider.signIn(
                            context: context,
                            email: emailController.text,
                            password: passwordController.text);
                      }
                    },
                    label: "Login"),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, registerPageRoute);
                  },
                  child: const Text("Don't have an account? Register"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, forgotPasswordPageRoute);
                  },
                  child: const Text("Forgot your password?"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
