import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  final String privacyPolicy;
  const PrivacyPolicyScreen({super.key, required this.privacyPolicy});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy',
            style: Theme.of(context).textTheme.titleLarge),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(privacyPolicy ?? ''),
          ),
        ),
      ),
    );
  }
}
