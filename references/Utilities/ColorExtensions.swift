import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    func toHex() -> String {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return "#FFFFFF"
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
    
    static let pastelColors: [Color] = [
        Color(hex: "#FFE5E5"),
        Color(hex: "#FFE5CC"),
        Color(hex: "#FFF4CC"),
        Color(hex: "#E5FFCC"),
        Color(hex: "#CCF5FF"),
        Color(hex: "#E5CCFF"),
        Color(hex: "#FFCCF5"),
        Color(hex: "#FFD9CC"),
        Color(hex: "#D9FFE5"),
        Color(hex: "#E5D9FF")
    ]
    
    static let darkModeColors: [Color] = [
        Color(hex: "#2D5F8D"),  // Deep Blue
        Color(hex: "#5D4E7C"),  // Purple
        Color(hex: "#2D6B4F"),  // Forest Green
        Color(hex: "#8B5A3C"),  // Brown
        Color(hex: "#6B4E71"),  // Plum
        Color(hex: "#3D5A6B"),  // Slate Blue
        Color(hex: "#7C5C4E"),  // Terracotta
        Color(hex: "#4E6B5D")   // Teal
    ]
    
    var luminance: Double {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return 0
        }
        let r = components[0]
        let g = components[1]
        let b = components[2]
        // Calculate relative luminance using sRGB coefficients
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }
    
    var contrastingTextColor: Color {
        // Use white text for dark backgrounds, black for light backgrounds
        return luminance > 0.5 ? .black : .white
    }
    
    // Dynamic accent color from UserDefaults (to avoid SwiftData initialization issues)
    static var appAccent: Color {
        let hexString = UserDefaults.standard.string(forKey: "appAccentColorHex") ?? "007AFF"
        return Color(hex: hexString)
    }
}
