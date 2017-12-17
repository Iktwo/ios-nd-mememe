import UIKit

class MemeDetailsViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        if (image != nil) {
            imageView.image = image
        }
    }
}
