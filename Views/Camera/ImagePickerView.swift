import SwiftUI
import UIKit

struct ImagePickerView: View {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss
    @State private var useCamera = true
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    
    var body: some View {
        Group {
            if useCamera {
                CameraView(capturedImage: $image)
            } else {
                StandardImagePicker(image: $image, sourceType: sourceType)
            }
        }
        .overlay(
            VStack {
                HStack {
                    Spacer()
                    
                    Button {
                        useCamera.toggle()
                        if !useCamera {
                            sourceType = .photoLibrary
                        }
                    } label: {
                        Image(systemName: useCamera ? "photo" : "camera")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .padding([.top, .trailing], 16)
                }
                Spacer()
            }
        )
    }
}

struct StandardImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss
    var sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: StandardImagePicker
        
        init(_ parent: StandardImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let selectedImage = info[.originalImage] as? UIImage {
                let processedImage = processImageForML(selectedImage)
                parent.image = processedImage
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
        
        private func processImageForML(_ image: UIImage) -> UIImage {
            let maxDimension: CGFloat = 1200
            let size = image.size
            
            if size.width <= maxDimension && size.height <= maxDimension {
                return image
            }
            
            var newWidth: CGFloat
            var newHeight: CGFloat
            
            if size.width > size.height {
                newWidth = maxDimension
                newHeight = size.height * maxDimension / size.width
            } else {
                newHeight = maxDimension
                newWidth = size.width * maxDimension / size.height
            }
            
            let targetSize = CGSize(width: newWidth, height: newHeight)
            
            UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
            image.draw(in: CGRect(origin: .zero, size: targetSize))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return resizedImage ?? image
        }
    }
}
