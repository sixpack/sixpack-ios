#
# Be sure to run `pod spec lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about the attributes see http://docs.cocoapods.org/specification.html
#
Pod::Spec.new do |s|
  s.name         = "Sixpack-iOS"
  s.version      = "0.0.2"
  s.summary      = "iOS client library for Sixpack AB testing."
  s.homepage     = "http://www.seatgeek.com"
  s.license      = 'BSD 2 License'
  s.author       = { "James Van-As" => "james@seatgeek.com" }
  s.source       = { :git => 'https://github.com/seatgeek/sixpack-ios.git', :tag => '0.0.1' }

  s.platform     = :ios, '6.0'
  s.ios.deployment_target = '6.0'
  s.requires_arc = true

  s.source_files = 'Classes'
  s.dependency     'AFNetworking', '>= 2.0.0'
end
