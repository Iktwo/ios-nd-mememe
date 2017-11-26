import Foundation
import UIKit

struct Meme {
    var topText: String
    var bottomText: String
    var originalImage: UIImage
    var modifiedImage: UIImage

    init(topText: String, bottomText: String, originalImage: UIImage, modifiedImage: UIImage) {
        self.topText = topText
        self.bottomText = bottomText
        self.originalImage = originalImage
        self.modifiedImage = modifiedImage
    }
}
