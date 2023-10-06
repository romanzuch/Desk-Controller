//
//  SettingsSlider.swift
//  Desk Controller
//
//  Created by Roman Zuchowski on 05.10.23.
//

import SwiftUI

struct SettingsSlider: View {
    
    var title: String
    @Binding var value: Float
    var range: ClosedRange<Float>
    var cornerRadius: CGFloat
    var material: Material
    
    init(title: String, value: Binding<Float>, range: ClosedRange<Float>, cornerRadius: CGFloat, material: Material) {
        self.title = title
        self._value = value
        self.range = range
        self.cornerRadius = cornerRadius
        self.material = material
    }
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
            HStack {
                Slider(value: $value, in: range)
                Text(String(format: "%.2f", value))
                    .font(.caption)
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(material)
            }
        }
    }
}

#Preview {
    SettingsSlider(title: "Hoch", value: .constant(20.0), range: 0...25.0, cornerRadius: 16, material: .ultraThinMaterial)
}
