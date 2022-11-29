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

  if ENV['RCT_NEW_ARCH_ENABLED'] == '1' then
    s.compiler_flags = folly_compiler_flags + " -DRCT_NEW_ARCH_ENABLED=1"
    s.pod_target_xcconfig    = {
        "HEADER_SEARCH_PATHS" => "\"$(PODS_ROOT)/boost\"",
        "OTHER_CPLUSPLUSFLAGS" => "-DFOLLY_NO_CONFIG -DFOLLY_MOBILE=1 -DFOLLY_USE_LIBCPP=1",
        "CLANG_CXX_LANGUAGE_STANDARD" => "c++17"
    }
    s.dependency "React-RCTFabric"
    s.dependency "React-Codegen"
    s.dependency "RCT-Folly"
    s.dependency "RCTRequired"
    s.dependency "RCTTypeSafety"
    s.dependency "ReactCommon/turbomodule/core"
  end
end
