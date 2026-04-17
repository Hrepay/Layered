import Foundation

extension AppError {
    /// Error를 사용자 친화적인 한글 메시지를 가진 AppError로 변환
    static func from(_ error: Error, retry: (() -> Void)? = nil) -> AppError {
        let message = Self.friendlyMessage(for: error)
        return AppError(
            message: message,
            isRetryable: retry != nil,
            retryAction: retry
        )
    }

    /// Error를 사용자에게 보여줄 한글 메시지로 변환
    /// 공통 케이스(네트워크/권한/찾기 실패)만 매핑하고, 나머지는 친절한 기본 메시지
    static func friendlyMessage(for error: Error) -> String {
        let nsError = error as NSError

        // 1. 네트워크 관련 (URLError)
        if nsError.domain == NSURLErrorDomain {
            switch nsError.code {
            case NSURLErrorNotConnectedToInternet,
                 NSURLErrorNetworkConnectionLost,
                 NSURLErrorCannotConnectToHost:
                return "인터넷 연결을 확인해주세요."
            case NSURLErrorTimedOut:
                return "요청 시간이 초과되었어요. 다시 시도해주세요."
            case NSURLErrorCannotFindHost,
                 NSURLErrorDNSLookupFailed:
                return "서버에 연결할 수 없어요. 잠시 후 다시 시도해주세요."
            default:
                return "네트워크 오류가 발생했어요."
            }
        }

        // 2. Firestore 에러 (FIRFirestoreErrorDomain)
        if nsError.domain == "FIRFirestoreErrorDomain" {
            switch nsError.code {
            case 7:  // permissionDenied
                return "접근 권한이 없어요."
            case 5:  // notFound
                return "데이터를 찾을 수 없어요."
            case 8:  // resourceExhausted
                return "요청이 너무 많아요. 잠시 후 다시 시도해주세요."
            case 14: // unavailable
                return "서비스에 일시적으로 연결할 수 없어요."
            default:
                break
            }
        }

        // 3. Firebase Auth 에러 (FIRAuthErrorDomain)
        if nsError.domain == "FIRAuthErrorDomain" {
            switch nsError.code {
            case 17020: // networkError
                return "인터넷 연결을 확인해주세요."
            case 17014: // requiresRecentLogin
                return "보안을 위해 다시 로그인해주세요."
            case 17011: // userNotFound
                return "계정을 찾을 수 없어요."
            default:
                break
            }
        }

        // 4. 앱 내부 에러 (domain = "family" 등 커스텀)
        if let localizedDescription = (error as NSError).userInfo[NSLocalizedDescriptionKey] as? String,
           !localizedDescription.isEmpty,
           !localizedDescription.contains("The operation couldn") {
            return localizedDescription
        }

        // 5. 기본 폴백
        return "일시적인 문제가 발생했어요. 잠시 후 다시 시도해주세요."
    }
}
