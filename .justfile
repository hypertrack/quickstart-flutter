alias ul := use-local-dependency
alias g := get-dependencies
alias us := use-sdk-dependency

get-dependencies: hooks
    flutter pub get

use-local-dependency:
    flutter pub add hypertrack_plugin --path ../sdk-flutter

use-sdk-dependency version:
    flutter pub add hypertrack_plugin:{{version}}

hooks:
    chmod +x .githooks/pre-push
    git config core.hooksPath .githooks
