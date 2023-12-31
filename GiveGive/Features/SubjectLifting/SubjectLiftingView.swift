//
//  SubjectLiftingView.swift
//  GiveGive
//
//  Created by Joanne Yager on 2023-10-05.
//

import SwiftUI
import VisionKit


@MainActor
final class SubjectLiftingViewModel: ObservableObject {
    
    var user = AuthenticationManager.shared.currentUser
    
    func pixelate(image: UIImage) throws -> UIImage? {
        
        guard let compressedImage = image.compress() else {
            print("error compressing")
            throw URLError(.backgroundSessionWasDisconnected)
        }
        
        guard let pixelatedImage = compressedImage.pixelate() else {
            print("couldn't pixelate")
            throw URLError(.backgroundSessionWasDisconnected)
        }
        return pixelatedImage
    }
    
    func saveImage(item: UIImage?) {
        guard let user else { return }
        
        Task {
            
            guard let data = item, let id = user.id else { return }
            
            let (path, name) = try await StorageManager.shared.saveImage(image: data, userId: id)
            
            print("SUCCESS")
            
            let newToy = Toy()
            
            let url = try await StorageManager.shared.getUrlForImage(path: path)
            
            let toyImage = ToyImage(url: url.absoluteString, path: path, name: name)
            newToy.images.append(toyImage)
            
            DatabaseManager.shared.addToy(toy: newToy)
        }
    }
}

struct SubjectLiftingView: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = SubjectLiftingViewModel()

    @State private var image = UIImage()
    @State private var readyToNavigate: Bool = false
    @State private var photoTaken: Bool = false
    @State private var subjectImage: UIImage?
    @Binding var subjectArray: [UIImage]
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack {
                if !photoTaken {
                    ImagePicker(selectedImage: self.$image, photoTaken: self.$photoTaken)
                    .cornerRadius(15.0)
                } else {
                    ImageLift(image: image, subjectImage: $subjectImage)
                }
            }
            .padding(.horizontal, 8)
            .onChange(of: subjectImage) { oldValue, newValue in

                if let newValue {
                    do {
                        let pixelatedImage = try viewModel.pixelate(image: newValue)
                        viewModel.saveImage(item: pixelatedImage)
                        subjectArray.append(pixelatedImage ?? UIImage())
                    } catch {
                        print("error saving image to db")
                    }
                    
                    dismiss()
                }
            }
            .onAppear {
                subjectArray.removeAll()
            }
        }
    }
}



@MainActor
struct ImageLift: UIViewRepresentable {
        
    var image: UIImage
    let imageView = LiftImageView()
    let analyzer = ImageAnalyzer()
    let interaction = ImageAnalysisInteraction()
    @Binding var subjectImage: UIImage?
    
    func makeUIView(context: Context) -> some UIView {
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.addInteraction(interaction)
        return imageView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        Task {
            if let image = imageView.image {
                // Set configuration to contain all the configurations.
                let configuration = ImageAnalyzer.Configuration([.text, .visualLookUp, .machineReadableCode])
                let analysis = try? await analyzer.analyze(image, configuration: configuration)
                if let analysis = analysis {
                    interaction.analysis = analysis
                    interaction.preferredInteractionTypes = .imageSubject
                    interaction.isSupplementaryInterfaceHidden = true
                }
            }
            let subjectsSet = await interaction.subjects
            
            for subject in subjectsSet {
                let subjectAsSet = Set(arrayLiteral: subject)
                subjectImage = try? await interaction.image(for: subjectAsSet)
            }
        }
    }
}


class LiftImageView: UIImageView {
    // Use intrinsicContentSize to change the default image size so that we can change the size in the SwiftUI View
    override var intrinsicContentSize: CGSize {
        .zero
    }
}


struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType = .camera
    @Binding var selectedImage: UIImage
    @Binding var photoTaken: Bool
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context:  UIViewControllerRepresentableContext<ImagePicker>) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
                parent.photoTaken = true
            }
        }
    }
}
