import 'package:flutter/material.dart';
import 'screens/vigilant_dashboard.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartVigilant',
      home: VigilantDashboard(),
    );
  }
}
