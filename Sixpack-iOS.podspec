Pod::Spec.new do |s|
  s.name         = "Sixpack-iOS"
  s.version      = "1.0"
  s.summary      = "iOS client library for Sixpack AB testing."
  s.homepage     = "http://www.seatgeek.com"
  s.license      = 'FreeBSD License'
  s.author       = { "James Van-As" => "james@seatgeek.com" }
  s.source       = { :git => 'https://github.com/seatgeek/sixpack-ios.git', :tag => '0.0.3' }

  s.platform     = :ios, '6.0'
  s.ios.deployment_target = '6.0'
  s.requires_arc = true

  s.source_files = 'Classes/*.h'
  s.dependency     'AFNetworking', '>= 2.0.0'

  s.subspec 'Private' do |ss|
    ss.prefix_header_file = 'SixpackClient-Prefix.pch'
    ss.source_files = 'Classes/Private/*.{m,h}'
  end
end
