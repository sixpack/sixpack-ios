Pod::Spec.new do |s|
  s.name         = "Sixpack-iOS"
  s.version      = "1.1.0"
  s.summary      = "iOS client library for Sixpack AB testing."
  s.homepage     = "http://sixpack.seatgeek.com"
  s.license      = 'FreeBSD License'
  s.author       = { "James Van-As" => "james@seatgeek.com" }
  s.source       = { :git => 'https://github.com/seatgeek/sixpack-ios.git', :tag => '1.1.0' }
  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Sixpack-iOS/**/*.{h,m}'
  s.prefix_header_file = 'SixpackClient-Prefix.pch'
  s.dependency     'SGHTTPRequest'
end
