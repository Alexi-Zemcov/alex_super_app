#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint pitch_detection.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'pitch_detection'
  s.version          = '0.1.0'
  s.summary          = 'Shared microphone pitch detection plugin for Flutter modules.'
  s.description      = <<-DESC
Shared microphone pitch detection plugin for Flutter modules.
                       DESC
  s.homepage         = 'https://github.com/AudioKit/AudioKit'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Alex Super App' => 'devnull@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'pitch_detection/Sources/pitch_detection/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  s.resource_bundles = {'pitch_detection_privacy' => ['pitch_detection/Sources/pitch_detection/PrivacyInfo.xcprivacy']}
end
