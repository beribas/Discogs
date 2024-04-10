#if os(macOS)

// Either put this in a separate file that you only include in your macOS target or wrap the code in #if os(macOS) / #endif

import Cocoa
import SwiftUI

// Step 1: Typealias UIImage to NSImage
typealias UIImage = NSImage

// Step 2: You might want to add these APIs that UIImage has but NSImage doesn't.
extension NSImage {
    var cgImage: CGImage? {
        var proposedRect = CGRect(origin: .zero, size: size)

        return cgImage(forProposedRect: &proposedRect,
                       context: nil,
                       hints: nil)
    }

    convenience init?(named name: String) {
        self.init(named: Name(name))
    }

    convenience init(systemName: String) {
        self.init(systemName: systemName)
    }
}

extension Image {
    init(uiImage: UIImage) {
        self.init(nsImage: uiImage)
    }
}

#elseif os(iOS)
import UIKit
#endif
import Accelerate

actor ImageLoader: ObservableObject {
    enum DownloadState {
        case inProgress(Task<UIImage, Error>)
        case completed(UIImage)
        case failed
    }
    private(set) var cache: [URL: DownloadState] = [:]

    func add(_ image: UIImage, forKey key: URL) {
        cache[key] = .completed(image)
    }

    func image(_ url: URL) async throws -> UIImage {
        if let cached = cache[url] {
            switch cached {
            case .completed(let image):
                return image
            case .inProgress(let task):
                return try await task.value
            case .failed: throw "Download failed"
            }
        }

        let download: Task<UIImage, Error> = Task.detached {
            let data = try await URLSession.shared.data(from: url).0
            return try resize(data, to: CGSize(width: 200, height: 200))
        }
        cache[url] = .inProgress(download)

        do {
            let result = try await download.value
            add(result, forKey: url)
            return result
        } catch {
            cache[url] = .failed
            throw error
        }
    }

    func clear() {
        cache.removeAll()
    }
}

/// Easily throw generic errors with a text description.
extension String: LocalizedError {
    public var errorDescription: String? {
        return self
    }
}

struct ResizeError: Error { }

func resize(_ data: Data, to size: CGSize) throws -> UIImage {
    guard let cgImage = UIImage(data: data)?.cgImage,
          let colorSpace = cgImage.colorSpace else {
        throw ResizeError()
    }

    var format = vImage_CGImageFormat(
        bitsPerComponent: UInt32(cgImage.bitsPerComponent),
        bitsPerPixel: UInt32(cgImage.bitsPerPixel),
        colorSpace: Unmanaged.passRetained(colorSpace),
        bitmapInfo: cgImage.bitmapInfo,
        version: 0,
        decode: nil,
        renderingIntent: cgImage.renderingIntent
    )

    var buffer = vImage_Buffer()
    vImageBuffer_InitWithCGImage(&buffer, &format, nil, cgImage, vImage_Flags(kvImageNoFlags))

    var destinationBuffer = try vImage_Buffer(width: Int(200), height: Int(200), bitsPerPixel: format.bitsPerPixel)

    defer { destinationBuffer.free() }

    _ = withUnsafePointer(to: buffer) { sourcePointer in
        vImageScale_ARGB8888(sourcePointer, &destinationBuffer, nil, vImage_Flags(kvImageNoFlags))
    }

    let destinationCGImage = vImageCreateCGImageFromBuffer(
        &buffer, &format, nil, nil, vImage_Flags(kvImageNoFlags), nil
    )

    guard let destinationCGImage = destinationCGImage else {
        throw ResizeError()
    }

#if os(iOS)
    return UIImage(cgImage: destinationCGImage.takeRetainedValue())
#elseif os(macOS)
    return UIImage(
        cgImage: destinationCGImage.takeRetainedValue(),
        size: CGSize(
            width: destinationCGImage.takeUnretainedValue().width,
            height: destinationCGImage.takeUnretainedValue().height
        )
    )
#endif
}
