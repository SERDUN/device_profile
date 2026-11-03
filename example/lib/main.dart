import 'package:flutter/material.dart';

import 'package:device_profile/device_profile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const _deviceProfile = PlatformDeviceProfile();
  static const _withUserName = PlatformDeviceProfile(
    userAssignedName: UserAssignedName.preferred,
  );

  DeviceProfile? _profile;
  DeviceProfile? _profileWithUserName;
  Map<Object?, Object?>? _sources;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await _deviceProfile.read();
    final profileWithUserName = await _withUserName.read();
    final sources = await _deviceProfile.readSources();
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _profileWithUserName = profileWithUserName;
      _sources = sources;
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('device_profile')),
        body: !_loaded
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _ProfileTile(title: 'Profile', profile: _profile),
                  _ProfileTile(
                    title: 'Profile, user-assigned name preferred',
                    profile: _profileWithUserName,
                  ),
                  const Divider(),
                  Text(
                    'What the platform read',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  for (final line in _lines(_sources))
                    SelectableText(line, key: ValueKey(line)),
                ],
              ),
      ),
    );
  }

  static Iterable<String> _lines(Map<Object?, Object?>? sources) sync* {
    if (sources == null) {
      yield 'nothing - the platform is not supported';
      return;
    }
    for (final MapEntry(:key, :value) in sources.entries) {
      if (value is Map) {
        for (final MapEntry(key: inner, value: innerValue) in value.entries) {
          yield '$key / $inner = $innerValue';
        }
        if (value.isEmpty) yield '$key = (none readable)';
      } else {
        yield '$key = $value';
      }
    }
  }
}

IconData _iconOf(DeviceKind kind) => switch (kind) {
  DeviceKind.phone => Icons.smartphone,
  DeviceKind.tablet => Icons.tablet_android,
  DeviceKind.foldable => Icons.devices_fold,
  DeviceKind.watch => Icons.watch,
  DeviceKind.tv => Icons.tv,
  DeviceKind.car => Icons.directions_car,
  DeviceKind.desktop => Icons.laptop,
  DeviceKind.headset => Icons.vrpano,
  DeviceKind.unknown => Icons.device_unknown,
};

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({required this.title, required this.profile});

  final String title;
  final DeviceProfile? profile;

  @override
  Widget build(BuildContext context) {
    final name = profile?.name;
    return ListTile(
      leading: Icon(_iconOf(profile?.kind ?? DeviceKind.unknown)),
      title: Text(name?.name ?? '-'),
      subtitle: Text(
        name == null
            ? title
            : '$title - ${name.source.name}${name.key == null ? '' : ' (${name.key})'}\n'
                  'kind: ${profile!.kind.name} - screen: ${profile!.screenShape.name} - full: ${name.fullName}\n'
                  'User-Agent: ${name.userAgentToken}',
      ),
    );
  }
}
