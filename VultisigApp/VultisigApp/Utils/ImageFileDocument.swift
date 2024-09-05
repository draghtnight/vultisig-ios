//
//  ImageFileDocument.swift
//  VultisigApp
//
//  Created by Amol Kumar on 2024-08-29.
//

import SwiftUI
import UniformTypeIdentifiers

#if os(iOS)
struct ImageFileDocument: FileDocument {
    var image: UIImage
    
    @MainActor
    init(image: Image) {
        let renderer = ImageRenderer(content: image)
        
        // Set the scale to match the device's screen scale for better quality
        renderer.scale = 3
        
        // Render the image to a UIImage
        if let uiImage = renderer.uiImage {
            self.image = uiImage
        } else {
            // Fallback to an empty image if rendering fails
            self.image = UIImage()
        }
    }

    // FileDocument required methods
    static var readableContentTypes: [UTType] { [.png] }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let image = UIImage(data: data) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.image = image
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let pngData = image.pngData() else {
            throw CocoaError(.fileWriteUnknown)
        }
        return FileWrapper(regularFileWithContents: pngData)
    }
}

#elseif os(macOS)
struct ImageFileDocument: FileDocument {
    var image: NSImage
    
    @MainActor
    init(image: Image) {
        let size = NSSize(width: 960, height: 1380)  // Adjust the size according to your needs
        let renderer = ImageRenderer(content: image)
        
        // Set the scale to match the device's screen scale for better quality
        renderer.scale = NSScreen.main?.backingScaleFactor ?? 2.0
        
        // Create an NSImage from the rendered CGImage
        if let cgImage = renderer.cgImage {
            let nsImage = NSImage(cgImage: cgImage, size: size)
            self.image = nsImage
        } else {
            // Fallback to an empty image if rendering fails
            self.image = NSImage(size: size)
        }
    }

    // FileDocument required methods
    static var readableContentTypes: [UTType] { [.png] }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let image = NSImage(data: data) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.image = image
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let data = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: data),
              let pngData = bitmap.representation(using: .png, properties: [:]) else {
            throw CocoaError(.fileWriteUnknown)
        }
        return FileWrapper(regularFileWithContents: pngData)
    }
}
#endif
