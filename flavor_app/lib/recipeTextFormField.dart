import 'package:flutter/material.dart';


class RecipeTextFormField extends StatelessWidget {
  final Key keyField;
  final TextInputType? keyboardType;
  final IconData icon;
  final String labelText;
  final String hintText;
  final String errorMessage;

  const RecipeTextFormField({
    super.key,
    required this.keyField, 
    this.keyboardType, 
    required this.icon, 
    required this.labelText, 
    required this.hintText, 
    required this.errorMessage,
  });


  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: keyField,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          icon: Icon(icon),
          labelText: labelText,
          hintText:hintText),
      validator: (value) {
        if (value!.isEmpty) {
          return errorMessage;
        }
        return null;
      },
    );
  }
}