import SwiftUI

struct CachedAsyncImage: View {
    let url: URL?
    var size: CGSize? = nil

    @State private var image: UIImage?
    @State private var isLoading = false

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else if isLoading {
                ProgressView()
            } else {
                Color(.systemGray5)
            }
        }
        .task(id: url) {
            await loadImage()
        }
    }

    private func loadImage() async {
        guard let url, image == nil else { return }

        // 캐시 확인
        let request = URLRequest(url: url)
        if let cached = URLCache.shared.cachedResponse(for: request),
           let uiImage = UIImage(data: cached.data) {
            image = uiImage
            return
        }

        // 네트워크 다운로드
        isLoading = true
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let uiImage = UIImage(data: data) {
                // 캐시 저장
                let cachedResponse = CachedURLResponse(response: response, data: data)
                URLCache.shared.storeCachedResponse(cachedResponse, for: request)
                image = uiImage
            }
        } catch {}
        isLoading = false
    }
}
