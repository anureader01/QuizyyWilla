import 'package:flutter/material.dart';

Widget prizeTile({
  required String text,
  bool active = false
}){
  return Container(
    width: double.infinity,
margin: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
padding: EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.deepPurple),
      borderRadius: BorderRadius.circular(40),
      color: active ?  Colors.deepOrangeAccent : Colors.deepPurpleAccent.shade100
    ),

    child: Center(child: Text(text, style: TextStyle(
      color: Colors.white,
      fontSize: 15, fontWeight: FontWeight.w700),)),
  );
}
