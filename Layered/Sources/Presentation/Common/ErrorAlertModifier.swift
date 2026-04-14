import SwiftUI

struct ErrorAlertModifier: ViewModifier {
    @Binding var error: AppError?

    func body(content: Content) -> some View {
        content
            .alert("오류", isPresented: .init(
                get: { error != nil },
                set: { if !$0 { error = nil } }
            )) {
                Button("확인", role: .cancel) {}
                if error?.isRetryable == true {
                    Button("재시도") {
                        error?.retryAction?()
                        error = nil
                    }
                }
            } message: {
                Text(error?.message ?? "알 수 없는 오류가 발생했습니다")
            }
    }
}

struct AppError: Equatable {
    let message: String
    var isRetryable: Bool = false
    var retryAction: (() -> Void)?

    static func == (lhs: AppError, rhs: AppError) -> Bool {
        lhs.message == rhs.message
    }
}

extension View {
    func errorAlert(_ error: Binding<AppError?>) -> some View {
        modifier(ErrorAlertModifier(error: error))
    }
}
