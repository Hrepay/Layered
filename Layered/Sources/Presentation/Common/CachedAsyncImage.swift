import SwiftUI

struct CachedAsyncImage: View {
    let url: URL?
    var size: CGSize? = nil

    @State private var image: UIImage?
    @State private var isLoading = false
    @State private var didFail = false

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else if isLoading {
                ProgressView()
                    .tint(AppColors.primary)
            } else if didFail {
                ZStack {
                    Color(.systemGray6)
                    Image(systemName: "photo.badge.exclamationmark")
                        .font(.title3)
                        .foregroundStyle(.tertiary)
                }
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
        didFail = false

        // 캐시 확인
        let request = URLRequest(url: url)
        if let cached = URLCache.shared.cachedResponse(for: request),
           let uiImage = UIImage(data: cached.data) {
            image = uiImage
            return
        }

        // 네트워크 다운로드
        isLoading = true
        defer { isLoading = false }
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let uiImage = UIImage(data: data) {
                let cachedResponse = CachedURLResponse(response: response, data: data)
                URLCache.shared.storeCachedResponse(cachedResponse, for: request)
                image = uiImage
            } else {
                didFail = true
            }
        } catch {
            didFail = true
        }
    }
}
