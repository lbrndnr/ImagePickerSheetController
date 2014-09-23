Pod::Spec.new do |s|
    s.name      = 'BRNImagePickerSheet'
    s.version   = '0.0.1'
    s.summary   = 'A duplicate of that shiny new custom action sheet seen in iOS8\’s iMessage'
    s.screenshots  = 'https://raw.github.com/larcus94/BRNImagePickerSheet/master/Screenshots/BRNImagePickerSheet-about.png', 'https://raw.github.com/larcus94/BRNImagePickerSheet/master/Screenshots/BRNImagePickerSheet-about-selected.png'
    s.author = {"Laurin Brandner" => "mail@laurinbrandner.ch"}
    s.social_media_url = 'https://twitter.com/larcus94'
    s.platform = :ios, '7.0'
    s.requires_arc = true
    s.homepage = 'http://laurinbrandner.ch'
    s.license = { :type => "MIT", :file => "LICENSE" }
    s.source = {
        :git => 'https://github.com/larcus94/BRNImagePickerSheet.git',
        :tag => s.version.to_s
    }
    s.source_files = 'BRNImagePickerSheet/BRNImagePickerSheet/*'
    s.framework = 'AssetsLibrary'
end