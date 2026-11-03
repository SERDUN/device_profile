Pod::Spec.new do |s|
  s.name             = 'device_profile'
  s.version          = '0.1.0'
  s.summary          = 'What the device is: its name, its kind and the shape of its display.'
  s.description      = <<-DESC
The name a person knows the device by instead of its hardware code, the kind of device, and the shape of its display.
                       DESC
  s.homepage         = 'https://github.com/SERDUN/device_profile'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Dmytro Serdun' => 'dmitriiserdun@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'device_profile/Sources/device_profile/**/*.swift'
  s.resource_bundles = { 'device_profile_privacy' => ['device_profile/Sources/device_profile/PrivacyInfo.xcprivacy'] }
  s.dependency 'Flutter'
  s.platform = :ios, '15.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
