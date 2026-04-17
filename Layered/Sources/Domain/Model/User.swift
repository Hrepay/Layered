import Foundation

struct User: Identifiable, Codable {
    let id: String
    var name: String
    var profileImageURL: String?
    var familyId: String?
    let createdAt: Date
    var agreedTermsAt: Date?
    var agreedTermsVersion: String?
    var marketingConsent: Bool?
}
