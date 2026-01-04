import SwiftUI

struct FirstLoginBanner: View {
    @Binding var isVisible: Bool
    
    var body: some View {
        VStack {
            HStack(spacing: 12) {
                Image(systemName: "star.circle.fill")
                    .font(.title)
                    .foregroundColor(.yellow)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome Back!")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("First login of the day!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        isVisible = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [Color.black, Color(.systemGray)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(radius: 8)
            .padding(.horizontal)
            
            Spacer()
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
