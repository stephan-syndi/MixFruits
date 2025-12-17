import UIKit
import PhotosUI
import SwiftUI

/// Present PHPicker directly from the top UIKit view controller to avoid nested SwiftUI presentations.
final class NativeImagePicker: NSObject {
    static func present(from completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.main.async {
            guard let top = topViewController() else {
                completion(nil)
                return
            }

            var config = PHPickerConfiguration(photoLibrary: .shared())
            config.filter = .images
            config.selectionLimit = 1
            let picker = PHPickerViewController(configuration: config)
            let delegate = PickerDelegate(completion: completion)
            picker.delegate = delegate

            // Keep delegate alive while presented
            objc_setAssociatedObject(picker, &AssociatedKeys.delegateKey, delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            // Embed in nav; rely on the picker's own controls to dismiss to avoid duplicate buttons
            let nav = UINavigationController(rootViewController: picker)

            top.present(nav, animated: true, completion: nil)
        }
    }

    private class PickerDelegate: NSObject, PHPickerViewControllerDelegate {
        let completion: (UIImage?) -> Void
        init(completion: @escaping (UIImage?) -> Void) {
            self.completion = completion
        }

        @objc func cancel() {
            DispatchQueue.main.async {
                if let top = topViewController() {
                    top.dismiss(animated: true) {
                        self.completion(nil)
                    }
                } else {
                    self.completion(nil)
                }
            }
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            if let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { object, error in
                    DispatchQueue.main.async {
                        if let image = object as? UIImage {
                            if let presenting = picker.presentingViewController {
                                presenting.dismiss(animated: true) {
                                    self.completion(image)
                                }
                            } else {
                                self.completion(image)
                            }
                        } else {
                            if let presenting = picker.presentingViewController {
                                presenting.dismiss(animated: true) {
                                    self.completion(nil)
                                }
                            } else {
                                self.completion(nil)
                            }
                        }
                    }
                }
            } else {
                // No selection or cannot load — just dismiss without calling completion with image
                DispatchQueue.main.async {
                    if let presenting = picker.presentingViewController {
                        presenting.dismiss(animated: true) {
                            self.completion(nil)
                        }
                    } else {
                        self.completion(nil)
                    }
                }
            }
        }
    }

    private struct AssociatedKeys {
        static var delegateKey = "native_picker_delegate".hashValue
    }

    private static func topViewController() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first { $0.activationState == .foregroundActive } as? UIWindowScene
        let windows = windowScene?.windows ?? UIApplication.shared.windows
        let keyWindow = windows.first { $0.isKeyWindow } ?? windows.first
        var top = keyWindow?.rootViewController
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }
}
