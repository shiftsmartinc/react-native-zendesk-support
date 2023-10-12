require "json"

json = File.read(File.join(__dir__, "package.json"))
package = JSON.parse(json).deep_symbolize_keys

Pod::Spec.new do |s|
  s.name = package[:name].include?("/") ? package[:name].split("/").last : package[:name]
  s.version = package[:version]
  s.license = package[:license]
  s.authors = package[:author]
  s.summary = package[:description]
  s.source = { :git => 'https://github.com/shiftsmartinc/react-native-zendesk-support.git',  :tag => 'v'+s.version.to_s }
  s.homepage = 'https://github.com/shiftsmartinc/react-native-zendesk-support'
  s.source_files   = 'ios/RNZenDeskSupport.{h,m}'
  s.static_framework = true

  s.platform = :ios, "10"

  s.framework    = 'Foundation'
  s.framework    = 'UIKit'

  # Deprecated and renamed after 4 to ZendeskSupportSDK and SupportProviderSDK
  s.dependency 'ZendeskSDK', '~> 3.0.3'
  s.dependency "React-Core"
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
end
