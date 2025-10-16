import 'package:feedly/core/providers/auth/auth_provider.dart';
import 'package:feedly/core/providers/feed/upload_feed_provider.dart';
import 'package:feedly/core/providers/feed/user_feed_provider.dart';
import 'package:feedly/my_app.dart';
import 'package:feedly/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => AddFeedProvider()),
        ChangeNotifierProvider(create: (_) => UserFeedProvider()),
      ],
      child: const MyAppWrapper(),
    ),
  );
}
