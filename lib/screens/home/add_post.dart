import 'package:flutter/material.dart';

class AddPostPage extends StatelessWidget {
  const AddPostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post')),
      body: Center(
        child: Text(
          'Post Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
