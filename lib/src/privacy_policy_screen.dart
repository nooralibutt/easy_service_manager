import 'package:easy_service_manager/src/easy_services_manager.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy',
            style: Theme.of(context).textTheme.titleLarge),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Text(EasyServicesManager.instance.privacyPolicy ?? ''),
        ),
      ),
    );
  }
}
