import Foundation
import UIKit

class TextFieldDelegate: NSObject, UITextFieldDelegate {
    var activeTextFieldTracker: ActiveTextFieldTracker

    init(activeTextFieldTracker: ActiveTextFieldTracker) {
        self.activeTextFieldTracker = activeTextFieldTracker
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeTextFieldTracker.updateActiveTextField(textField: textField)
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField.text == "TOP" || textField.text == "BOTTOM") {
            textField.text = ""
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextFieldTracker.updateActiveTextField(textField: nil)
    }
}
