Pod::Spec.new do |s|
  s.name             = "DreemNav"
  s.version          = "1.3.0"
  s.summary          = "Developer friendly library designed to easily setup navigation through your SwiftUI app."
  s.homepage         = "https://github.com/Dreem-Organization/dreem-ios-navigation"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "Vincent Lemonnier" => "vincent.lemonnier@dreem.com" }
  s.source           = { :git => "https://github.com/Dreem-Organization/dreem-ios-navigation",
                         :tag => s.version.to_s }
  s.source_files     = "Sources/*.swift"
  s.requires_arc     = true

  s.ios.deployment_target = "14.0"
end