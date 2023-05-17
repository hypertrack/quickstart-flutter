alias ul := use-local-dependency
alias g := get-dependencies

get-dependencies: hooks
    flutter pub get

use-local-dependency:
    flutter pub add hypertrack_plugin --path ../sdk-flutter

hooks:
    chmod +x .githooks/pre-push
    git config core.hooksPath .githooks
