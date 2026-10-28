import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

void main() => runApp(const TawasolApp());

class TawasolApp extends StatelessWidget {
  const TawasolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'تطبيق تواصل',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تطبيق تواصل'),
      ),
      body: const Center(
        child: Text(
          'أهلاً بك في تطبيق تواصل للمراسلة',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
