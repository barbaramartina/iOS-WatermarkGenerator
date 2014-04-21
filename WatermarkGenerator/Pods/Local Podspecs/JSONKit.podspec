Pod::Spec.new do |s|
  s.name     = 'JSONKit'
  s.version  = '1.5pre'
  s.license  = 'BSD / Apache License, Version 2.0'
  s.summary  = 'A Very High Performance Objective-C JSON Library.'
  s.homepage = 'https://github.com/heroims/JSONKit'
  s.author   = 'John Engelhart'
  s.source   = { :git => 'https://github.com/heroims/JSONKit', :commit => 'bcb1e9823cb8e8003ed5a97b23a93ceafb2240b3' }

  s.source_files   = 'JSONKit.*'
end
