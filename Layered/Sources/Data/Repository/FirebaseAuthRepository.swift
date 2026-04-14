import Foundation
import FirebaseAuth
import AuthenticationServices
import CryptoKit

final class FirebaseAuthRepository: NSObject, AuthRepositoryProtocol {
    private var currentNonce: String?
    private var signInContinuation: CheckedContinuation<User, Error>?

    func signInWithApple() async throws -> User {
        return try await withCheckedThrowingContinuation { continuation in
            self.signInContinuation = continuation
            let nonce = randomNonceString()
            currentNonce = nonce

            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = sha256(nonce)

            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.performRequests()
        }
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func deleteAccount() async throws {
        guard let firebaseUser = Auth.auth().currentUser else { return }
        try await firebaseUser.delete()
    }

    func getCurrentUser() -> User? {
        guard let firebaseUser = Auth.auth().currentUser else { return nil }
        return User(
            id: firebaseUser.uid,
            name: firebaseUser.displayName ?? "사용자",
            profileImageURL: firebaseUser.photoURL?.absoluteString,
            familyId: nil, // Firestore에서 따로 조회
            createdAt: firebaseUser.metadata.creationDate ?? Date()
        )
    }

    // MARK: - Nonce helpers
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce.")
        }
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(randomBytes.map { charset[Int($0) % charset.count] })
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension FirebaseAuthRepository: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let nonce = currentNonce,
              let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            signInContinuation?.resume(throwing: NSError(domain: "auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Apple 로그인 실패"]))
            signInContinuation = nil
            return
        }

        let credential = OAuthProvider.credential(
            providerID: AuthProviderID.apple,
            idToken: idTokenString,
            rawNonce: nonce
        )

        Task {
            do {
                let result = try await Auth.auth().signIn(with: credential)
                let firebaseUser = result.user

                // 첫 로그인 시 Apple에서 제공하는 이름 저장
                var displayName = firebaseUser.displayName ?? "사용자"
                if let fullName = appleIDCredential.fullName {
                    let name = [fullName.familyName, fullName.givenName]
                        .compactMap { $0 }
                        .joined()
                    if !name.isEmpty {
                        displayName = name
                        let changeRequest = firebaseUser.createProfileChangeRequest()
                        changeRequest.displayName = displayName
                        try? await changeRequest.commitChanges()
                    }
                }

                let user = User(
                    id: firebaseUser.uid,
                    name: displayName,
                    profileImageURL: firebaseUser.photoURL?.absoluteString,
                    familyId: nil,
                    createdAt: firebaseUser.metadata.creationDate ?? Date()
                )
                signInContinuation?.resume(returning: user)
            } catch {
                signInContinuation?.resume(throwing: error)
            }
            signInContinuation = nil
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        signInContinuation?.resume(throwing: error)
        signInContinuation = nil
    }
}
