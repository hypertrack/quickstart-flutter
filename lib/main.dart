import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hypertrack_plugin/data_types/json.dart';
import 'package:hypertrack_plugin/data_types/location.dart';
import 'package:hypertrack_plugin/data_types/result.dart';
import 'package:hypertrack_plugin/hypertrack.dart';

const String _publishableKey = '< Put your publishable_key here >';

Future<void> main() async {
  DartPluginRegistrant.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  HyperTrack hyperTrack =
      await HyperTrack.initialize(_publishableKey, loggingEnabled: true)
          .onError((error, stackTrace) {
    throw Exception(error);
  });
  runApp(MyApp(hyperTrack));
}

class MyApp extends StatefulWidget {
  final HyperTrack hyperTrack;

  const MyApp(HyperTrack this.hyperTrack, {Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState(this.hyperTrack);
}

class _MyAppState extends State<MyApp> {
  HyperTrack _hypertrackSdk;

  _MyAppState(this._hypertrackSdk);

  String _trackingStateText = 'Not initialized';
  String _trackingErrorText = '';
  String _isAvailableText = 'Not initialized';
  String _deviceId = '';

  @override
  void initState() {
    super.initState();
    initHyperTrack();
    updateDeviceId();

    _hypertrackSdk.setName(_deviceName);
    _hypertrackSdk.setMetadata(_testMetadata);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: const ColorScheme.light(primary: Colors.green),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('HyperTrack Quickstart'),
          centerTitle: true,
        ),
        body: Builder(
          builder: (builder) => ListView(
            children: [
              SizedBox(height: 10),
              ListTile(
                leading: const Text("Device name"),
                trailing: Container(
                  width: 180,
                  child: Text(
                    _deviceName,
                  ),
                ),
              ),
              Container(
                height: 65,
                width: 400,
                child: Row(
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: TextField(
                        enabled: false,
                        style: TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        controller: TextEditingController(text: _deviceId),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        ClipboardData data = ClipboardData(text: _deviceId);
                        await Clipboard.setData(data);
                        print(_deviceId);
                        _showSnackBarMessage(
                            builder, "Device ID copied to clipboard");
                      },
                      child: Text("Copy"),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: 50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text("isTracking state"),
                    ),
                  ),
                  Flexible(child: Text(_trackingStateText))
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: 50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text("isAvailable state"),
                    ),
                  ),
                  Flexible(child: Text(_isAvailableText.toString()))
                ],
              ),
              Row(
                children: [
                  Container(
                    height: 50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: const Text("Errors"),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      _trackingErrorText,
                    ),
                  )
                ],
              ),
              ButtonBar(
                alignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _hypertrackSdk.startTracking();
                    },
                    child: Text("Start Tracking"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _hypertrackSdk.stopTracking();
                    },
                    child: Text("Stop Tracking"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _hypertrackSdk.setAvailability(true);
                    },
                    child: Text("Set Available"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _hypertrackSdk.setAvailability(false);
                    },
                    child: Text("Set Unavailable"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      bool isAvailable = await _hypertrackSdk.isAvailable;
                      _showSnackBarMessage(
                          builder, "isAvailable: $isAvailable");
                    },
                    child: Text("isAvailable"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      bool isTracking = await _hypertrackSdk.isTracking;
                      _showSnackBarMessage(builder, "isTracking: $isTracking");
                    },
                    child: Text("isTracking"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await _hypertrackSdk.location;
                      _showSnackBarMessage(builder, result.toString());
                    },
                    child: Text("Get location"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final result =
                          await _hypertrackSdk.addGeotag(_testGeotag);
                      if (result is Success) {
                        _showSnackBarMessage(
                            builder, "Geotag added at $result");
                      } else {
                        _showSnackBarMessage(builder, "Geotag error: $result");
                      }
                    },
                    child: Text("Add geotag"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await _hypertrackSdk.addGeotag(_testGeotag,
                          expectedLocation: Location(37.422, -122.084));
                      if (result is Success) {
                        _showSnackBarMessage(
                            builder, "Geotag added at $result");
                      } else {
                        _showSnackBarMessage(builder, "Geotag error: $result");
                      }
                    },
                    child: Text("Add geotag with expected location"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _hypertrackSdk.sync();
                      _showSnackBarMessage(builder, "Sync");
                    },
                    child: Text("Sync"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void initHyperTrack() {
    _hypertrackSdk.onTrackingChanged.listen((bool isTracking) {
      if (mounted) {
        _trackingStateText = "Tracking: $isTracking";
        _trackingErrorText = "";
        setState(() {});
      }
    }).onError((error) {
      if (mounted) {
        _trackingStateText = error.toString();
        setState(() {});
      }
    });
    _hypertrackSdk.onAvailabilityChanged.listen((bool isAvailable) {
      if (mounted) {
        _isAvailableText = "Available: ${isAvailable}";
        _trackingErrorText = "";
        setState(() {});
      }
    }).onError((error) {
      if (mounted) {
        _isAvailableText = error.toString();
        setState(() {});
      }
    });
    _hypertrackSdk.onError.listen((errors) {
      if (mounted) {
        _trackingErrorText =
            errors.map((e) => {e.toString().split('.').last}).join("\n");
        setState(() {});
      }
    }).onError((error) {
      if (mounted) {
        _trackingErrorText = error.toString();
        setState(() {});
      }
    });
  }

  void updateDeviceId() async {
    _deviceId = await _hypertrackSdk.deviceId;
    setState(() {});
  }

  void _showSnackBarMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: Duration(milliseconds: 1000),
        content: RichText(
          text: TextSpan(
            children: [message]
                .map<TextSpan>(
                  (String message) => TextSpan(text: message),
                )
                .toList(),
          ),
        )));
  }
}

const String _deviceName = 'Flutter Quickstart';
final JSONObject _testMetadata = JSONObject({
  "source": JSONString("Flutter"),
  "metadata": JSONObject({"value": JSONNumber(Random().nextDouble())})
});
final JSONObject _testGeotag = JSONObject({
  "source": JSONString("Flutter"),
  "payload": JSONObject({"test_payload": JSONNumber(1)})
});
