import 'dart:async';
import 'dart:math' as Math;
import 'dart:ui';
import 'dart:io' show Platform;
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hypertrack_plugin/data_types/hypertrack_error.dart';
import 'package:hypertrack_plugin/data_types/json.dart';
import 'package:hypertrack_plugin/data_types/location.dart';
import 'package:hypertrack_plugin/data_types/location_error.dart';
import 'package:hypertrack_plugin/data_types/location_with_deviation.dart';
import 'package:hypertrack_plugin/data_types/order.dart';
import 'package:hypertrack_plugin/data_types/order_status.dart';
import 'package:hypertrack_plugin/data_types/result.dart';
import 'package:hypertrack_plugin/hypertrack.dart';

Future<void> main() async {
  DartPluginRegistrant.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _deviceId = '';
  String _errorsText = '';
  String _isAvailableText = '';
  String _isTrackingStateText = '';
  String _locationText = '';
  String _ordersText = '';
  String _workerHandle = '';

  StreamSubscription? locateSubscription;

  @override
  void initState() {
    super.initState();

    final String name = "Quickstart Flutter";
    HyperTrack.setName(name);

    final String platformName = Platform.isAndroid ? "android" : "ios";
    /**
     * `worker_handle` is used to link the device and the worker.
     * You can use any unique user identifier here.
     * The recommended way is to set it on app login in set it to null on logout
     * (to remove the link between the device and the worker)
     **/
    HyperTrack.setWorkerHandle(
        "test_worker_quickstart_flutter_${platformName}");

    final JSONObject metadata = JSONObject({
      /**
       * You can also provide any custom data to the metadata.
       */
      "source": JSONString(name),
      "employee_id": JSONNumber(Math.Random().nextInt(10000).toDouble()),
    });
    HyperTrack.setMetadata(metadata);

    HyperTrack.deviceId.then((deviceId) => _deviceId = deviceId);
    HyperTrack.metadata.then((metadata) => log(metadata.toString()));
    HyperTrack.name.then((name) => log(name));
    HyperTrack.workerHandle.then((workerHandle) {
      log(workerHandle);
      _workerHandle = workerHandle;
    });

    _initSubscriptions();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: const ColorScheme.light(primary: Colors.green),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('HyperTrack Quickstart Flutter'),
          centerTitle: true,
        ),
        body: Builder(
          builder: (builder) => Container(
            child: SingleChildScrollView(
                child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  _deviceIdView(builder),
                  _errorsView(),
                  _locationSubscriptionView(),
                  _isTrackingView(),
                  _isAvailableView(),
                  _ordersView(),
                  _addGeotagView(builder),
                  ElevatedButton(
                    onPressed: () async {
                      locateSubscription?.cancel();
                      locateSubscription =
                          await HyperTrack.locate().listen((event) {
                        _showSnackBarMessage(builder, event.toString());
                        locateSubscription?.cancel();
                      });
                    },
                    child: Text("Locate"),
                  ),
                  _gettersView(builder)
                ],
              ),
            )),
          ),
        ),
      ),
    );
  }

  Widget _deviceIdView(builder) {
    return Container(
      child: Row(
        children: [
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
              _showSnackBarMessage(builder, "Device ID copied to clipboard");
            },
            child: Text("Copy"),
          ),
        ],
      ),
    );
  }

  Widget _addGeotagView(builder) {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        ElevatedButton(
          onPressed: () async {
            final result = await HyperTrack.addGeotag(
                _testOrderHandle, _testOrderStatus, _testGeotag);
            _showSnackBarMessage(builder, _formatGeotagResult(result));
          },
          child: Text("Add geotag"),
        ),
        ElevatedButton(
          onPressed: () async {
            final result = await HyperTrack.addGeotagWithExpectedLocation(
                _testOrderHandle,
                _testOrderStatus,
                _testGeotag,
                Location(37.422, -122.084));
            _showSnackBarMessage(
                builder, _formatGeotagWithExpectedLocationResult(result));
          },
          child: Text("Add geotag with expected location"),
        ),
      ],
    );
  }

  Widget _errorsView() {
    return Row(
      children: [
        Container(
          height: 50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: const Text("Errors:"),
          ),
        ),
        Flexible(
          child: Text(
            _errorsText,
          ),
        )
      ],
    );
  }

  Widget _gettersView(builder) {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        ElevatedButton(
          onPressed: () async {
            bool isAvailable = await HyperTrack.isAvailable;
            _showSnackBarMessage(builder, "isAvailable: $isAvailable");
          },
          child: Text("isAvailable"),
        ),
        ElevatedButton(
          onPressed: () async {
            bool isTracking = await HyperTrack.isTracking;
            _showSnackBarMessage(builder, "isTracking: $isTracking");
          },
          child: Text("isTracking"),
        ),
        ElevatedButton(
          onPressed: () async {
            final result = await HyperTrack.errors;
            _showSnackBarMessage(builder, result.toString());
          },
          child: Text("Get errors"),
        ),
        ElevatedButton(
          onPressed: () async {
            final result = await HyperTrack.location;
            _showSnackBarMessage(builder, result.toString());
          },
          child: Text("Get location"),
        ),
        ElevatedButton(
          onPressed: () async {
            final result = await HyperTrack.metadata;
            _showSnackBarMessage(builder, result.toString());
          },
          child: Text("Get metadata"),
        ),
        ElevatedButton(
          onPressed: () async {
            final result = await HyperTrack.name;
            _showSnackBarMessage(builder, result.toString());
          },
          child: Text("Get name"),
        ),
        ElevatedButton(
          onPressed: () async {
            final result = await HyperTrack.orders;
            _showSnackBarMessage(builder, _formatOrders(result));
          },
          child: Text("Get orders"),
        ),
      ],
    );
  }

  Widget _isTrackingView() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _button("Start tracking", () => HyperTrack.setIsTracking(true)),
        Expanded(
          child: Column(
            children: [
              Text(
                "isTracking",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(_isTrackingStateText)
            ],
          ),
        ),
        _button("Stop tracking", () => HyperTrack.setIsTracking(false)),
      ],
    );
  }

  Widget _isAvailableView() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _button("Set available", () => HyperTrack.setIsAvailable(true)),
        Expanded(
          child: Column(
            children: [
              Text(
                "isAvailable",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(_isAvailableText)
            ],
          ),
        ),
        _button("Set unavailable", () => HyperTrack.setIsAvailable(false)),
      ],
    );
  }

  Widget _locationSubscriptionView() {
    return Row(
      children: [
        Container(
          height: 50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: const Text("Location:"),
          ),
        ),
        Flexible(
          child: Text(
            _locationText,
          ),
        )
      ],
    );
  }

  Widget _button(String text, Function() onPressed) {
    return Container(
      width: 110,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(text, textAlign: TextAlign.center),
      ),
    );
  }

  Widget _ordersView() {
    return Column(
      children: [
        Text(
          "Orders",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(_ordersText),
      ],
    );
  }

  void _initSubscriptions() {
    HyperTrack.isTrackingSubscription.listen((bool isTracking) {
      if (mounted) {
        _isTrackingStateText = "$isTracking";
        setState(() {});
      }
    }).onError((error) {
      if (mounted) {
        _isTrackingStateText = error.toString();
        setState(() {});
      }
    });
    HyperTrack.isAvailableSubscription.listen((bool isAvailable) {
      if (mounted) {
        _isAvailableText = "${isAvailable}";
        setState(() {});
      }
    }).onError((error) {
      if (mounted) {
        _isAvailableText = error.toString();
        setState(() {});
      }
    });
    HyperTrack.errorsSubscription.listen((errors) {
      if (mounted) {
        if (errors.length == 0) {
          _errorsText = 'No errors';
        } else {
          _errorsText = _formatErrors(errors);
        }
        setState(() {});
      }
    }).onError((error) {
      if (mounted) {
        _errorsText = error.toString();
        setState(() {});
      }
    });
    HyperTrack.locationSubscription.listen((location) {
      if (mounted) {
        _locationText = location.toString();
        setState(() {});
      }
    }).onError((error) {
      if (mounted) {
        _locationText = error.toString();
        setState(() {});
      }
    });
    HyperTrack.ordersSubscription.listen((orders) {
      if (mounted) {
        _ordersText = _formatOrders(orders);
        setState(() {});
      }
    }).onError((error) {
      if (mounted) {
        _ordersText = error.toString();
        setState(() {});
      }
    });
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

  String _formatGeotagResult(Result<Location, LocationError> result) {
    if (result is Success<Location, LocationError>) {
      return result.value.toString();
    } else if (result is Failure<Location, LocationError>) {
      return _formatLocationError(result.failure);
    } else {
      throw Exception("Unknown result type");
    }
  }

  String _formatGeotagWithExpectedLocationResult(
      Result<LocationWithDeviation, LocationError> result) {
    if (result is Success<LocationWithDeviation, LocationError>) {
      return result.value.toString();
    } else if (result is Failure<LocationWithDeviation, LocationError>) {
      return _formatLocationError(result.failure);
    } else {
      throw Exception("Unknown result type");
    }
  }

  String _formatLocateResult(Result<Location, Set<HyperTrackError>> result) {
    if (result is Success<Location, Set<HyperTrackError>>) {
      return result.value.toString();
    } else if (result is Failure<Location, Set<HyperTrackError>>) {
      return _formatErrors(result.failure);
    } else {
      throw Exception("Unknown result type");
    }
  }

  String _formatLocationResult(Result<Location, LocationError> result) {
    if (result is Success<Location, LocationError>) {
      return result.value.toString();
    } else if (result is Failure<Location, LocationError>) {
      return _formatLocationError(result.failure);
    } else {
      throw Exception("Unknown result type");
    }
  }

  String _formatLocationError(LocationError locationError) {
    if (locationError is NotRunning) {
      return "NotRunning";
    } else if (locationError is Starting) {
      return "Starting";
    } else if (locationError is Errors) {
      return _formatErrors(locationError.errors);
    } else {
      throw Exception("Unknown error type");
    }
  }

  String _formatErrors(Set<HyperTrackError> errors) {
    return errors.map((e) => {e.toString().split('.').last}).join("\n");
  }

  String _formatOrders(Map<String, Order> orders) {
    return orders.entries.map((entry) {
      return "${entry.value.orderHandle}: ${_formatIsInsideGeofence(entry.value.isInsideGeofence)}";
    }).join("\n");
  }

  String _formatIsInsideGeofence(Result<bool, LocationError> result) {
    if (result is Success<bool, LocationError>) {
      return result.value.toString();
    } else if (result is Failure<bool, LocationError>) {
      return _formatLocationError(result.failure);
    } else {
      throw Exception("Unknown result type");
    }
  }
}

final JSONObject _testGeotag = JSONObject({
  "source": JSONString("Flutter"),
  "payload": JSONObject({"test_payload": JSONNumber(1)})
});
final _testOrderHandle = "test_order";
final _testOrderStatus = OrderStatus.custom("test_status");
