import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RateFloatingButton extends StatefulWidget {
  final String? appStoreId;
  const RateFloatingButton({
    Key? key,
    this.appStoreId,
  }) : super(key: key);

  @override
  State<RateFloatingButton> createState() => _RateFloatingButtonState();
}

class _RateFloatingButtonState extends State<RateFloatingButton>
    with SingleTickerProviderStateMixin {
  AnimationController? controller;
  static const _shake = 12.0;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);

    Future.delayed(
        const Duration(seconds: 2), () => controller?.forward(from: 0.0));
  }

  @override
  void dispose() {
    controller?.dispose();
    controller = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null) {
      return const SizedBox();
    }

    final Animation<double> offsetAnimation = Tween(begin: 0.0, end: _shake)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(controller!)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller?.reverse();
        }
      });

    final button = FloatingActionButton(
      onPressed: () =>
          EasyRatingManager.showRatingDialog(context, widget.appStoreId),
      child: const Icon(Icons.star, size: 30),
    );

    return AnimatedBuilder(
        animation: offsetAnimation,
        builder: (buildContext, child) {
          return Container(
            margin: const EdgeInsets.only(bottom: 50),
            padding: EdgeInsets.only(
                left: offsetAnimation.value + _shake,
                right: _shake - offsetAnimation.value),
            child: button,
          );
        });
  }
}

class EasyRatingManager {
  static const _keyAppLaunches = "keyEasyRatingAppLaunches";
  static const _keyAlreadyRated = "keyEasyRatingRated";

  static SharedPreferences? _prefs;

  static Future<void> _init() async =>
      _prefs = await SharedPreferences.getInstance();

  static bool get isAlreadyRated => _prefs?.getBool(_keyAlreadyRated) ?? false;
  static void setAlreadyRated({bool rated = true}) =>
      _prefs?.setBool(_keyAlreadyRated, rated);

  static Future<void> incrementAppLaunches() async {
    if (_prefs == null) await _init();
    _prefs?.setInt(_keyAppLaunches, getAppLaunches() + 1);
  }

  static int getAppLaunches() => _prefs?.getInt(_keyAppLaunches) ?? 0;

  static Future<bool> tryShowingCustomInAppReview(
      BuildContext context, String? appStoreID) async {
    if (isAlreadyRated) return false;

    final isSuccessful = await showRatingDialog(context, appStoreID);

    return isSuccessful == true;
  }

  static Future<bool?> showRatingDialog(
      BuildContext context, String? appStoreId) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text('App Review', style: Theme.of(context).textTheme.titleLarge),
          content: Text(
              'If you like our app, would you like to rate us on play store?',
              style: Theme.of(context).textTheme.bodyLarge),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Later',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(color: Colors.redAccent),
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Rate Us'),
              onPressed: () async {
                await InAppReview.instance
                    .openStoreListing(appStoreId: appStoreId);
                if (context.mounted) Navigator.of(context).pop(true);
                setAlreadyRated();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<bool> tryShowingNativeInAppReview(bool forceShow) async {
    // if launches are 3 then show in app review
    if (getAppLaunches() % 3 == 0 || forceShow) {
      final InAppReview inAppReview = InAppReview.instance;

      if (await inAppReview.isAvailable()) {
        inAppReview.requestReview();
        return true;
      }
    }

    return false;
  }
}
