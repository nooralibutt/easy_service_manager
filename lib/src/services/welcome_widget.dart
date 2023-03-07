import 'dart:async';
import 'dart:math';

import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:easy_service_manager/easy_service_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:package_info_plus/package_info_plus.dart';

class WelcomeWidget extends StatefulWidget {
  final AsyncCallback? initializeBuilder;
  final String? nextScreenRouteName;
  final VoidCallback? onDone;
  final bool showAppOpenAd;
  final String? iconPath;

  /// After initializing or showing app open ad, on done or move to next screen will be called after this delay in SECONDS
  final int delayInDone;

  const WelcomeWidget({
    this.iconPath,
    this.initializeBuilder,
    this.showAppOpenAd = true,
    this.delayInDone = 2,
    this.nextScreenRouteName,
    this.onDone,
    super.key,
  });

  @override
  State<WelcomeWidget> createState() => _WelcomeWidgetState();
}

class _WelcomeWidgetState extends State<WelcomeWidget> {
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

    _cancelAppOpenAdSubscription();
  }

  void _cancelAppOpenAdSubscription() {
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
            if (widget.iconPath != null) buildLogo(),
            Container(
              width: 200,
              height: 200,
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
                alignment: const Alignment(0.8, 0.9),
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

  Widget buildLogo() {
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.all(50.0),
      child: widget.iconPath!.startsWith('http')
          ? Image.network(
              widget.iconPath!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.contain,
              loadingBuilder:
                  (BuildContext context, Widget child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator.adaptive(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded.toDouble() /
                            (loadingProgress.expectedTotalBytes?.toDouble() ??
                                1)
                        : null,
                  ),
                );
              },
            )
          : Image.asset(
              widget.iconPath!,
              width: double.infinity,
            ),
    );
  }

  void _initializeEveryThing() async {
    if (widget.showAppOpenAd) {
      _streamSubscription = EasyAds.instance.onEvent.listen((event) {
        if (event.adUnitType == AdUnitType.appOpen) {
          if (event.type == AdEventType.adLoaded) {
            EasyServicesManager.showAppOpenAd();
          } else if (event.type == AdEventType.adFailedToLoad ||
              event.type == AdEventType.adFailedToShow ||
              event.type == AdEventType.adDismissed) {
            _cancelAppOpenAdSubscription();
            _scheduleDone();
          }
        }
      });
    }

    if (widget.initializeBuilder != null) {
      await widget.initializeBuilder?.call();
    }
    final appOpenAdNotAvailable =
        EasyAds.instance.adIdManager.admobAdIds?.appOpenId?.isEmpty ?? true;
    if (widget.showAppOpenAd == false || appOpenAdNotAvailable) {
      _scheduleDone();
    }
  }

  void _scheduleDone() {
    Future.delayed(Duration(seconds: widget.delayInDone), _onDone);
  }

  bool _isAlreadyDone = false;
  void _onDone() {
    if (_isAlreadyDone) return;
    _isAlreadyDone = true;

    if (widget.nextScreenRouteName != null) {
      Navigator.pushReplacementNamed(context, widget.nextScreenRouteName!);
    }

    widget.onDone?.call();
  }
}
