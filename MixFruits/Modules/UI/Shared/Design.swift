import SwiftUI

enum Design {
    // Core colors (kept neutral so gradient is soft and pastel)
    static let primary = Color(red: 0.18, green: 0.58, blue: 0.40)
    static let accent = Color(red: 0.96, green: 0.58, blue: 0.50)
    static let mellow = Color(red: 0.99, green: 0.94, blue: 0.88)

    // Backgrounds & surfaces
    static let cardBackground = Color(UIColor.systemBackground)
    static let elevatedCard = Color(.secondarySystemBackground)
    static let chipBackground = Color(.systemGray5)

    // Shadows (soft, airy)
    static let softShadow = Color.black.opacity(0.04)

    // App background: pastel, bed-like tones
    static var backgroundGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color(red: 1.00, green: 0.94, blue: 0.95), location: 0.0), // soft pink
                .init(color: Color(red: 0.95, green: 0.88, blue: 0.98), location: 0.33), // lavender
                .init(color: Color(red: 0.88, green: 0.98, blue: 0.95), location: 0.66), // mint
                .init(color: Color(red: 1.00, green: 0.96, blue: 0.86), location: 1.0)  // warm peach
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var webBackgroundGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color("#7B3FA0"), location: 0.0), 
                .init(color: Color("#A86EDC"), location: 0.33),
                .init(color: Color("#E94A6F"), location: 0.66),
                .init(color: Color("#F78C3F"), location: 1.0)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // Subtle gradients used on cards and chips
    static var cardGradient: LinearGradient {
        LinearGradient(colors: [Color.white.opacity(0.85), Color.white.opacity(0.92)], startPoint: .top, endPoint: .bottom)
    }

    static var chipGradient: LinearGradient {
        LinearGradient(colors: [Color.white.opacity(0.98), Color.white.opacity(0.95)], startPoint: .top, endPoint: .bottom)
    }

    static var headerGradient: LinearGradient {
        LinearGradient(colors: [accent.opacity(0.12), primary.opacity(0.06)], startPoint: .leading, endPoint: .trailing)
    }
}

extension View {
    func elevatedCardStyle(cornerRadius: CGFloat = 12) -> some View {
        self
            .background(RoundedRectangle(cornerRadius: cornerRadius).fill(Design.elevatedCard))
            .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(Color.gray.opacity(0.04), lineWidth: 1))
            .shadow(color: Design.softShadow, radius: 6, x: 0, y: 2)
    }
}
