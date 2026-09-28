import 'package:flutter/material.dart';

Widget CustomChip({required String chipName, required VoidCallback onTap}) {
  return  GestureDetector(
    onTap: onTap,
    child: Container(
          
                  margin: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.deepOrange, width: 5),
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white.withOpacity(0.9),
                  ),
                  child: Text(
                    // level == 3 ?
    
                    // "HARD" : level == 2 ? "MID" : level == 1 ? "EASY" : "EASY" ,
                   chipName,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
  );
}
