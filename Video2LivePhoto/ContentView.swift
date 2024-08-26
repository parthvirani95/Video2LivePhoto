import SwiftUI
import Photos

struct ContentView: View {
    @State private var videoURL: URL? = nil
    @State private var isPickerPresented = false
    @State private var livePhotoStatus: String = "No Live Photo created yet"
    @State private var isProcessing = false  // New state variable to manage button state

    var body: some View {
        VStack(spacing: 20) {
            if let videoURL = videoURL {
                Text("Selected Video: \(videoURL.lastPathComponent)")
            } else {
                Text("No Video Selected")
            }

            Button("Select Video") {
                isPickerPresented = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .sheet(isPresented: $isPickerPresented) {
                VideoPicker(videoURL: $videoURL)
            }

            Button("Convert to Live Photo") {
                
                if let videoURL = videoURL {
                    if(!isProcessing) {
                        isProcessing = true
                        processVideoFile(at: videoURL)
                    }
                } else {
                    isProcessing = false  // Disable the button when processing starts
                    livePhotoStatus = "Please select a video first."
                }
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)

            Text(livePhotoStatus)
                .padding()
        }
        .padding()
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
             isProcessing = true  // Disable the button when processing starts
                              
            // Convert the video to live wallpaper
            LivePhotoUtil.convertVideo(tmpPath) { success, msg in
                if(success){
                    isProcessing = false  // Disable the button when processing starts
                    livePhotoStatus = "Live Photo created and saved successfully!"
                }else{
                    isProcessing = false  // Disable the button when processing starts
                    livePhotoStatus = "Error: \(String(describing: msg))"
                }
                isProcessing = false  // Disable the button when processing starts
            }
        } catch {
            isProcessing = false  // Disable the button when processing starts
            print("Failed to copy file: \(error.localizedDescription)")
        }
    }
}

struct VideoPicker: UIViewControllerRepresentable {
    @Binding var videoURL: URL?

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: VideoPicker

        init(parent: VideoPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let url = info[.mediaURL] as? URL {
                parent.videoURL = url
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.mediaTypes = ["public.movie"]  // Restrict to videos only
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
