import SwiftUI
import SwiftData
import Lottie

struct LoadingView: View {
    @Query private var appThemeArray: [AppTheme]
    @State private var isAnimating = false
    
    private var appTheme: AppTheme? {
        appThemeArray.first
    }
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Color.black,
                    (appTheme?.primaryColor ?? Color(hex: "00CED1")).opacity(0.15),
                    (appTheme?.secondaryColor ?? Color(hex: "FF8C00")).opacity(0.1),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                    .opacity(isAnimating ? 1.0 : 0.5)
                
                // Loading animation
                LottieView(
                    animationName: "loading circle",
                    loopMode: .loop,
                    animationSpeed: 1.0
                )
                .frame(width: 120, height: 120)
                
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    LoadingView()
        .modelContainer(DataStore.createModelContainer())
}
