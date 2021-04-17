import SwiftUI

extension Color {
    // #FFAB8B
    static let barnEnd: Color = Color(red: 255 / 255, green: 171 / 255, blue: 139 / 255)
    // #E95468
    static let barnStart: Color = Color(red: 233 / 255, green: 84 / 255, blue: 104 / 255)
}

struct GradientColor {
    static let upper = LinearGradient(
        gradient: Gradient(colors: [.barnEnd, Color.barnEnd.opacity(0.01)]),
        startPoint: .bottom,
        endPoint: .top
    )
    static let lower = LinearGradient(
            gradient: Gradient(colors: [.barnStart, Color.barnEnd]),
            startPoint: .bottom,
            endPoint: .top
        )
}
