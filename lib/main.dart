import 'package:flutter/material.dart';
import 'package:hypertrack_plugin/const/constants.dart';
import 'package:hypertrack_plugin/hypertrack.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  HyperTrack _hypertrackFlutterPlugin = HyperTrack();
  final String _publishableKey =
      "KdoMYSdE4MFWHEjdOO32xGP2jpmeyV0A0BPtRXUEfUiZfhPm5IfA5j"
      "NmQWJZ7GfQBhUtE8SpdoRbtndPGyGofA";
  final String _deviceName = 'RMv2';
  String _result = 'Not initialized';
  bool isRunning = false;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    initHyperTrack();
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
          body: ListView(
            children: [
              SizedBox(height: 10),
              ListTile(
                leading: const Text("Device name"),
                trailing: Text(
                  _deviceName,
                ),
              ),
              ButtonBar(
                alignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: isRunning ? Colors.red : Colors.green),
                    onPressed: () {
                      isRunning
                          ? _hypertrackFlutterPlugin.stop()
                          : _hypertrackFlutterPlugin.start();
                      setState(() {});
                    },
                    child: Text(isRunning ? "Stop Tracking" : "Start Tracking"),
                  ),
                  ElevatedButton(
                    onPressed: () async =>
                        _hypertrackFlutterPlugin.syncDeviceSettings(),
                    child: const Text("Sync Settings"),
                  ),
                  ElevatedButton(
                    onPressed: () async => subscribeToAvailability(),
                    child: const Text("Stream of Availablity"),
                  ),
                  ElevatedButton(
                    onPressed: () async =>
                        print(_hypertrackFlutterPlugin.getAvailability()),
                    child: const Text("get Available"),
                  ),
                  ElevatedButton(
                    onPressed: () async => _hypertrackFlutterPlugin
                        .setAvailability(Availability.Available),
                    child: const Text("set Availability"),
                  ),
                  ElevatedButton(
                    onPressed: () async =>
                        _hypertrackFlutterPlugin.getLatestLocation(),
                    child: const Text("get latest location"),
                  ),
                ],
              ),
            ],
          ),
          bottomNavigationBar: ListTile(
            leading: Text("Status"),
            trailing: Text(_result),
          )),
    );
  }

  void initHyperTrack() async {
    _hypertrackFlutterPlugin = await HyperTrack().initialize(_publishableKey);
    _hypertrackFlutterPlugin.enableDebugLogging();
    _hypertrackFlutterPlugin.setDeviceName(_deviceName);
    _hypertrackFlutterPlugin.setDeviceMetadata({"source": "flutter sdk"});
    _hypertrackFlutterPlugin.onTrackingStateChanged
        .listen((TrackingStateChange event) {
      if (mounted) {
        updateButtonState();
        _result = getTrackingStatus(event);
        setState(() {});
      }
    });
  }

  void updateButtonState() async {
    final temp = await _hypertrackFlutterPlugin.isRunning();
    isRunning = temp;
    setState(() {});
  }

  subscribeToAvailability() async {
    Stream _avail = await _hypertrackFlutterPlugin.subscribeToAvailability;
    _avail.listen((event) {
      print(event.toString() + "123");
    });
  }
}

String getTrackingStatus(TrackingStateChange event) {
  Map<TrackingStateChange, String> statusMap = {
    TrackingStateChange.start: "Tracking Started",
    TrackingStateChange.stop: "Tracking Stop",
    TrackingStateChange.unknownError: "Unknown Error",
    TrackingStateChange.authError: "Authentication Error",
    TrackingStateChange.networkError: "Network Error",
    TrackingStateChange.invalidToken: "Invalid Token",
    TrackingStateChange.locationDisabled: "Location Disabled",
    TrackingStateChange.permissionsDenied: "Permissions Denied",
  };
  if (statusMap[event] == null) {
    throw Exception("Unexpected null value in getTrackingStatus");
  }
  return statusMap[event]!;
}
