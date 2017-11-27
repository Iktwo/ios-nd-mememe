import UIKit

public func getImageRect(imageView: UIImageView) -> CGRect {
    if imageView.image != nil {
        let widthRatio = imageView.bounds.size.width / (imageView.image?.size.width)!
        let heightRatio = imageView.bounds.size.height / (imageView.image?.size.height)!
        let scale = min(widthRatio, heightRatio)

        let imageWidth = round(scale * (imageView.image?.size.width)!)
        let imageHeight = round(scale * (imageView.image?.size.height)!)

        var imageRect = CGRect(x: imageView.frame.origin.x, y: imageView.frame.origin.y, width: imageWidth, height: imageHeight)

        imageRect.origin.x = round(imageView.frame.origin.x + ((imageView.frame.width - imageRect.size.width) / 2))
        imageRect.origin.y = round(imageView.frame.origin.y + ((imageView.frame.height - imageRect.size.height) / 2))

        return imageRect
    } else {
        return CGRect(x: 0, y: 0, width: 0, height: 0)
    }
}

public func createImagePickerWith(sourceType: UIImagePickerControllerSourceType, delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate) -> UIImagePickerController {
    let imagePickerController = UIImagePickerController()
    imagePickerController.delegate = delegate
    imagePickerController.sourceType = sourceType
    return imagePickerController
}
