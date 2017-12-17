import UIKit

fileprivate extension Selector {
    static let keyboardWillShow = #selector(GeneratorViewController.keyboardWillShow(_:))
    static let keyboardWillHide = #selector(GeneratorViewController.keyboardWillHide(_:))
}

class GeneratorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ActiveTextFieldTracker {
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!

    var meme: Meme?
    var textFieldDelegate: TextFieldDelegate?
    var activeTextField: UITextField?

    @IBAction func pickImageFromCamera(_ sender: Any) {
        present(createImagePickerWith(sourceType: .camera, delegate: self), animated: true, completion: nil)
    }

    @IBAction func handleClick(_ sender: Any) {
        present(createImagePickerWith(sourceType: .photoLibrary, delegate: self), animated: true)
    }

    @IBAction func didPressShare(_ sender: Any) {
        meme = Meme(topText: topTextField.text ?? "", bottomText: bottomTextField.text ?? "", originalImage: imageView.image!, modifiedImage: generateMemedImage())

        let activityItems = [meme?.modifiedImage]
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)

        activityViewController.completionWithItemsHandler = { activity, success, items, error in
            if success {
                self.save(meme: self.meme!)
            }
        }

        self.present(activityViewController, animated: true, completion: nil)
    }

    @IBAction func cancel(_ sender: Any) {
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        imageView.image = nil
        cancelButton.isEnabled = false
        shareButton.isEnabled = false
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        textFieldDelegate = TextFieldDelegate(activeTextFieldTracker: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        cancelButton.isEnabled = false

        let memeTextAttributes: [String: Any] = [
            NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
            NSAttributedStringKey.backgroundColor.rawValue: UIColor.clear,
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
            NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedStringKey.strokeWidth.rawValue: -5.0]

        configure(textField: topTextField, withDelegate: textFieldDelegate!, withText: "TOP", andAttributes: memeTextAttributes)
        configure(textField: bottomTextField, withDelegate: textFieldDelegate!, withText: "BOTTOM", andAttributes: memeTextAttributes)

        shareButton.isEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)

        subscribeToKeyboardNotifications()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {

        topTextField.isHidden = true
        bottomTextField.isHidden = true

        coordinator.animate(alongsideTransition: nil, completion: {
            _ in
            self.positionTextFields()
        })
    }

    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }

    func save(meme: Meme) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.memes.append(meme)
        
        UIImageWriteToSavedPhotosAlbum(meme.modifiedImage, nil, nil, nil)
    }


    func generateMemedImage() -> UIImage {
        // TODO: Hide toolbar and navbar

        UIGraphicsBeginImageContext(view.frame.size)
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        // TODO: Show toolbar and navbar

        return memedImage
    }

    func configure(textField: UITextField, withDelegate delegate: UITextFieldDelegate, withText text: String, andAttributes attributes: [String : Any]) {
        textField.text = text
        textField.delegate = delegate
        textField.defaultTextAttributes = attributes
        textField.autocapitalizationType = .allCharacters
        textField.textAlignment = .center
        textField.borderStyle = .none
    }

    // Keep track of the current active text field
    func updateActiveTextField(textField: UITextField?) {
        activeTextField = textField
    }

    func getActiveTextField() -> UITextField? {
        return activeTextField
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func positionTextFields() {
        let textFieldHeight = topTextField.frame.height

        topTextField.isHidden = false
        bottomTextField.isHidden = false

        if imageView.image == nil {
            let navigationBarHeight: CGFloat = self.navigationController!.navigationBar.frame.height

            topTextField.frame = CGRect(x: 0, y: navigationBarHeight + 10, width: (self.view.frame.width), height: textFieldHeight)
            bottomTextField.frame = CGRect(x: 0, y: topTextField.frame.origin.y + 10 + topTextField.frame.height, width: (self.view.frame.width), height: textFieldHeight)
        } else {
            let imageDimensions = getImageRect(imageView: self.imageView)

            let bottomTextFieldY = imageDimensions.origin.y + imageDimensions.height - textFieldHeight

            topTextField.frame = CGRect(x: imageDimensions.origin.x, y: imageDimensions.origin.y, width: imageDimensions.width, height: textFieldHeight)
            bottomTextField.frame = CGRect(x: imageDimensions.origin.x, y: bottomTextFieldY, width: imageDimensions.width, height: textFieldHeight)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            cancelButton.isEnabled = true

            imageView.contentMode = .scaleAspectFit
            imageView.image = pickedImage

            positionTextFields()

            shareButton.isEnabled = true
        }

        dismiss(animated: true, completion: nil)
    }

    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }

    func getKeyboardStartPosition(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.origin.y
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        let keyboardHeight = getKeyboardHeight(notification)

        if getActiveTextField() != nil {
            let activeTextFieldFrame = (getActiveTextField()?.frame)!

            if (activeTextFieldFrame.origin.y + activeTextFieldFrame.height > getKeyboardStartPosition(notification)) {
                view.frame.origin.y = 0 - keyboardHeight
            }
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
