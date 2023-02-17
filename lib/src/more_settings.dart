import 'dart:io';

import 'package:easy_service_manager/src/privacy_policy_screen.dart';
import 'package:easy_service_manager/src/utils/app_info.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class MoreSettings extends StatefulWidget {
  final AppInfo appInfo;
  const MoreSettings({super.key, required this.appInfo});

  @override
  State<MoreSettings> createState() => _MoreSettingsState();
}

class _MoreSettingsState extends State<MoreSettings> {
  final InAppReview inAppReview = InAppReview.instance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.titleLarge;

    return Scaffold(
      appBar: AppBar(title: const Text('More Settings')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                if (widget.appInfo.privacyPolicy != null &&
                    widget.appInfo.privacyPolicy!.isNotEmpty)
                  ListTile(
                    title: Text('Privacy Policy', style: style),
                    leading: const Icon(Icons.security),
                    onTap: _privacyPolicy,
                  ),
                if (widget.appInfo.appStoreID != null &&
                    widget.appInfo.appStoreID!.isNotEmpty)
                  ListTile(
                    title: Text('Rate Us', style: style),
                    leading: const Icon(Icons.stars),
                    onTap: _rateUs,
                  ),
                ListTile(
                  title: Text('Share', style: style),
                  leading: const Icon(Icons.share),
                  onTap: _share,
                ),
                if ((widget.appInfo.itunesMoreAppLink != null &&
                        widget.appInfo.itunesMoreAppLink!.isNotEmpty) ||
                    (widget.appInfo.androidDeveloperName != null &&
                        widget.appInfo.androidDeveloperName!.isNotEmpty))
                  ListTile(
                    title: Text('More Apps', style: style),
                    leading: const Icon(Icons.widgets),
                    onTap: _moreApps,
                  ),
                if (widget.appInfo.supportEmail != null &&
                    widget.appInfo.supportEmail!.isNotEmpty)
                  ListTile(
                    title: Text(
                      'Contact Us',
                      style: style,
                    ),
                    leading: const Icon(Icons.email),
                    onTap: _mailTo,
                  ),
                ListTile(
                  title: Text('About', style: style),
                  leading: const Icon(Icons.info_outline),
                  onTap: _showAboutDialog,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
        context: context,
        applicationName: widget.appInfo.appName,
        applicationIcon: widget.appInfo.appIconPath != null &&
                widget.appInfo.appIconPath!.isNotEmpty
            ? Image.asset(widget.appInfo.appIconPath!, width: 50)
            : null,
        applicationVersion: 'version ${widget.appInfo.versionAndBuild}',
        children: widget.appInfo.aboutAppDescription != null &&
                widget.appInfo.aboutAppDescription!.isNotEmpty
            ? [Text(widget.appInfo.aboutAppDescription!)]
            : null);
  }

  void _mailTo() {
    final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: widget.appInfo.supportEmail,
        queryParameters: {'subject': widget.appInfo.appName});

    _launchURL(emailLaunchUri.toString());
  }

  void _share() {
    Share.share(
        'Hey there check out the best ${widget.appInfo.appName}: iOS: items-apps://itunes.apple.com/app/apple-store/id${widget.appInfo.appStoreID}?mt=8  Android: https://play.google.com/store/apps/details?id=${widget.appInfo.packageName}',
        subject: widget.appInfo.appName);
  }

  void _rateUs() =>
      inAppReview.openStoreListing(appStoreId: widget.appInfo.appStoreID);

  void _moreApps() async {
    _launchURL(Platform.isIOS
        ? 'https://apps.apple.com/us/developer/${widget.appInfo.itunesMoreAppLink}'
        : 'market://search?q=pub:${widget.appInfo.androidDeveloperName}');
  }

  void _privacyPolicy() {
    if (widget.appInfo.privacyPolicy!.startsWith('http')) {
      _launchURL(widget.appInfo.privacyPolicy!);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => PrivacyPolicyScreen(
              privacyPolicy: widget.appInfo.privacyPolicy ?? ''),
        ),
      );
    }
  }

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
          title: Text(title, style: Theme.of(context).textTheme.titleLarge),
          content:
              Text(description, style: Theme.of(context).textTheme.bodyLarge),
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
