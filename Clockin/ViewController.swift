//
//  ViewController.swift
//  Clockin
//
//  Created by Mack Singh on 8/11/2024.
//

import UIKit
import AVFoundation
import Photos

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Request permission to access the photo library
        PHPhotoLibrary.requestAuthorization { status in
            if status != .authorized {
                print("Permission to access photo library was not granted.")
            }
        }
        
        // Set up the image picker
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.cameraDevice = .front
        imagePicker.allowsEditing = false
    }
    
    @IBAction func takePictureButtonTapped(_ sender: UIButton) {
        // Check for camera permissions and present the camera
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                DispatchQueue.main.async {
                    self.present(self.imagePicker, animated: true, completion: nil)
                }
            } else {
                print("Permission to use the camera was not granted.")
            }
        }
    }
    
    // UIImagePickerControllerDelegate method
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let originalImage = info[.originalImage] as? UIImage {
            // Add date and time text to the image
            let dateTimeImage = addDateTimeTextToImage(image: originalImage)
            
            // Save the processed image to the photo gallery
            UIImageWriteToSavedPhotosAlbum(dateTimeImage, nil, nil, nil)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // Function to overlay date and time on the image
    func addDateTimeTextToImage(image: UIImage) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        let dateTimeString = getCurrentDateTimeString()
        
        let newImage = renderer.image { context in
            image.draw(at: CGPoint.zero)
            
            // Draw the date and time string
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 40),
                .foregroundColor: UIColor.red
            ]
            let textSize = dateTimeString.size(withAttributes: attributes)
            let textPoint = CGPoint(x: 10, y: image.size.height - textSize.height - 10)
            dateTimeString.draw(at: textPoint, withAttributes: attributes)
        }
        
        return newImage
    }
    
    // Function to get the current date and time as a string
    func getCurrentDateTimeString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss dd-MM-yyyy"
        return dateFormatter.string(from: Date())
    }
}
