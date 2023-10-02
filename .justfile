alias al := use-local-dependency
alias g := get-dependencies
alias a := use-dependency
alias ag := use-github-dependency
alias ra := run-android
alias oi := open-ios

run-android: hooks
    flutter run

get-dependencies: hooks
    flutter pub get

use-local-dependency: hooks
    flutter pub add hypertrack_plugin --path ../sdk-flutter

use-dependency version: hooks
    flutter pub add hypertrack_plugin:{{version}}

use-github-dependency branch: hooks
    flutter pub add hypertrack_plugin --git-url=https://github.com/hypertrack/sdk-flutter --git-ref={{branch}}

hooks:
    chmod +x .githooks/pre-push
    git config core.hooksPath .githooks

open-ios:
    open ios/Runner.xcworkspace
