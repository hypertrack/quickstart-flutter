alias a := add-plugin
alias ag := add-plugin-github
alias al := add-plugin-local
alias ap := add-plugin
alias c := clean
alias oi := open-ios
alias ra := run-android
alias s := setup

add-plugin version: hooks
    flutter pub add hypertrack_plugin:{{version}}

add-plugin-local: hooks
    flutter pub add hypertrack_plugin --path ../sdk-flutter

add-plugin-github branch: hooks
    flutter pub add hypertrack_plugin --git-url=https://github.com/hypertrack/sdk-flutter --git-ref={{branch}}

clean: hooks
    flutter clean

get-dependencies: hooks
    flutter pub get

hooks:
    chmod +x .githooks/pre-push
    git config core.hooksPath .githooks

open-ios:
    open ios/Runner.xcworkspace

run-android: hooks
    flutter run

setup: get-dependencies hooks
