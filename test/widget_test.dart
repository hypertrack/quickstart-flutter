import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hypertrack_plugin/hypertrack.dart';
import 'package:hypertrack_plugin/const/constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  String publishableKey =
      "<-- PUBLISHABLE KEY GOES HERE -->";
  HyperTrack? hyperTrack;

  setUp(() async {
    if (hyperTrack == null)
      hyperTrack = await HyperTrack().initialize(publishableKey);
  });

  tearDown(() {});

  group('Basic Smoke Test', () {
    test('initialize', () async {
      hyperTrack = await HyperTrack().initialize(publishableKey);
      expect(await hyperTrack.runtimeType, HyperTrack);
    });

    test('is not running', () async {
    hyperTrack = await HyperTrack().initialize(publishableKey);
      expect(await hyperTrack?.isRunning(), false);
    });

    test('tracking', () async {
      expect(await hyperTrack?.isTracking(), false);
    });

    test('is running', () {
      Timer(Duration(seconds: 3), () async {
        expect(await hyperTrack?.isRunning(), true);
      });
    });

    test('not tracking', () async {
      await hyperTrack?.stop();
      expect(await hyperTrack?.onTrackingStateChanged.first,
          TrackingStateChange.stop);
      expect(await hyperTrack?.isRunning(), false);
    });
    test("get availability", () async {
      expect(await hyperTrack?.getAvailability(), Availability.Unavailable);
    });
  });
}
