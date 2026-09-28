import 'package:flutter/material.dart';

Widget CustTextField(String hintText, TextEditingController controller, {bool obsecureText = false}){
  return TextField( decoration: InputDecoration(hint: Text(hintText), border: OutlineInputBorder()));
}
