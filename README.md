# ImagePickerSheet

## About
ImagePickerSheet is a duplicate of that shiny new custom action sheet seen in iOS8's iMessage that Apple didn't make part of UIKit. It's the first project I've written in Swift. It works well but I might have coded something the Objective-C kind of way. Don't hesitate to open an issue or pull request if you spotted something.
And no, ImagePickerSheet does not have the glitches Apple's image picker has :)

![demo](Screenshots/ImagePickerSheet.gif)

[![Twitter: @larcus94](https://img.shields.io/badge/contact-@larcus94-blue.svg?style=flat)](https://twitter.com/larcus94)
[![License](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/larcus94/ImagePickerSheet/blob/master/LICENSE)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## Author
I'm Laurin Brandner, I'm on [Twitter](https://twitter.com/larcus94).

## Usage
ImagePickerSheet's API is similar to the one of UIActionSheet so you should get along with it just well.

### Example

```swift
let sheet = ImagePickerSheet()
sheet.numberOfButtons = 3
sheet.delegate = self
sheet.showInView(view)
```

```swift
func imagePickerSheet(imagePickerSheet: ImagePickerSheet, titleForButtonAtIndex buttonIndex: Int) -> String {
    let photosSelected = (imagePickerSheet.selectedPhotos.count > 0)

    if (buttonIndex == 0) {
        if photosSelected {
            return NSLocalizedString("Add comment", comment: "Add comment")
        }
        else {
            return NSLocalizedString("Take Photo Or Video", comment: "Take Photo Or Video")
        }
    }
    else {
        if photosSelected {
            return NSString.localizedStringWithFormat(NSLocalizedString("ImagePickerSheet.button1.Send %lu Photo", comment: "The secondary title of the image picker sheet to send the photos"), imagePickerSheet.selectedPhotos.count)
        }
        else {
            return NSLocalizedString("Photo Library", comment: "Photo Library")
        }
    }
}

func imagePickerSheet(imagePickerSheet: ImagePickerSheet, willDismissWithButtonIndex buttonIndex: Int) {
    if buttonIndex != imagePickerSheet.cancelButtonIndex {
        if imagePickerSheet.selectedPhotos.count > 0 {
                println(imagePickerSheet.selectedPhotos)
        }
        else {
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = (buttonIndex == 2) ? .PhotoLibrary : .Camera
            presentViewController(controller, animated: true, completion: nil)
        }
    }
}
```
ImagePickerSheet uses a delegate method, similar to UITableView's dataSource, to get the title of a button. In conjunction with [stringsdict](https://developer.apple.com/library/ios/documentation/MacOSX/Conceptual/BPInternational/StringsdictFileFormat/StringsdictFileFormat.html), this allows for easy translation of various plural forms.

## Installation

### CocoaPods
```ruby
pod "ImagePickerSheet", "~> 0.0.8"
```

###Carthage
```objc
github "larcus94/ImagePickerSheet" ~> 0.0.8
```


## Requirements
ImagePickerSheet is written in Swift and links against `Photos.framework`. It therefore requires iOS 8 or later.

## License
ImagePickerSheet is licensed under the [MIT License](http://opensource.org/licenses/mit-license.php).
