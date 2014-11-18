Pod::Spec.new do |s|
  s.name         = "BRNImagePickerSheet"
  s.version      = "0.0.2"
  s.summary      = "A duplicate of that shiny new custom action sheet seen in iOS8\’s iMessage"
  s.description  = <<-DESC
                   BRNImagePickerSheet is a duplicate of the custom image actionsheet of iMessage in iOS 8.
                   It is easy to use and performant. It even fixes a few bugs that the iMessage's component has.
                   DESC

  s.screenshots  = "https://raw.github.com/larcus94/BRNImagePickerSheet/master/Screenshots/BRNImagePickerSheet-about.png", "https://raw.github.com/larcus94/BRNImagePickerSheet/master/Screenshots/BRNImagePickerSheet-about-selected.png"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "Laurin Brandner" => "mail@laurinbrandner.ch" }
  s.social_media_url   = "http://twitter.com/larcus94"
  s.homepage           = "http://laurinbrandner.ch"

  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/larcus94/BRNImagePickerSheet.git", :tag => s.version.to_s }

  s.source_files  = "BRNImagePickerSheet/*"
  s.framework  = "Photos"
  s.requires_arc = true

end
