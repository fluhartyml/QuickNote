//
//  NoteDetailView.swift
//  QuickNote
//
//  Created by Michael Fluharty on 4/6/26.
//

import SwiftUI
import SwiftData
import PhotosUI
import WidgetKit

struct NoteDetailView: View {
    @Bindable var note: Note
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var showCamera = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Title
                TextField("Title", text: $note.title)
                    .font(.system(size: 24, weight: .bold))
                    .onChange(of: note.title) {
                        note.dateModified = .now
                        WidgetCenter.shared.reloadAllTimelines()
                    }

                // Date Created
                DatePicker(
                    "Date Created",
                    selection: $note.dateCreated,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .font(.system(size: 20))
                .foregroundStyle(.secondary)
                .onChange(of: note.dateCreated) {
                    note.dateModified = .now
                }

                // Photo/Camera buttons
                HStack(spacing: 16) {
                    PhotosPicker(
                        selection: $selectedPhotos,
                        maxSelectionCount: 10,
                        matching: .images
                    ) {
                        Label("Photos", systemImage: "photo.on.rectangle")
                            .font(.system(size: 18, weight: .medium))
                    }

                    Button {
                        showCamera = true
                    } label: {
                        Label("Camera", systemImage: "camera")
                            .font(.system(size: 18, weight: .medium))
                    }
                }
                .onChange(of: selectedPhotos) {
                    Task {
                        for item in selectedPhotos {
                            if let data = try? await item.loadTransferable(type: Data.self) {
                                note.imageData.append(data)
                            }
                        }
                        selectedPhotos = []
                        note.dateModified = .now
                    }
                }

                // Attached images
                if !note.imageData.isEmpty {
                    Text("Attachments (\(note.imageData.count))")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.secondary)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 12) {
                        ForEach(Array(note.imageData.enumerated()), id: \.offset) { index, data in
                            if let uiImage = UIImage(data: data) {
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(minHeight: 120)
                                        .clipped()
                                        .cornerRadius(8)

                                    Button {
                                        note.imageData.remove(at: index)
                                        note.dateModified = .now
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 22))
                                            .foregroundStyle(.white, .red)
                                    }
                                    .padding(4)
                                }
                            }
                        }
                    }
                }

                // Body
                TextEditor(text: $note.body)
                    .font(.system(size: 18))
                    .frame(minHeight: 200)
                    .scrollContentBackground(.hidden)
                    .onChange(of: note.body) {
                        note.dateModified = .now
                        WidgetCenter.shared.reloadAllTimelines()
                    }

                Spacer()

                // Date Modified
                Text("Modified: \(quickNoteDateFormatter.string(from: note.dateModified).uppercased())")
                    .font(.system(size: 18, weight: .light).italic())
                    .foregroundStyle(.tertiary)
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                ShareLink(item: shareText)
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraView { image in
                if let data = image.jpegData(compressionQuality: 0.8) {
                    note.imageData.append(data)
                    note.dateModified = .now
                }
            }
        }
    }

    private var shareText: String {
        var text = note.title
        text += "\n\(quickNoteDateFormatter.string(from: note.dateCreated).uppercased())"
        text += "\n\n\(note.body)"
        if !note.imageData.isEmpty {
            text += "\n\n[\(note.imageData.count) photo(s) attached]"
        }
        text += "\n\nModified: \(quickNoteDateFormatter.string(from: note.dateModified).uppercased())"
        return text
    }
}

// MARK: - Camera View

struct CameraView: UIViewControllerRepresentable {
    var onCapture: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onCapture: onCapture, dismiss: dismiss)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onCapture: (UIImage) -> Void
        let dismiss: DismissAction

        init(onCapture: @escaping (UIImage) -> Void, dismiss: DismissAction) {
            self.onCapture = onCapture
            self.dismiss = dismiss
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                onCapture(image)
            }
            dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss()
        }
    }
}
