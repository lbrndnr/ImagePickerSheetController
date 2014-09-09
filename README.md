# BRNImagePickerSheet

## About
BRNImagePickerSheet is a duplicate of that shiny new custom action sheet seen in iOS8's iMessage that Apple didn't make part of UIKit. It's the first project I've written in Swift. It works well but I might have coded something the Objective-C kind of way. Don't hesitate to open an issue/ pullrequest if you spotted something.

Also, I want to mention that I couldn't get it to work with UICollectionView. I originally used it for the previews. However, I couldn't get the animation to work _perfectly_. Whoever manages to make the animation look perfect by using a UICollectionView will get a free round :)

## Usage
BRNImagePickerSheet's API is similar to the one of UIActionSheet so you should get along with it just well.

### Example

```swift
let placeholder = BRNImagePickerSheet.selectedPhotoCountPlaceholder
var sheet = BRNImagePickerSheet()
sheet.addButtonWithTitle("Take Photo Or Video", singularSecondaryTitle: "Add Comment", pluralSecondaryTitle: nil)
sheet.addButtonWithTitle("Photo Library", singularSecondaryTitle: "Send \(placeholder) Photo", pluralSecondaryTitle: "Send \(placeholder) Photos")
sheet.delegate = self
sheet.showInView(self.view)
```

Note that you can use the placeholder to specify where BRNImagePickerSheet should insert the number of selected photos. This allows you to use very custom titles

```swift
func imagePickerSheet(imagePickerSheet: BRNImagePickerSheet, willDismissWithButtonIndex buttonIndex: Int) {
if buttonIndex != imagePickerSheet.cancelButtonIndex {
if imagePickerSheet.showsSecondaryTitles {
let selectedImages = imagePickerSheet.selectedPhotos
// Do something with the selectedImages
}
else {
let controller = UIImagePickerController()
controller.delegate = self
controller.sourceType = (buttonIndex == 2) ? .PhotoLibrary : .Camera
self.presentViewController(controller, animated: true, completion: nil)
}
}
}
```

## Requirements
BRNImagePickerSheet is written in Swift. It therefore runs on iOS 7 and 8.

## License
BRNImagePickerSheet is licensed under the [MIT License](http://opensource.org/licenses/mit-license.php). 