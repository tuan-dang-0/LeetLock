import SwiftUI

struct ColorPickerSection: View {
    @Binding var primaryColor: Color
    @Binding var secondaryColor: Color
    let onColorChange: () -> Void
    
    @State private var selectedTab = 0 // 0 = Primary, 1 = Secondary
    
    private let darkThemeColors: [Color] = [
        Color(hex: "00CED1"), // Cyan
        Color(hex: "1E90FF"), // Dodger Blue
        Color(hex: "9370DB"), // Medium Purple
        Color(hex: "FF1493"), // Deep Pink
        Color(hex: "FF4500"), // Orange Red
        Color(hex: "FF8C00"), // Dark Orange
        Color(hex: "FFD700"), // Gold
        Color(hex: "32CD32"), // Lime Green
        Color(hex: "00FA9A"), // Medium Spring Green
        Color(hex: "00B8A3")  // LeetCode Green
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Tab Switcher
            HStack(spacing: 0) {
                Button(action: { selectedTab = 0 }) {
                    Text("Primary")
                        .font(.comfortaa(size: 13, weight: .medium))
                        .foregroundColor(selectedTab == 0 ? .white : .gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(selectedTab == 0 ? Color.darkAccent : Color.clear)
                        .cornerRadius(6)
                }
                
                Button(action: { selectedTab = 1 }) {
                    Text("Secondary")
                        .font(.comfortaa(size: 13, weight: .medium))
                        .foregroundColor(selectedTab == 1 ? .white : .gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(selectedTab == 1 ? Color.darkAccent : Color.clear)
                        .cornerRadius(6)
                }
            }
            .padding(4)
            .background(Color.black.opacity(0.3))
            .cornerRadius(8)
            
            // Color Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 5), spacing: 8) {
                ForEach(darkThemeColors.indices, id: \.self) { index in
                    ColorCircle(
                        color: darkThemeColors[index],
                        isSelected: selectedTab == 0 ? 
                            colorsMatch(primaryColor, darkThemeColors[index]) : 
                            colorsMatch(secondaryColor, darkThemeColors[index]),
                        size: 32,
                        action: {
                            if selectedTab == 0 {
                                primaryColor = darkThemeColors[index]
                            } else {
                                secondaryColor = darkThemeColors[index]
                            }
                            onColorChange()
                        }
                    )
                }
            }
        }
    }
    
    private func colorsMatch(_ color1: Color, _ color2: Color) -> Bool {
        color1.toHex() == color2.toHex()
    }
}

struct ColorCircle: View {
    let color: Color
    let isSelected: Bool
    var size: CGFloat = 44
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: size, height: size)
                
                if isSelected {
                    Circle()
                        .strokeBorder(Color.white, lineWidth: 2)
                        .frame(width: size, height: size)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: size * 0.4, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
