import 'package:document_saver_app/provider/auth_provider.dart';
import 'package:document_saver_app/screens/login/widgets/custom_button.dart';
import 'package:document_saver_app/screens/login/widgets/custom_text_form_field.dart';
import 'package:document_saver_app/widgets/gradient_background.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  TextEditingController emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: GradientBackground(
          child: Padding(
        padding: const EdgeInsets.all(15),
        child: ListView(
          children: [
            const SizedBox(height: 100),
            Image.asset(
              "lib/assets/confusion.png",
              height: 100,
            ),
            const Text(
              "Enter your e-mail to reset your password",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: CustomTextField(
                keyboardType: TextInputType.emailAddress,
                controller: emailController,
                hintText: "Enter your e-mail",
                labelText: "E-mail",
                prefixIconData: Icons.email,
                validator: (String? value) {
                  if (value!.isEmpty) {
                    return "Please enter your E-mail";
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 17),
            CustomButton(
              label: 'Send recovery e-mail',
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  authProvider.forgotPassword(
                    context: context,
                    email: emailController.text,
                  );
                }
              },
            )
          ],
        ),
      )),
    );
  }
}
