//
//  ContentView.swift
//  Clockin
//
//  Created by Mack Singh on 8/11/2024.
// 

import SwiftUI
import AVFoundation
import UIKit

struct ContentView: View {
    @State private var isShowingCamera = false

    var body: some View {
        VStack {
            Button(action: {
                self.isShowingCamera = true
            }) {
                Text("Clock In")
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .sheet(isPresented: $isShowingCamera) {
            CameraView()
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraDevice = .front
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                // Save the image with the current date and time
                let smallerImage = image.resized(to: CGSize(width: 800, height: 800))
                let date = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm a,       dd-MM-yyyy"
                let dateString = formatter.string(from: date)
                
                // Draw the date and time on the image
                let imageWithDate = smallerImage.drawText(text: dateString)
                
                // Save the image to the photo library
                UIImageWriteToSavedPhotosAlbum(imageWithDate, nil, nil, nil)
            }
            picker.dismiss(animated: true)
        }
    }
}

extension UIImage {
    func resized(to targetSize: CGSize) -> UIImage {
        let size = self.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        let newSize = widthRatio < heightRatio ? CGSize(width: size.width * widthRatio, height: size.height * widthRatio) : CGSize(width: size.width * heightRatio, height: size.height * heightRatio)

        let rect = CGRect(origin: .zero, size: newSize)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }

    func drawText(text: String) -> UIImage {
        let textColor = UIColor.white
        let textFont = UIFont.systemFont(ofSize: 36)

        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(self.size, false, scale)

        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
        ]

        self.draw(in: CGRect(origin: .zero, size: self.size))

        let rect = CGRect(x: 20, y: self.size.height - 50, width: self.size.width - 40, height: 40)
        text.draw(in: rect, withAttributes: textFontAttributes)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}
