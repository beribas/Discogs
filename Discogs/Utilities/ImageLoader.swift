import UIKit
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

  return UIImage(cgImage: destinationCGImage.takeRetainedValue())
}
