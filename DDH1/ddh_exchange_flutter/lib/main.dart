import 'package:flutter/material.dart';
import 'ui/screens/business/main_tab_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '点点换',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainTabScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
