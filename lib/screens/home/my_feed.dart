import 'package:flutter/material.dart';

class MyFeedsPage extends StatelessWidget {
  const MyFeedsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Feeds')),
      body: Center(
        child: Text(
          'My feeds page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
