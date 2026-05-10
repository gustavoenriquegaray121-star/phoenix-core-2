import 'package:flutter/material.dart';

void main() {
  runApp(const PhoenixTestApp());
}

class PhoenixTestApp extends StatelessWidget {
  const PhoenixTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Phoenix Core 2',
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'PHOENIX CORE 2 ONLINE',
            style: TextStyle(
              color: Colors.greenAccent,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
