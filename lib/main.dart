import 'package:feedly/core/providers/auth_provider.dart';
import 'package:feedly/core/providers/feed_provider.dart';
import 'package:feedly/my_app.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FeedProvider()),
        ChangeNotifierProvider(create: (_) => AuthProviderCompact()),
      ],
      child: const MyAppWrapper(),
    ),
  );
}
