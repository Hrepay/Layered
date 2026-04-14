import SwiftUI

struct FullScreenImageItem: Identifiable {
    let id = UUID()
    let url: String
}

struct FullScreenImageView: View {
    let url: String
    let onDismiss: () -> Void

    @State private var scale: CGFloat = 1.0
    @State private var toast: ToastData?
    @State private var loadedImage: UIImage?
    @State private var isSaving = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            CachedAsyncImage(url: URL(string: url))
                .scaledToFit()
                .scaleEffect(scale)
                .gesture(
                    MagnifyGesture()
                        .onChanged { value in
                            scale = value.magnification
                        }
                        .onEnded { _ in
                            withAnimation(.spring(duration: 0.3)) {
                                scale = max(1.0, min(scale, 3.0))
                            }
                        }
                )
                .onTapGesture(count: 2) {
                    withAnimation(.spring(duration: 0.3)) {
                        scale = scale > 1 ? 1 : 2
                    }
                }
        }
        .overlay(alignment: .topTrailing) {
            HStack(spacing: 12) {
                Button {
                    Haptic.light()
                    saveImage()
                } label: {
                    if isSaving {
                        ProgressView()
                            .tint(.white)
                            .frame(width: 36, height: 36)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "arrow.down.to.line")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
                .disabled(isSaving)

                Button {
                    Haptic.light()
                    onDismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }
            .padding(.top, 50)
            .padding(.trailing, 20)
        }
        .toast($toast)
        .task {
            // 캐시에서 이미지 로드
            guard let imageURL = URL(string: url) else { return }
            let request = URLRequest(url: imageURL)
            if let cached = URLCache.shared.cachedResponse(for: request),
               let image = UIImage(data: cached.data) {
                loadedImage = image
            } else if let (data, _) = try? await URLSession.shared.data(for: request),
                      let image = UIImage(data: data) {
                loadedImage = image
            }
        }
    }

    private func saveImage() {
        guard let image = loadedImage else {
            toast = ToastData(type: .error, message: "이미지를 불러올 수 없습니다")
            return
        }
        isSaving = true
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isSaving = false
            toast = ToastData(type: .success, message: "저장되었습니다 (원본보다 화질이 낮을 수 있어요)")
        }
    }
}
