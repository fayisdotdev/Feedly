import 'package:flutter/material.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Text(
          'Login Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
