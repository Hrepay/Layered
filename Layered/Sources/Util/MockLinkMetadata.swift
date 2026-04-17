import Foundation
import UIKit
import LinkPresentation

/// Mock 모드(스크린샷) 전용 헬퍼. App Store 스크린샷에서 실제 네이버지도 링크 미리보기 대신
/// 번들된 한강 이미지로 깔끔하게 보이도록 LPLinkMetadata를 수동 구성한다.
enum MockLinkMetadata {
    static func hangang(urlString: String, title: String) -> LPLinkMetadata {
        let metadata = LPLinkMetadata()
        metadata.originalURL = URL(string: urlString)
        metadata.url = URL(string: urlString)
        metadata.title = title
        if let image = UIImage(named: "HangangPreview") {
            metadata.imageProvider = NSItemProvider(object: image)
        }
        return metadata
    }
}
