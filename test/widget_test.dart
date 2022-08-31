import 'package:flutter_test/flutter_test.dart';
import 'package:hypertrack_plugin/hypertrack.dart';
import 'package:hypertrack_plugin/const/constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  String publishableKey = "KdoMYSdE4MFWHEjdOO32xGP2jpmeyV0A0BPtRXUEfUiZfhPm5IfA5jNmQWJZ7GfQBhUtE8SpdoRbtndPGyGofA";
    HyperTrack? hyperTrack;

  setUp(() async {
    if (hyperTrack == null)
          hyperTrack = await HyperTrack().initialize(publishableKey);
  });

  tearDown(() {});

  group('Basic Smoke Test', () {

    test('initialize', () async {
      // hyperTrack = await ;
      expect(await HyperTrack().initialize(publishableKey).runtimeType,
          HyperTrack);
    });
    
    test('is not running', () async {
      expect(await hyperTrack?.isRunning(), false);
    });

    test('tracking', () async {
      await hyperTrack?.start();
      expect(await hyperTrack?.onTrackingStateChanged.first,
          TrackingStateChange.start);
    });

    test('is running', () async {
      expect(await hyperTrack?.isRunning(), true);
    });

    test('not tracking', () async {
      await hyperTrack?.stop();
      expect(await hyperTrack?.onTrackingStateChanged.first,
          TrackingStateChange.stop);
      expect(await hyperTrack?.isRunning(), false);
    });
  });
}
