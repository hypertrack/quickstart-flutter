alias a := add-plugin
alias ag := add-plugin-github
alias al := add-plugin-local
alias ap := add-plugin
alias c := clean
alias ogp := open-github-prs
alias oi := open-ios
alias pi := pod-install
alias ra := run-android
alias s := setup
alias us := update-sdk
alias v := version
alias va := version-android

SDK_NAME := "HyperTrack SDK Flutter"
SDK_REPOSITORY_NAME := "sdk-flutter"
QUICKSTART_REPOSITORY_NAME := "quickstart-flutter"

# Source: https://semver.org/#is-there-a-suggested-regular-expression-regex-to-check-a-semver-string
# \ are escaped
SEMVER_REGEX := "(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)(?:-((?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\\.(?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\\+([0-9a-zA-Z-]+(?:\\.[0-9a-zA-Z-]+)*))?"

add-plugin version: hooks
    flutter pub add hypertrack_plugin:{{version}}
    just pod-install

add-plugin-local: hooks
    flutter pub add hypertrack_plugin --path ../{{SDK_REPOSITORY_NAME}}
    just pod-install

add-plugin-github branch: hooks
    flutter pub add hypertrack_plugin --git-url=https://github.com/hypertrack/{{SDK_REPOSITORY_NAME}} --git-ref={{branch}}
    just pod-install

clean: hooks
    flutter clean

get-dependencies: hooks
    flutter pub get

hooks:
    chmod +x .githooks/pre-push
    git config core.hooksPath .githooks

open-github-prs:
    open "https://github.com/hypertrack/{{QUICKSTART_REPOSITORY_NAME}}/pulls"

open-ios:
    open ios/Runner.xcworkspace

pod-install: hooks
    #!/usr/bin/env sh
    cd ios
    rm -f Podfile.lock
    pod install --repo-update
    cd ..

run-android: hooks
    flutter run

setup: get-dependencies hooks

update-sdk version: hooks
    git checkout -b update-sdk-{{version}}
    just add-plugin {{version}}
    git commit -am "Update {{SDK_NAME}} to {{version}}"
    just open-github-prs

version:
    #!/usr/bin/env sh
    echo "Not implemented"

version-android:
    #!/usr/bin/env sh
    set -euo pipefail
    cd android
    ./gradlew app:dependencies | grep "com.hypertrack:sdk-android" | head -n 1 | grep -o -E '{{SEMVER_REGEX}}'
    cd ..
