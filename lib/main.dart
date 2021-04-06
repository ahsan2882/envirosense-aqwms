import 'package:flutter/material.dart';
import 'package:envirosense_aqwms/MainPage.dart';
void main() async{
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Air Quality Monitoring System',
    theme: ThemeData(
      primarySwatch: Colors.green,
      backgroundColor: Colors.greenAccent,
      highlightColor: Colors.green,
    ),
    home: LoadingScreen(title: 'Air Quality Monitoring System'),
  ));
}
