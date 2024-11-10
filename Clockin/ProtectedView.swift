import SwiftUI

struct ProtectedView: View {
    @ObservedObject var imageStore = ImageStore.shared
    @State private var showDeleteConfirmation = false
    @State private var showDeleteAllConfirmation = false
    @State private var indexToDelete: Int?
    @State private var selectedImage: UIImage?
    @State private var isImageViewerPresented = false

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(imageStore.images.indices, id: \.self) { index in
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: self.imageStore.images[index])
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .onTapGesture {
                                    self.selectedImage = self.imageStore.images[index]
                                    self.isImageViewerPresented = true
                                }
                            Button(action: {
                                self.indexToDelete = index
                                self.showDeleteConfirmation = true
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                    .padding(5)
                                    .background(Color.white)
                                    .clipShape(Circle())
                            }
                        }
                    }
                }
                .padding()
            }
            Button(action: {
                self.showDeleteAllConfirmation = true
            }) {
                Text("Delete All")
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .sheet(isPresented: $isImageViewerPresented) {
            if let selectedImage = selectedImage {
                ImageViewer(image: selectedImage)
            }
        }
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Delete Image"),
                message: Text("Are you sure you want to delete this image?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let index = self.indexToDelete {
                        self.imageStore.deleteImage(at: index)
                        self.indexToDelete = nil
                    }
                },
                secondaryButton: .cancel() {
                    self.indexToDelete = nil
                }
            )
        }
        .alert(isPresented: $showDeleteAllConfirmation) {
            Alert(
                title: Text("Delete All Images"),
                message: Text("Are you sure you want to delete all images?"),
                primaryButton: .destructive(Text("Delete All")) {
                    self.imageStore.deleteAllImages()
                },
                secondaryButton: .cancel()
            )
        }
        .onAppear {
            self.imageStore.loadImages()
        }
    }
}

struct ImageViewer: View {
    var image: UIImage

    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .padding()
            Button(action: {
                // Dismiss the sheet
                UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
            }) {
                Text("Close")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
}
