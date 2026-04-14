import SwiftUI

enum AppColors {
    // Primary - Peach
    static let primary = Color(hex: "FF9472")
    static let primaryLight = Color(hex: "FFB99A")
    static let primarySubtle = Color(hex: "FFF0E8")

    // Secondary - Olive
    static let secondary = Color(hex: "8B9E6B")
    static let secondarySubtle = Color(hex: "EFF3E8")

    // Info - Sky
    static let info = Color(hex: "6BB5C9")
    static let infoSubtle = Color(hex: "E8F4F8")

    // Warning - Amber
    static let warning = Color(hex: "F5A623")
    static let warningSubtle = Color(hex: "FFF4E0")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        (r, g, b) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        self.init(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255
        )
    }
}
