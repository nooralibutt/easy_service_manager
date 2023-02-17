import 'dart:io';

import 'package:easy_service_manager/src/easy_services_manager.dart';
import 'package:easy_service_manager/src/privacy_policy_screen.dart';
import 'package:easy_service_manager/src/utils/app_info.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class MoreSettings extends StatefulWidget {
  const MoreSettings({super.key});

  @override
  State<MoreSettings> createState() => _MoreSettingsState();
}

class _MoreSettingsState extends State<MoreSettings> {
  final InAppReview inAppReview = InAppReview.instance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.titleLarge;
    final iconColor = theme.iconTheme.color;

    return Scaffold(
      appBar: AppBar(title: const Text('More Settings')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                if (EasyServicesManager.instance.privacyPolicy != null &&
                    EasyServicesManager.instance.privacyPolicy!.isNotEmpty)
                  ListTile(
                    title: Text('Privacy Policy', style: style),
                    leading: Icon(Icons.security, color: iconColor),
                    onTap: _privacyPolicy,
                  ),
                if (EasyServicesManager.instance.appStoreID != null &&
                    EasyServicesManager.instance.appStoreID!.isNotEmpty)
                  ListTile(
                    title: Text('Rate Us', style: style),
                    leading: Icon(Icons.stars, color: iconColor),
                    onTap: _rateUs,
                  ),
                ListTile(
                  title: Text('Share', style: style),
                  leading: Icon(Icons.share, color: iconColor),
                  onTap: _share,
                ),
                if ((EasyServicesManager.instance.itunesMoreAppLink != null &&
                        EasyServicesManager
                            .instance.itunesMoreAppLink!.isNotEmpty) ||
                    (EasyServicesManager.instance.androidDeveloperName !=
                            null &&
                        EasyServicesManager
                            .instance.androidDeveloperName!.isNotEmpty))
                  ListTile(
                    title: Text('More Apps', style: style),
                    leading: Icon(Icons.widgets, color: iconColor),
                    onTap: _moreApps,
                  ),
                if (EasyServicesManager.instance.supportEmail != null &&
                    EasyServicesManager.instance.supportEmail!.isNotEmpty)
                  ListTile(
                    title: Text(
                      'Contact Us',
                      style: style,
                    ),
                    leading: Icon(Icons.email, color: iconColor),
                    onTap: _mailTo,
                  ),
                if (isShowAboutTile())
                  ListTile(
                    title: Text('About', style: style),
                    leading: Icon(Icons.info_outline, color: iconColor),
                    onTap: _showAboutDialog,
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }

  bool isShowAboutTile() {
    if ((EasyServicesManager.instance.appIconPath != null &&
            EasyServicesManager.instance.appIconPath!.isNotEmpty) &&
        (EasyServicesManager.instance.aboutAppDescription != null &&
            EasyServicesManager.instance.aboutAppDescription!.isNotEmpty)) {
      return true;
    }
    return false;
  }

  void _showAboutDialog() {
    showAboutDialog(
        context: context,
        applicationName: AppInfo.instance.appName,
        applicationIcon:
            Image.asset(EasyServicesManager.instance.appIconPath!, width: 50),
        applicationVersion: 'version ${AppInfo.instance.versionAndBuild}',
        children: [Text(EasyServicesManager.instance.aboutAppDescription!)]);
  }

  void _mailTo() {
    final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: EasyServicesManager.instance.supportEmail,
        queryParameters: {'subject': AppInfo.instance.appName});

    _launchURL(emailLaunchUri.toString());
  }

  void _share() {
    Share.share(
        'Hey there check out the best ${AppInfo.instance.appName}: iOS: items-apps://itunes.apple.com/app/apple-store/id${EasyServicesManager.instance.appStoreID}?mt=8  Android: https://play.google.com/store/apps/details?id=${AppInfo.instance.packageName}',
        subject: AppInfo.instance.appName);
  }

  void _rateUs() => inAppReview.openStoreListing(
      appStoreId: EasyServicesManager.instance.appStoreID);

  void _moreApps() async {
    _launchURL(Platform.isIOS
        ? 'https://apps.apple.com/us/developer/${EasyServicesManager.instance.itunesMoreAppLink}'
        : 'market://search?q=pub:${EasyServicesManager.instance.androidDeveloperName}');
  }

  void _privacyPolicy() => Navigator.push(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => const PrivacyPolicyScreen()));

  void _launchURL(String url) async {
    if (await canLaunchUrl(Uri(path: url))) {
      await launchUrl(Uri(path: url));
    } else {
      _showDialog(
          'Failed', 'Failed to launch. Please check your internet connection');
    }
  }

  void _showDialog(String title, String description) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: Colors.white),
          ),
          content: Text(
            description,
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Dismiss'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
