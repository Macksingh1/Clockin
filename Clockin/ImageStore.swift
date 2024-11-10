import Foundation
import UIKit

class ImageStore: ObservableObject {
    static let shared = ImageStore()
    @Published var images: [UIImage] = []

    private init() {}

    func saveImage(image: UIImage) {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let timestamp = Date().timeIntervalSince1970
        let fileURL = documentsURL.appendingPathComponent("\(timestamp).jpg")

        if let data = image.jpegData(compressionQuality: 1.0) {
            try? data.write(to: fileURL)
        }

        loadImages()
    }

    func loadImages() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let directoryContents = try? fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: [.creationDateKey])

        let sortedContents = directoryContents?.sorted(by: { (url1, url2) -> Bool in
            let date1 = (try? url1.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
            let date2 = (try? url2.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
            return date1 > date2
        })

        images = sortedContents?.compactMap { url in
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                return image
            }
            return nil
        } ?? []
    }

    func deleteImage(at index: Int) {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let directoryContents = try? fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)

        if let sortedContents = directoryContents?.sorted(by: { (url1, url2) -> Bool in
            let date1 = (try? url1.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
            let date2 = (try? url2.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
            return date1 > date2
        }) {
            let fileURL = sortedContents[index]
            try? fileManager.removeItem(at: fileURL)
            loadImages()
        }
    }

    func deleteAllImages() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let directoryContents = try? fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)

        directoryContents?.forEach { url in
            try? fileManager.removeItem(at: url)
        }

        loadImages()
    }
}