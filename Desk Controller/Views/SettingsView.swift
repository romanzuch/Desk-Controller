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
    @State private var showSettings: Bool = false
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Einstellungen")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Button {
                    showSettings.toggle()
                } label: {
                    Image(systemName: showSettings == true ? "chevron.up" : "chevron.down")
                }
                .buttonStyle(.plain)
            }
            Spacer()
            if showSettings == true {
                // Set the table height preferences
                VStack(alignment: .leading, spacing: 8) {
                    Text("Voreinstellung Tischhöhe")
                    VStack {
                        Text("STATE_HIGH")
                            .font(.caption)
                            .fontWeight(.bold)
                        HStack {
                            Slider(value: $settings.deskSettingHigh, in: 85...120)
                            Text(String(format: "%.2f", settings.deskSettingHigh))
                                .font(.caption)
                        }
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                        }
                    }
                    VStack {
                        Text("STATE_MID")
                            .font(.caption)
                            .fontWeight(.bold)
                        HStack {
                            Slider(value: $settings.deskSettingMid, in: 65...85)
                            Text(String(format: "%.2f", settings.deskSettingMid))
                                .font(.caption)
                        }
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                        }
                    }
                    VStack {
                        Text("STATE_LOW")
                            .font(.caption)
                            .fontWeight(.bold)
                        HStack {
                            Slider(value: $settings.deskSettingLow, in: 40...65)
                            Text(String(format: "%.2f", settings.deskSettingLow))
                                .font(.caption)
                        }
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                        }
                    }
                }
                // Current table selection
                Text("Aktuelle Auswahl: \(self.btDelegate.peripheral?.name ?? "")")
                // Select a table
//                Picker(selection: $settings.savedPeripheral) {
//                    ForEach(self.btDelegate.peripheralsAdditional, id: \.name) { peripheral in
//                        Text(peripheral.name ?? "")
//                    }
//                } label: {
//                    Text("Tisch auswählen")
//                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(CBManagerDelegate())
        .environmentObject(Settings())
}
