# HyperTrack Quickstart for Flutter SDK

![GitHub](https://img.shields.io/github/license/hypertrack/quickstart-flutter.svg)
[![Pub Version](https://img.shields.io/pub/v/hypertrack_plugin?color=blueviolet)](https://pub.dev/packages/hypertrack_plugin)
[![iOS SDK](https://img.shields.io/badge/iOS%20SDK-4.7.0-brightgreen.svg)](https://cocoapods.org/pods/HyperTrack)
![Android SDK](https://img.shields.io/badge/Android%20SDK-5.2.5-brightgreen.svg)

[HyperTrack](https://www.hypertrack.com) lets you add live location tracking to your mobile app.
Live location is made available along with ongoing activity, tracking controls and tracking outage with reasons.
This repo contains an example Flutter app that has everything you need to get started in minutes.

## Create HyperTrack Account

[Sign up](https://dashboard.hypertrack.com/signup) for HyperTrack and 
get your publishable key from the [Setup page](https://dashboard.hypertrack.com/setup).

## Clone Quickstart app

Clone the app and import the source using your favorite Android IDE.

Install Flutter package and setup the environment for both Android and IOS using the steps provided [here](https://flutter.dev/docs/get-started/install).

### Set your Publishable Key

Open the Quickstart project inside the workspace and set your Publishable Key (from [Setup page](https://dashboard.hypertrack.com/setup)) inside the placeholder in the [`main.dart`](https://github.com/hypertrack/quickstart-flutter/blob/master/lib/main.dart#L14) file.

### Set up Firebase

1. [Set up Firebase for Flutter](https://firebase.google.com/docs/flutter/setup)
2. [Set up Firebase for Hypertrack](https://hypertrack.com/docs/install-sdk-android)

### Run the app

Run the app on your phone. Grant location and activity permissions when prompted.

> HyperTrack creates a unique internal device identifier that's used as mandatory key for all HyperTrack API calls.
> Please be sure to get the `device_id` from the app or the logs. The app calls
> [getDeviceId](https://hypertrack.com/docs/references/#references-sdks-android-get-device-id) to retrieve it.

You may also set device name and metadata using the [Devices API](https://hypertrack.com/docs/references/#references-apis-devices-set-device-name-and-metadata)

## Start tracking

Now the app is ready to be tracked from the cloud. HyperTrack gives you powerful APIs
to control device tracking from your backend.

> To use the HyperTrack API, you will need the `{AccountId}` and `{SecretKey}` from the [Setup page](https://dashboard.hypertrack.com/setup).

### Track devices during work

Track devices when user is logged in to work, or during work hours by calling the 
[Devices API](https://hypertrack.com/docs/references/#references-apis-devices).

To start, call the [start](https://hypertrack.com/docs/references/#references-apis-devices-start-tracking) API.

```
curl -X POST \
  -u {AccountId}:{SecretKey} \
  https://v3.api.hypertrack.com/devices/{device_id}/start
```


Get the tracking status of the device by calling
[GET /devices/{device_id}](https://hypertrack.com/docs/references/#references-apis-devices-get-device-location-and-status) api.

```
curl \
  -u {AccountId}:{SecretKey} \
  https://v3.api.hypertrack.com/devices/{device_id}
```

To see the device on a map, open the returned embed_url in your browser (no login required, so you can add embed these views directly to you web app).
The device will also show up in the device list in the [HyperTrack dashboard](https://dashboard.hypertrack.com/).

To stop tracking, call the [stop](https://hypertrack.com/docs/references/#references-apis-devices-stop-tracking) API.

```
curl -X POST \
  -u {AccountId}:{SecretKey} \
  https://v3.api.hypertrack.com/devices/{device_id}/stop
```

### Track trips with ETA

If you want to track a device on its way to a destination, call the [Trips API](https://hypertrack.com/docs/references/#references-apis-trips-start-trip)
and add destination.

HyperTrack Trips API offers extra fields to get additional intelligence over the Devices API.
* set destination to track route and ETA
* set scheduled_at to track delays
* share live tracking URL of the trip with customers 
* embed live tracking view of the trip in your ops dashboard 

```curl
curl -u {AccountId}:{SecretKey} --location --request POST 'https://v3.api.hypertrack.com/trips/' \
--header 'Content-Type: application/json' \
--data-raw '{
    "device_id": "{device_id}",
    "destination": {
        "geometry": {
            "type": "Point",
            "coordinates": [{longitude}, {latitude}]
        }
    }
}'
```

To get `{longitude}` and `{latitude}` of your destination, you can use for example [Google Maps](https://support.google.com/maps/answer/18539?co=GENIE.Platform%3DDesktop&hl=en).

> HyperTrack uses [GeoJSON](https://en.wikipedia.org/wiki/GeoJSON). Please make sure you follow the correct ordering of longitude and latitude.

The returned JSON includes the embed_url for your dashboard and share_url for your customers.

When you are done tracking this trip, call [complete](https://docs.hypertrack.com/#references-apis-trips-post-trips-trip_id-complete) Trip API using the `trip_id` from the create trip call above.
```
curl -X POST \
  -u {AccountId}:{SecretKey} \
  https://v3.api.hypertrack.com/trips/{trip_id}/complete
```

After the trip is completed, use the [Trips API](https://hypertrack.com/docs/references/#references-apis-trips-complete-trip) to
retrieve a full [summary](https://hypertrack.com/docs/references/#references-apis-trips-get-trip-summary) of the trip.
The summary contains the polyline of the trip, distance, duration and markers of the trip.

```
curl -X POST \
  -u {AccountId}:{SecretKey} \
  https://v3.api.hypertrack.com/trips/{trip_id}
```
 

### Track trips with geofences

If you want to track a device going to a list of places, call the [Trips API](https://hypertrack.com/docs/references/#references-apis-trips-start-trip-with-geofences)
and add geofences. This way you will get arrival, exit, time spent and route to geofences. Please checkout our [docs](https://hypertrack.com/docs/references/#references-apis-trips) for more details.

## Dashboard

Once your app is running, go to the [dashboard](https://dashboard.hypertrack.com/devices) where you can see a list of all your devices and their live location with ongoing activity on the map.

## Documentation

You can find API references in our [docs](https://hypertrack.com/docs/references/#references-sdks-android). There is also a full in-code reference for all SDK methods.

## Support
Join our [Slack community](https://join.slack.com/t/hypertracksupport/shared_invite/enQtNDA0MDYxMzY1MDMxLTdmNDQ1ZDA1MTQxOTU2NTgwZTNiMzUyZDk0OThlMmJkNmE0ZGI2NGY2ZGRhYjY0Yzc0NTJlZWY2ZmE5ZTA2NjI) for instant responses. You can also email us at help@hypertrack.com.
