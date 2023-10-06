//
//  SettingsView.swift
//  Desk Controller
//
//  Created by Roman Zuchowski on 05.10.23.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var btDelegate: CBManagerDelegate
    @EnvironmentObject var settings: Settings
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Einstellungen")
                .font(.headline)
                .fontWeight(.bold)
            // Set the table height preferences
            VStack(alignment: .leading, spacing: 8) {
                Text("Voreinstellung Tischhöhe")
                SettingsSlider(title: "Hoch", value: $settings.deskSettingHigh, range: 85.0...120.0, cornerRadius: 16, material: .ultraThinMaterial)
                SettingsSlider(title: "Mittel", value: $settings.deskSettingMid, range: 65.0...85.0, cornerRadius: 16, material: .ultraThinMaterial)
                SettingsSlider(title: "Niedrig", value: $settings.deskSettingLow, range: 40.0...65.0, cornerRadius: 16, material: .ultraThinMaterial)
            }
            // Current table selection
            Text("Aktuelle Auswahl: \(self.btDelegate.peripheral?.name ?? "")")
            // Select a table
            Picker(selection: $settings.savedPeripheral) {
                ForEach(self.btDelegate.peripheralsAdditional, id: \.name) { peripheral in
                    Text(peripheral.name ?? "")
                }
            } label: {
                Text("Tisch auswählen")
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(CBManagerDelegate())
        .environmentObject(Settings())
}
