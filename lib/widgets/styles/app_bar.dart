import 'package:flutter/material.dart';
import 'package:feedly/widgets/styles/app_colors.dart';

PreferredSizeWidget feedlyAppBar({required String title, bool center = true}) {
  return AppBar(
    title: Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        color: AppColors.white,
        fontSize: 22,
      ),
    ),
    centerTitle: center,
    backgroundColor: AppColors.backgroundDark,
    elevation: 0,
  );
}
