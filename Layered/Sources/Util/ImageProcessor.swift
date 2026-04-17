import UIKit

/// 이미지 리사이즈 + JPEG 압축 유틸. Firebase 등 외부 의존성 없음.
enum ImageProcessor {
    static func resizeAndCompress(
        _ image: UIImage,
        maxSize: CGFloat = 1080,
        quality: CGFloat = 0.8
    ) -> Data? {
        let size = image.size
        var newSize = size
        if size.width > maxSize || size.height > maxSize {
            let ratio = min(maxSize / size.width, maxSize / size.height)
            newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        }

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }

        return resized.jpegData(compressionQuality: quality)
    }
}
