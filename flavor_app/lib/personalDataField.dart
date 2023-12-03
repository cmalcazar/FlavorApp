import 'package:flutter/material.dart';

//TextField widget for registration screen
class PersonalDataField extends StatelessWidget {
  final Key? keyField; 
  final String labelText;
  final String hintText;
  final String errorMessage;
  final IconData? icon;


  const PersonalDataField({
    super.key,  
    required this.keyField,
    required this.labelText, 
    required this.hintText, 
    required this.errorMessage, 
    required this.icon, 
  });


  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: keyField,
      autocorrect: true,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(fontSize: 20),
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 20),
        icon: Icon(icon),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return errorMessage;
        }
        return null;
      },
    );
  }
}
