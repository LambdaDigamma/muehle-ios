#
# Be sure to run `pod lib lint TVButton.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "TVButton"
  s.version          = "0.1.5"
  s.summary          = "Apple TV style parallax icons as iOS UIButtons"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description      = <<-DESC
                        Recreating the cool parallax icons from Apple TV as iOS UIButtons (in Swift).
                       DESC

  s.homepage         = "https://github.com/marmelroy/TVButton"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Roy Marmelstein" => "marmelroy@gmail.com" }
  s.source           = { :git => "https://github.com/marmelroy/TVButton.git", :tag => s.version.to_s }
  s.social_media_url   = "http://twitter.com/marmelroy"

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = "TVButton"
  s.resources = "TVButton/Specular.png"

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.dependency 'AFNetworking', '~> 2.3'
end
