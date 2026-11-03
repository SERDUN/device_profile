// Runs on a device, against the real platform side:
//
//   flutter test integration_test -d <device>

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:device_profile/device_profile.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const DeviceProfileReader deviceProfile = PlatformDeviceProfile();

  testWidgets('read gives a profile with a name', (tester) async {
    final profile = await deviceProfile.read();

    expect(profile, isNotNull);
    expect(profile!.name.name, isNotEmpty);
  });

  testWidgets('the platform reports the shape of the display', (tester) async {
    final sources = await const PlatformDeviceProfile().readSources();

    expect(
      sources,
      anyOf(containsPair('isScreenRound', isA<bool>()), contains('machine')),
    );
  });

  testWidgets('the platform reads the build fields', (tester) async {
    final sources = await const PlatformDeviceProfile().readSources();

    expect(sources, isNotNull);
    expect(sources!.keys, anyOf(contains('model'), contains('machine')));
  });
}
