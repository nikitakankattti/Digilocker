import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String hintText;
  final String? labelText;
  final IconData prefixIconData;
  final String? Function(String?) validator;
  final bool enableVisibilityToggle;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.keyboardType,
    required this.hintText,
    this.labelText,
    required this.prefixIconData,
    required this.validator,
    this.enableVisibilityToggle = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
      ),
      child: TextFormField(
        keyboardType: widget.keyboardType,
        obscureText: widget.keyboardType == TextInputType.visiblePassword &&
            _obscureText,
        validator: widget.validator,
        controller: widget.controller,
        decoration: InputDecoration(
          hintText: widget.hintText,
          labelText: widget.labelText,
          prefixIcon: Icon(widget.prefixIconData),
          suffixIcon: widget.enableVisibilityToggle
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  icon: Icon(_obscureText
                      ? Icons.remove_red_eye
                      : Icons.visibility_off),
                )
              : null,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
