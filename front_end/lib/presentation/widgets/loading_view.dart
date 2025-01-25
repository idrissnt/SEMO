// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '../../core/config/theme.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading...',
            style: AppTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
