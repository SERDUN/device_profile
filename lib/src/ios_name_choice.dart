import '../device_profile.dart';
import 'apple_identifiers.g.dart';

/// Names an Apple device by its hardware identifier ("iPhone13,1").
///
/// iOS has no public API that returns the marketing name, and `UIDevice.name`
/// is just "iPhone" since iOS 16, so a table is the only way. A device newer
/// than the table is named by its identifier, which still tells two models
/// apart.
DisplayName chooseIosName(String machine) {
  final name = appleIdentifiers[machine];
  return name != null
      ? DisplayName(name, NameSource.identifierTable, key: machine)
      : DisplayName(machine, NameSource.identifier);
}

/// The whole profile of an Apple device: its name by [chooseIosName], its
/// kind by the interface [idiom], and a rectangular display - no iPhone or
/// iPad display is round.
DeviceProfile chooseIosProfile(String machine, {String? idiom}) =>
    DeviceProfile(
      name: chooseIosName(machine),
      kind: iosKind(idiom),
      screenShape: ScreenShape.rectangular,
    );
