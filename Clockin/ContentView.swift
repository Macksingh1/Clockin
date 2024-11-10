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
    @State private var isShowingPasswordView = false
    @State private var isClockingOut = false

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour < 12 ? "Good Morning!" : "Good Afternoon!"
    }

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text(greeting)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
                Button(action: {
                    self.isShowingCamera = true
                    self.isClockingOut = false
                }) {
                    Text("Clock In")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                
                Button(action: {
                    self.isShowingCamera = true
                    self.isClockingOut = true
                }) {
                    Text("Clock Out")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal)
                Spacer()
            }
            .overlay(
                VStack {
                    Spacer()
                    HStack {
                        Button(action: {
                            self.isShowingPasswordView = true
                        }) {
                            Text("View")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                        }
                        .padding()
                        Spacer()
                    }
                }
            )
            .sheet(isPresented: $isShowingCamera) {
                CameraView(isClockingOut: self.isClockingOut)
            }
            .sheet(isPresented: $isShowingPasswordView) {
                PasswordView()
            }
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    var isClockingOut: Bool

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraDevice = .front
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(self, isClockingOut: isClockingOut)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: CameraView
        var isClockingOut: Bool

        init(_ parent: CameraView, isClockingOut: Bool) {
            self.parent = parent
            self.isClockingOut = isClockingOut
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                // Process the image in the background
                DispatchQueue.global(qos: .userInitiated).async {
                    let smallerImage = image.resized(to: CGSize(width: 800, height: 800))
                    let date = Date()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "EEEE, HH:mm a\ndd-MM-yyyy"
                    let dateString = formatter.string(from: date)
                    
                    // Draw the date and time on the image
                    let text = self.isClockingOut ? "Out" : "IN"
                    let imageWithText = smallerImage.drawText(text: text, dateString: dateString, isClockingOut: self.isClockingOut)
                    
                    // Save the image to the photo library
                    UIImageWriteToSavedPhotosAlbum(imageWithText, nil, nil, nil)
                    
                    // Save the image locally
                    ImageStore.shared.saveImage(image: imageWithText)
                }
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

        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }

        let rect = CGRect(origin: .zero, size: newSize)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }

    func drawText(text: String, dateString: String, isClockingOut: Bool) -> UIImage {
        let textColor = isClockingOut ? UIColor.red : UIColor.green
        let textFont = UIFont(name: "Helvetica Bold", size: 100)!
        let dateFont = UIFont(name: "Helvetica Bold", size: 40)!

        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(self.size, false, scale)

        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
        ] as [NSAttributedString.Key : Any]
        
        let dateFontAttributes = [
            NSAttributedString.Key.font: dateFont,
            NSAttributedString.Key.foregroundColor: UIColor.white,
        ] as [NSAttributedString.Key : Any]

        self.draw(in: CGRect(origin: CGPoint.zero, size: self.size))

        let textRect = CGRect(origin: CGPoint(x: self.size.width / 4, y: self.size.height / 2 - 50), size: self.size)
        text.draw(in: textRect, withAttributes: textFontAttributes)

        let dateRect = CGRect(origin: CGPoint(x: self.size.width / 4, y: self.size.height / 2 - 150), size: self.size)
        dateString.draw(in: dateRect, withAttributes: dateFontAttributes)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}

