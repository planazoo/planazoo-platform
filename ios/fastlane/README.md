fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios build_only

```sh
[bundle exec] fastlane ios build_only
```

Solo compilar IPA (sin subir). Útil para comprobar que el build funciona sin tener cuenta Apple activa.

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Subir build a TestFlight (beta)

### ios release

```sh
[bundle exec] fastlane ios release
```

Subir build a App Store (release)

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
