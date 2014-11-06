#
# Be sure to run `pod lib lint LGALibrary.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "LGALibrary"
  s.version          = "1.2.5"
  s.summary          = "A collection of utilities and categories."
  s.description      = <<-DESC
                        A collection of utilities and categories for iOS development.
                       DESC
  s.homepage         = "https://github.com/loicgardiol/LGALibrary"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Loic Gardiol" => "loic.gardiol@gmail.com" }
  s.source           = { :git => "https://github.com/loicgardiol/LGALibrary.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resources = 'Pod/Assets/*'
  s.preserve_paths = "Pod/Assets/*.lproj"

  # s.public_header_files = 'Pod/Classes/**/*.h'
    s.frameworks = 'Foundation', 'UIKit', 'MapKit'
    s.dependency 'AFNetworking', '~> 2.3'
end
