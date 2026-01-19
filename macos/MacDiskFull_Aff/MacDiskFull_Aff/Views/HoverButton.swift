
import SwiftUI

struct HoverButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                Text(title)
                    .font(.system(size: 13, weight: .medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                ZStack {
                    if isHovering {
                        color.opacity(0.15)
                    } else {
                        Color.clear
                    }
                }
            )
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(color.opacity(isHovering ? 1.0 : 0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle()) // Crucial for custom styling
        .foregroundColor(color)
        .onHover { hover in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isHovering = hover
            }
        }
        .scaleEffect(isHovering ? 1.02 : 1.0)
    }
}
