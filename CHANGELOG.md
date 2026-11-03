## 0.1.0

The first release as `device_profile`, the successor of
[device_display_name](https://pub.dev/packages/device_display_name) 0.1.1: what the device is, from one read of the
platform - its name, its kind and the shape of its display.

### Added

- `DeviceProfile` with `name` (`DisplayName`), `kind` (`DeviceKind`) and `screenShape` (`ScreenShape`), given by
  `PlatformDeviceProfile.read()` behind the `DeviceProfileReader` interface.
- `ScreenShape.round` or `ScreenShape.rectangular`: Android's `Configuration.isScreenRound`, read in the same call as
  the name; always rectangular on iOS.
- `chooseAndroidProfile` and `chooseIosProfile`, which turn what the platform read into a profile.

### Changed (from device_display_name 0.1.1)

- `DisplayName` no longer carries the kind: it is `DeviceProfile.kind`.
- `chooseIosName` takes only the identifier; the idiom goes to `chooseIosProfile`.
- The method channel and the Android package are `device_profile` and `com.serdun.device_profile`.

Everything else - where the name is read, the user-assigned modes, `userAgentToken`, `distinctLabels`,
`readSources()` - is as in device_display_name 0.1.1.

### Requirements

- Flutter 3.47 or later; Android 7.0 (API 24) or later, built with Android Gradle Plugin 8.13 or later; iOS 15 or
  later.
