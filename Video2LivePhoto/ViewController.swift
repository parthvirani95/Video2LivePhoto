import UIKit
import UniformTypeIdentifiers
import MobileCoreServices
import SwiftUI

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    override func viewDidLoad() {
         super.viewDidLoad()

        // Create an instance of UIHostingController with ContentView as the root view
        let contentView = UIHostingController(rootView: ContentView())

                // Add the SwiftUI view to the current view controller
        addChild(contentView)
        contentView.view.frame = view.bounds
        contentView.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(contentView.view)
        contentView.didMove(toParent: self)
        
//        let selectFileButton = UIButton(type: .system)
//         selectFileButton.setTitle("Select Video", for: .normal)
//         selectFileButton.addTarget(self, action: #selector(selectFileTapped), for: .touchUpInside)
//         selectFileButton.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
//         selectFileButton.center = view.center
//         view.addSubview(selectFileButton)
     }

     @objc func selectFileTapped() {
         let imagePickerController = UIImagePickerController()
         imagePickerController.delegate = self
         imagePickerController.mediaTypes = ["public.movie"]
         imagePickerController.sourceType = .photoLibrary
         present(imagePickerController, animated: true, completion: nil)
     }

     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
         if let selectedVideoURL = info[.mediaURL] as? URL {
             processVideoFile(at: selectedVideoURL)
         }
         picker.dismiss(animated: true, completion: nil)
     }

     func processVideoFile(at url: URL) {
         // Generate a temporary file path based on the selected file name
         let fileName = url.lastPathComponent
         let tmpPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first! + "/\(fileName)"
         let tmpURL = URL(filePath: tmpPath)
        
         do {
             try FileManager.default.removeItem(at: tmpURL)  // Remove any existing file with the same name
          
         } catch {
             print("Failed to remove file: \(error.localizedDescription)")
         }
         
         do {
              try FileManager.default.copyItem(at: url, to: tmpURL)  // Copy the selected video to the temporary path
             
             // Convert the video to live wallpaper
             LivePhotoUtil.convertVideo(tmpPath) { success, msg in
                 print(msg ?? "")
             }
         } catch {
             print("Failed to copy file: \(error.localizedDescription)")
         }
     }

     func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
         picker.dismiss(animated: true, completion: nil)
     }

    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view.
//        
//        let tmpPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first! + "/output_new.mov"
//        let tmpURL = URL(filePath: tmpPath)
//        try? FileManager.default.removeItem(at: tmpURL)
//        try? FileManager.default.copyItem(at: Bundle.main.url(forResource: "output_new", withExtension: "mov")!, to: tmpURL)
//        
//        LivePhotoUtil.convertVideo(tmpPath) { success, msg in
//            print(msg ?? "")
//        }
//    }


}

