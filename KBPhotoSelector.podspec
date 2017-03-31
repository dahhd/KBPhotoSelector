#
#  Be sure to run `pod spec lint KBPhotoSelector.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#


Pod::Spec.new do |s|

s.name         = "KBPhotoSelector"
s.version      = "v0.0.1"
s.summary      = "KBPhotoSelector."
s.author       = {"Bofearless" => "Bofearless@gmail.com"}
s.description  = <<-DESC
This is KBPhotoSelector, a photos selected repository.
DESC

s.homepage     = "https://github.com/Bofearless/KBPhotoSelector.git"
s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
s.platform     = :ios, "8.0"
s.source       = { :git => "https://github.com/Bofearless/KBPhotoSelector.git", :tag => s.version.to_s }

s.source_files  = "KBPhotoSelector/KBPhotoSelector/**/*.{h,m}"
s.requires_arc = true

s.framework  = "UIKit","Photos"


end
