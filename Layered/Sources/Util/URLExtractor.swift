import Foundation

/// 임의 텍스트에서 URL 추출 (NSDataDetector 기반).
/// 네이버지도/카카오맵에서 공유한 텍스트("[네이버지도]\n장소명\n주소\nhttps://naver.me/...")처럼
/// 여러 줄에 URL이 섞여 있어도 첫 번째 URL을 뽑아낸다.
enum URLExtractor {
    private static let detector: NSDataDetector? = {
        try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    }()

    /// 텍스트에서 첫 번째 URL을 추출. scheme이 없으면 https:// 자동 보정.
    static func firstURL(in text: String) -> URL? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let range = NSRange(trimmed.startIndex..., in: trimmed)
        if let match = detector?.firstMatch(in: trimmed, options: [], range: range),
           let url = match.url {
            return url
        }

        // 단일 토큰이지만 scheme이 없는 경우 (예: "naver.me/abc")
        if !trimmed.contains(" "), !trimmed.contains("\n") {
            let normalized = trimmed.hasPrefix("http://") || trimmed.hasPrefix("https://")
                ? trimmed
                : "https://\(trimmed)"
            if let url = URL(string: normalized), url.host != nil {
                return url
            }
        }

        return nil
    }
}
