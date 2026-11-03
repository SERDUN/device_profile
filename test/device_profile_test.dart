// The native channel is asked on Android and iOS only.
@TestOn('vm')
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:device_profile/device_profile.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('device_profile');
  const DeviceProfileReader deviceProfile = PlatformDeviceProfile();

  final calls = <MethodCall>[];

  void answer(Future<Object?> Function() handler) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) {
          calls.add(call);
          return handler();
        });
  }

  setUp(() {
    calls.clear();
    PlatformDeviceProfile.debugForget();
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('Android: the name is chosen from what the platform read', () async {
    answer(
      () async => {
        'manufacturer': 'samsung',
        'brand': 'samsung',
        'model': 'SM-G525F',
        'device': 'xcover5',
        'product': 'xcover5eea',
        'properties': <String, String>{},
        'globalSettings': {'default_device_name': 'Galaxy XCover 5'},
      },
    );

    expect(
      (await deviceProfile.read())?.name,
      const DisplayName(
        'Galaxy XCover 5',
        NameSource.factorySetting,
        key: 'default_device_name',
      ),
    );
  });

  test('Android: one read, with the keys of every maker by brand', () async {
    answer(
      () async => {
        'manufacturer': 'samsung',
        'brand': 'samsung',
        'model': 'SM-G525F',
      },
    );

    await deviceProfile.read();

    final keysByMaker =
        (calls.single.arguments as Map)['keysByMaker'] as Map<Object?, Object?>;
    expect(keysByMaker['samsung'], {
      'properties': ['persist.sys.device_name'],
      'globalSettings': ['default_device_name', 'device_name'],
    });
    expect(keysByMaker.containsKey(null), isTrue);
  });

  test(
    'readSources(allMakerKeys) asks for every key and is not kept',
    () async {
      answer(
        () async => {'manufacturer': 'Acme', 'brand': 'Acme', 'model': 'AC-1'},
      );

      await const PlatformDeviceProfile().readSources(allMakerKeys: true);
      final keysByMaker =
          (calls.single.arguments as Map)['keysByMaker']
              as Map<Object?, Object?>;
      expect(keysByMaker.keys, [null]);
      expect(
        (keysByMaker[null] as Map)['properties'],
        contains('ro.vendor.oplus.market.name'),
      );

      await deviceProfile.read();
      expect(calls, hasLength(2));
    },
  );

  test('iOS: the identifier is looked up in the table', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    answer(() async => {'machine': 'iPhone13,1'});

    expect(
      (await deviceProfile.read())?.name,
      const DisplayName(
        'iPhone 12 mini',
        NameSource.identifierTable,
        key: 'iPhone13,1',
      ),
    );
  });

  test(
    'iOS: an identifier the table does not know is given as it is',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      answer(() async => {'machine': 'iPhone99,1'});

      expect(
        (await deviceProfile.read())?.name,
        const DisplayName('iPhone99,1', NameSource.identifier),
      );
    },
  );

  test('the platform is asked once', () async {
    answer(
      () async => {
        'manufacturer': 'Google',
        'brand': 'google',
        'model': 'Pixel 9',
      },
    );

    await deviceProfile.read();
    await deviceProfile.read();

    expect(calls, hasLength(1));
  });

  test('the user-assigned name is used only when allowed', () async {
    answer(
      () async => {
        'manufacturer': 'samsung',
        'brand': 'samsung',
        'model': 'SM-G525F',
        'globalSettings': {'device_name': "Anna's XCover 5"},
      },
    );

    expect(
      (await const PlatformDeviceProfile().read())!.name.source,
      NameSource.brandAndModel,
    );
    expect(
      (await const PlatformDeviceProfile(
        userAssignedName: UserAssignedName.fallback,
      ).read())!.name.source,
      NameSource.userAssigned,
    );
  });

  test('a platform error answers null', () async {
    answer(() async => throw PlatformException(code: 'boom'));

    expect(await deviceProfile.read(), isNull);
  });

  test('a failure is not remembered', () async {
    answer(() async => throw PlatformException(code: 'boom'));
    expect(await deviceProfile.read(), isNull);

    answer(
      () async => {
        'manufacturer': 'Google',
        'brand': 'google',
        'model': 'Pixel 9',
      },
    );
    expect((await deviceProfile.read())!.name.name, 'Pixel 9');
  });

  test(
    'a platform without a native side answers null without asking',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      answer(() async => {'model': 'x'});

      expect(await deviceProfile.read(), isNull);
      expect(calls, isEmpty);
    },
  );

  test('readSources gives the raw values for diagnostics', () async {
    answer(
      () async => {
        'manufacturer': 'Google',
        'brand': 'google',
        'model': 'Pixel 9',
      },
    );

    expect(
      await const PlatformDeviceProfile().readSources(),
      containsPair('model', 'Pixel 9'),
    );
  });

  test(
    'Android: the shape and the kind come with the name, from the same read',
    () async {
      answer(
        () async => {
          'manufacturer': 'Google',
          'brand': 'google',
          'model': 'Pixel Watch 3',
          'features': ['android.hardware.type.watch'],
          'smallestScreenWidthDp': 192,
          'isScreenRound': true,
        },
      );

      final profile = await deviceProfile.read();
      expect(profile?.kind, DeviceKind.watch);
      expect(profile?.screenShape, ScreenShape.round);
      expect(calls, hasLength(1));
    },
  );

  test(
    'Android: a platform side that does not report the shape reads rectangular',
    () async {
      answer(
        () async => {
          'manufacturer': 'Google',
          'brand': 'google',
          'model': 'Pixel 9',
        },
      );

      expect(
        (await deviceProfile.read())?.screenShape,
        ScreenShape.rectangular,
      );
    },
  );

  test('iOS: a rectangular display, the kind from the idiom', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    answer(() async => {'machine': 'iPhone13,1', 'idiom': 'phone'});

    final profile = await deviceProfile.read();
    expect(profile?.name.name, 'iPhone 12 mini');
    expect(profile?.kind, DeviceKind.phone);
    expect(profile?.screenShape, ScreenShape.rectangular);
  });
}
