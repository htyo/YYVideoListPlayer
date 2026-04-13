#
# Be sure to run `pod lib lint YYVideoListPlayer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YYVideoListPlayer'
  s.version          = '1.0.5'
  s.summary          = 'iOS video list player built on ZFPlayer for smooth scrolling playback.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
YYVideoListPlayer provides a lightweight video list experience for iOS using
ZFPlayer/AVPlayer. It focuses on smooth scrolling playback, reusable player
views, and simple integration for feed-style UIs.
                       DESC

  s.homepage         = 'https://github.com/htyo/YYVideoListPlayer'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'htyo' => 'arno.yy.chen@icloud.com' }
  s.source           = { :git => 'https://github.com/htyo/YYVideoListPlayer.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'

  s.source_files = 'YYVideoListPlayer/Classes/**/*'
  
  # s.resource_bundles = {
  #   'YYVideoListPlayer' => ['YYVideoListPlayer/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.static_framework = true
  s.dependency 'ZFPlayer/AVPlayer'
  s.dependency 'MJRefresh'
#  s.dependency 'Masonry'

end
