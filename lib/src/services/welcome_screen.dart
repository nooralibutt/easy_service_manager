import 'dart:async';
import 'dart:math';

import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:easy_service_manager/easy_service_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:package_info_plus/package_info_plus.dart';

class WelcomeScreen extends StatefulWidget {
  final AsyncCallback? initializeBuilder;
  final String? nextScreenRouteName;
  final VoidCallback? onDone;
  final bool showAppOpenAd;

  const WelcomeScreen({
    this.initializeBuilder,
    this.showAppOpenAd = true,
    this.nextScreenRouteName,
    this.onDone,
    super.key,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  static const List<Color> _kDefaultRainbowColors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
  ];
  StreamSubscription<AdEvent>? _streamSubscription;

  @override
  void initState() {
    super.initState();

    _initializeEveryThing();
  }

  @override
  void dispose() {
    super.dispose();

    _streamSubscription?.cancel();
    _streamSubscription = null;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(50.0),
              child: Image.asset(
                'assets/images/diamonds/diamond_heading.png',
                width: double.infinity,
              ),
            ),
            Container(
              width: 200,
              padding: const EdgeInsets.all(60.0),
              alignment: Alignment.center,
              child: LoadingIndicator(
                indicatorType:
                    Indicator.values[Random().nextInt(Indicator.values.length)],
                colors: _kDefaultRainbowColors,
              ),
            ),
          ],
        ),
        FutureBuilder(
          future: PackageInfo.fromPlatform(),
          builder: (context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              final version =
                  '${snapshot.data?.version}+${snapshot.data?.buildNumber}';
              return Align(
                alignment: const Alignment(0.8, 1.0),
                child: Text(
                  kDebugMode ? 'd$version' : 'r$version',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ],
    );
  }

  Future<void> _initializeEveryThing() async {
    if (widget.initializeBuilder != null) {
      await widget.initializeBuilder?.call();
    }

    if (widget.showAppOpenAd) {
      _streamSubscription = EasyAds.instance.onEvent.listen((event) {
        if (event.adUnitType == AdUnitType.appOpen &&
            event.type == AdEventType.adLoaded) {
          _streamSubscription?.cancel();
          _streamSubscription = null;

          EasyServicesManager.showAppOpenAd();
        }
      });
    }

    Future.delayed(const Duration(seconds: 2), _moveToNextScreen);
  }

  void _moveToNextScreen() {
    if (widget.nextScreenRouteName != null) {
      Navigator.pushReplacementNamed(context, widget.nextScreenRouteName!);
    }

    widget.onDone?.call();
  }
}
