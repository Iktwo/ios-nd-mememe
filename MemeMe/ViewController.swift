import UIKit

public func getImageRect(imageView: UIImageView) -> CGRect {
    if imageView.image != nil {
        let widthRatio = imageView.bounds.size.width / (imageView.image?.size.width)!
        let heightRatio = imageView.bounds.size.height / (imageView.image?.size.height)!
        let scale = min(widthRatio, heightRatio)

        let imageWidth = scale * (imageView.image?.size.width)!
        let imageHeight = scale * (imageView.image?.size.height)!

        var imageRect = CGRect(x: imageView.frame.origin.x, y: imageView.frame.origin.y, width: imageWidth, height: imageHeight)

        imageRect.origin.x = imageView.frame.origin.x + ((imageView.frame.width - imageRect.size.width) / 2)
        imageRect.origin.y = imageView.frame.origin.y + ((imageView.frame.height - imageRect.size.height) / 2)

        return imageRect
    } else {
        return CGRect(x: 0, y: 0, width: 0, height: 0)
    }
}

fileprivate extension Selector {
    static let keyboardWillShow = #selector(ViewController.keyboardWillShow(_:))
    static let keyboardWillHide = #selector(ViewController.keyboardWillHide(_:))
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ActiveTextFieldTracker {
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!

    @IBAction func pickImageFromCamera(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .camera
        present(imagePickerController, animated: true, completion: nil)
    }

    @IBAction func handleClick(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true)
    }

    @IBAction func save(_ sender: Any) {
        let activityItems = [generateMemedImage()]
        let avc = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)

        self.present(avc, animated: true, completion: nil)
    }

    func generateMemedImage() -> UIImage {
        // TODO: Hide toolbar and navbar

        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        // TODO: Show toolbar and navbar

        return memedImage
    }

    var textFieldDelegate: TextFieldDelegate?
    var activeTextField: UITextField?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        textFieldDelegate = TextFieldDelegate(activeTextFieldTracker: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let memeTextAttributes: [String: Any] = [
            NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.red,
            NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedStringKey.strokeWidth.rawValue: 2.0]

        topTextField.text = "TOP"
        topTextField.delegate = textFieldDelegate
        topTextField.defaultTextAttributes = memeTextAttributes
        topTextField.autocapitalizationType = .allCharacters
        topTextField.textAlignment = .center
        /// TODO: check why this makes the font transparent
        //        topTextField.backgroundColor = UIColor.clear

        bottomTextField.text = "BOTTOM"
        bottomTextField.delegate = textFieldDelegate
        bottomTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.autocapitalizationType = .allCharacters
        bottomTextField.textAlignment = .center
        /// TODO: check why this makes the font transparent
        //        bottomTextField.borderStyle = .none

        saveButton.isEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)

        subscribeToKeyboardNotifications()
    }

    func updateActiveTextField(textField: UITextField?) {
        activeTextField = textField
    }

    func getActiveTextField() -> UITextField? {
        return activeTextField
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if imageView.image != nil {
            topTextField.isHidden = true
            bottomTextField.isHidden = true

            coordinator.animate(alongsideTransition: nil, completion: {
                _ in

                self.topTextField.isHidden = false
                self.bottomTextField.isHidden = false

                let imageDimensions = getImageRect(imageView: self.imageView)

                let textFieldHeight = self.topTextField.frame.height

                let bottomTextFieldY = imageDimensions.origin.y + imageDimensions.height - textFieldHeight

                self.topTextField.frame = CGRect(x: imageDimensions.origin.x, y: imageDimensions.origin.y, width: imageDimensions.width, height: textFieldHeight)
                self.bottomTextField.frame = CGRect(x: imageDimensions.origin.x, y: bottomTextFieldY, width: imageDimensions.width, height: textFieldHeight)
            })
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .scaleAspectFit
            imageView.image = pickedImage

            let imageDimensions = getImageRect(imageView: imageView)

            let textFieldHeight = topTextField.frame.height

            let bottomTextFieldY = imageDimensions.origin.y + imageDimensions.height - textFieldHeight

            topTextField.frame = CGRect(x: imageDimensions.origin.x, y: imageDimensions.origin.y, width: imageDimensions.width, height: textFieldHeight)
            bottomTextField.frame = CGRect(x: imageDimensions.origin.x, y: bottomTextFieldY, width: imageDimensions.width, height: textFieldHeight)

            saveButton.isEnabled = true
        }

        dismiss(animated: true, completion: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }

    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }

    func getKeyboardStartPosition(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.origin.y
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        let keyboardHeight = getKeyboardHeight(notification)

        if ((getActiveTextField()?.frame.origin.y)! + (getActiveTextField()?.frame.height)! > getKeyboardStartPosition(notification)) {
            view.frame.origin.y = 0 - keyboardHeight
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }

    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: .keyboardWillShow, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: .keyboardWillHide, name: .UIKeyboardWillHide, object: nil)
    }

    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
}
