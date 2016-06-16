Pod::Spec.new do |s|
  s.name             = "SlateOfflineMessageQueue"
  s.version          = "3.4.2.1"
  s.summary          = "A offline message queue."
  s.description      = <<-DESC
			A offline message queue. Store messages in a queue when network offline, then post message when network come back online. 
                       DESC
  s.homepage         = "https://github.com/islate/SlateOfflineMessageQueue"
  s.license          = 'Apache 2.0'
  s.author           = { "mengxiangjian" => "mengxiangjian13@163.com" }
  s.source           = { :git => "https://github.com/islate/SlateOfflineMessageQueue.git", :tag => s.version.to_s }
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source_files = 'SlateOfflineMessageQueue/*.{h,m}'
  s.dependency 'SlateReachability'
end
