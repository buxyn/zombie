require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "ZombieGps"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :ios => min_ios_version_supported }
  s.source       = { :git => "https://github.com/nanikasi/react-native-zombie-gps.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,mm,cpp}"
  s.exclude_files = "ios/TestRunner/**"
  s.public_header_files = [
    "ios/ZombieGps.h",
    "ios/ZombieGpsBackgroundWorker.h",
  ]
  s.resource_bundles = {
    'ZombieGps_Privacy' => ['ios/PrivacyInfo.xcprivacy']
  }


  install_modules_dependencies(s)
end
