Pod::Spec.new do |s|
  s.name             = "SlateOfflineMessageQueue"
  s.version          = "0.1.0"
  s.summary          = "A offline message queue."
  s.description      = <<-DESC
			A offline message queue. Store messages in a queue when network offline, then post message when network come back online. 
                       DESC
  s.homepage         = "https://github.com/mmslate/SlateOfflineMessageQueue"
  s.license          = 'MIT'
  s.author           = { "mengxiangjian" => "mengxiangjian13@163.com" }
  s.source           = { :git => "https://github.com/mmslate/SlateOfflineMessageQueue.git", :tag => s.version.to_s }
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source_files = '*.{h,m}'
  s.dependency 'SlateURLProtocol', '~> 0.1.0'
end
