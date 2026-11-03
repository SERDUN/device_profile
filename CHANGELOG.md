## 0.1.1

- The package description and the README open with all three things the profile tells: the name, the kind
  and the shape of the display.

## 0.1.0

### Added

- `PlatformDeviceProfile.read()`, behind the `DeviceProfileReader` interface, giving a `DeviceProfile`: what the
  device is, from one read of the platform.
- `DeviceProfile.name`: a `DisplayName` with the name, its `NameSource` and the key it was read from.
- Android: the maker's factory name from `Settings.Global` (Samsung `default_device_name`, Huawei/Honor
  `unified_default_device_name`, vivo `wifi_hotspot_default_name`) or from its system properties (Xiaomi,
  OPPO/realme/OnePlus, vivo, Huawei, ZTE, Transsion, Lenovo/Motorola, HMD, Sony, Asus, LG, Umidigi);
  `Build.MODEL` when it already is a name; the brand and the model otherwise. Placeholders, codenames and hardware
  codes are rejected. Only the device maker's keys are read (`androidKeysFor`).
- Android: the user-assigned name through `userAssignedName`: `never` (default), `fallback` or `preferred`.
- iOS: the hardware identifier looked up in a generated table of Apple identifiers; the identifier itself when the
  table does not know it.
- `DeviceProfile.kind` (`DeviceKind`: phone, tablet, foldable, watch, tv, car, desktop, headset, unknown) from the
  Android system features, `ro.build.characteristics` and the smallest screen width, or the iOS interface idiom.
- `DeviceProfile.screenShape` (`ScreenShape.round` or `rectangular`): Android's `Configuration.isScreenRound`, read
  in the same call as the name; always rectangular on iOS.
- `chooseAndroidProfile`, `chooseIosProfile`, and `chooseAndroidName`, `chooseIosName` for the name alone.
- `DisplayName.fullName` with the brand in front, `DisplayName.userAgentToken` and `userAgentToken(String)` safe
  for a header, and `distinctLabels` for a list of devices that share a name.
- `readSources()` with the raw values the platform read.
- Other platforms, and every failure, answer `null`.

### Requirements

- Flutter 3.47 or later; Android 7.0 (API 24) or later, built with Android Gradle Plugin 8.13 or later; iOS 15 or
  later.
