import UIKit
import PhotosUI

class AvatarPickerVC: UIViewController, PHPickerViewControllerDelegate {
    @IBOutlet weak var avatarImageView: UIImageView!
    var completion: ((UIImage?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        avatarImageView.layer.cornerRadius = 75
        avatarImageView.layer.masksToBounds = true
    }
    
    @IBAction func selectPhotoTapped() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @IBAction func useDefaultTapped() {
        if let defaultImage = UIImage(named: "default_token") {
            avatarImageView.image = defaultImage
        }
    }
    
    @IBAction func saveTapped() {
        completion?(avatarImageView.image)
        dismiss(animated: true)
    }
    
    @IBAction func cancelTapped() {
        dismiss(animated: true)
    }
    
    // MARK: - PHPickerViewControllerDelegate
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            guard let self = self, let image = object as? UIImage else { return }
            
            DispatchQueue.main.async {
                self.avatarImageView.image = image
            }
        }
    }
}