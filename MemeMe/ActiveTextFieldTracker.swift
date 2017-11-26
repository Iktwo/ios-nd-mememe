import Foundation
import UIKit

protocol ActiveTextFieldTracker {
    func updateActiveTextField(textField: UITextField?)
    func getActiveTextField() -> UITextField?
}
