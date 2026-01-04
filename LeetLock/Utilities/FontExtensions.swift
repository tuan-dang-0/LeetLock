import SwiftUI

extension Font {
    // MARK: - Comfortaa Font Family

    static func comfortaa(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let fontName: String
        switch weight {
        case .ultraLight, .thin, .light:
            fontName = "Comfortaa-Light"
        case .regular, .medium:
            fontName = "Comfortaa-Regular"
        case .semibold, .bold, .heavy, .black:
            fontName = "Comfortaa-Bold"
        default:
            fontName = "Comfortaa-Regular"
        }
        return .custom(fontName, size: size)
    }
    
    // MARK: - Poppins Font Family
    
    static func poppins(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let fontName: String
        switch weight {
        case .ultraLight:
            fontName = "Poppins-Thin"
        case .thin:
            fontName = "Poppins-ExtraLight"
        case .light:
            fontName = "Poppins-Light"
        case .regular:
            fontName = "Poppins-Regular"
        case .medium:
            fontName = "Poppins-Medium"
        case .semibold:
            fontName = "Poppins-SemiBold"
        case .bold:
            fontName = "Poppins-Bold"
        case .heavy:
            fontName = "Poppins-ExtraBold"
        case .black:
            fontName = "Poppins-Black"
        default:
            fontName = "Poppins-Regular"
        }
        return .custom(fontName, size: size)
    }
}
