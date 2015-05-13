Pod::Spec.new do |s|
  s.name    = 'YammerSDK'
  s.version = '1.0'
  s.summary = 'YammerSDK'
  s.author = { 'Yammer' => 'ios@yammer-inc.com' }
  s.homepage = 'https://github.com/yammer/ios-oauth-demo'
  s.license = { :type => 'Apache', :file => 'LICENSE' }

  s.source = { :git => 'https://github.com/yammer/ios-oauth-demo.git', :tag => s.version.to_s }
  s.source_files = 'OAuthSDK/*.{h,m}'
  s.requires_arc = true
  s.ios.deployment_target = '7.0'

  s.dependency 'AFNetworking', '~> 2.0'
  s.dependency 'PDKeychainBindingsController'
end
