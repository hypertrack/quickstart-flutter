# Flutter Quickstart for HyperTrack SDK

![GitHub](https://img.shields.io/github/license/hypertrack/quickstart-flutter.svg)
[![Pub Version](https://img.shields.io/pub/v/hypertrack_plugin?color=blueviolet)](https://pub.dev/packages/hypertrack_plugin)

[HyperTrack](https://www.hypertrack.com) lets you add live location tracking to your mobile app.
Live location is made available along with ongoing activity, tracking controls and tracking outage with reasons.

This repo contains an example Flutter app that has everything you need to get started.

For information about how to get started with Flutter SDK, please check this [Guide](https://www.hypertrack.com/docs/install-sdk-flutter).

## How to get started?

### Create HyperTrack Account

[Sign up](https://dashboard.hypertrack.com/signup) for HyperTrack and get your publishable key from the [Setup page](https://dashboard.hypertrack.com/setup).

### Set up the environment

You need to [set up the development environment for Flutter](https://docs.flutter.dev/get-started/install)

### Clone Quickstart app

### Install Dependencies

Run `flutter pub get`

### Update the publishable key

Insert your HyperTrack publishable key to `_publishableKey` in [main.dart](lib/main.dart)

### [Set up silent push notifications](https://hypertrack.com/docs/install-sdk-flutter/#set-up-silent-push-notifications)

HyperTrack SDK needs Firebase Cloud Messaging to manage on-device tracking as well as enable using HyperTrack cloud APIs from your server to control the tracking.

### Run the app

### Grant permissions

Grant location and activity permissions (choose "Always Allow" for location).

### Start tracking

Press `Start tracking` button.

To see the device on a map, open the [HyperTrack dashboard](https://dashboard.hypertrack.com/).

## Support

Join our [Slack community](https://join.slack.com/t/hypertracksupport/shared_invite/enQtNDA0MDYxMzY1MDMxLTdmNDQ1ZDA1MTQxOTU2NTgwZTNiMzUyZDk0OThlMmJkNmE0ZGI2NGY2ZGRhYjY0Yzc0NTJlZWY2ZmE5ZTA2NjI) for instant responses. You can also email us at help@hypertrack.com
