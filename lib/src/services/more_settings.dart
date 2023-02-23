import 'dart:io';

import 'package:easy_service_manager/src/models/app_info.dart';
import 'package:easy_service_manager/src/services/privacy_policy_screen.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class MoreSettings extends StatefulWidget {
  final AppInfo appInfo;
  final String? title;
  const MoreSettings({super.key, required this.appInfo, this.title});

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
      body: ListView(
        children: [
          ListTile(
            leading: getCloseButton(),
            title: widget.title == null
                ? null
                : Text(
                    widget.title!,
                    style: theme.textTheme.headlineLarge!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
          ),
          const SizedBox(height: 10),
          if (widget.appInfo.privacyPolicy?.isNotEmpty ?? false)
            ListTile(
              title: Text('Privacy Policy', style: style),
              leading: const Icon(Icons.security),
              onTap: _privacyPolicy,
            ),
          _buildRateUs(style),
          _buildShare(style),
          _buildMoreApps(style),
          if (widget.appInfo.supportEmail?.isNotEmpty ?? false)
            ListTile(
              title: Text('Contact Us', style: style),
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
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
        context: context,
        applicationName: widget.appInfo.appName,
        applicationIcon: widget.appInfo.appIconPath?.isNotEmpty ?? false
            ? Image.asset(widget.appInfo.appIconPath!, width: 50)
            : null,
        applicationVersion: 'version ${widget.appInfo.versionAndBuild}',
        children: widget.appInfo.aboutAppDescription?.isNotEmpty ?? false
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
    String link = '';
    if (Platform.isAndroid) {
      link =
          'Android: https://play.google.com/store/apps/details?id=${widget.appInfo.packageName}';
    } else {
      link =
          'iOS: items-apps://itunes.apple.com/app/apple-store/id${widget.appInfo.appStoreID}?mt=8';
    }
    Share.share('Hey there check out the best ${widget.appInfo.appName}: $link',
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
    final canLaunch = await canLaunchUrl(Uri.parse(url));
    if (canLaunch) {
      await launchUrl((Uri.parse(url)));
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

  Widget _buildRateUs(TextStyle? style) {
    if (Platform.isIOS && (widget.appInfo.appStoreID?.isEmpty ?? true)) {
      return const SizedBox();
    }

    return ListTile(
      title: Text('Rate Us', style: style),
      leading: const Icon(Icons.stars),
      onTap: _rateUs,
    );
  }

  Widget _buildShare(TextStyle? style) {
    if (Platform.isIOS && (widget.appInfo.appStoreID?.isEmpty ?? true)) {
      return const SizedBox();
    }

    return ListTile(
      title: Text('Share', style: style),
      leading: const Icon(Icons.share),
      onTap: _share,
    );
  }

  Widget _buildMoreApps(TextStyle? style) {
    if ((Platform.isIOS &&
            (widget.appInfo.itunesMoreAppLink?.isNotEmpty ?? false)) ||
        (Platform.isAndroid &&
            (widget.appInfo.androidDeveloperName?.isNotEmpty ?? false))) {
      return ListTile(
        title: Text('More Apps', style: style),
        leading: const Icon(Icons.widgets),
        onTap: _moreApps,
      );
    }

    return const SizedBox();
  }

  Widget? getCloseButton() {
    final parentRoute = ModalRoute.of(context);
    final canPop = parentRoute?.canPop ?? false;
    if (canPop) {
      final bool useCloseButton =
          parentRoute is PageRoute<dynamic> && parentRoute.fullscreenDialog;
      return useCloseButton ? const CloseButton() : const BackButton();
    }
    return null;
  }
}
