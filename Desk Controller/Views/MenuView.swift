//
//  MenuView.swift
//  Desk Controller
//
//  Created by Roman Zuchowski on 02.10.23.
//

import SwiftUI

struct MenuView: View {
    
    var btDelegate: CBManagerDelegate
    var settings: Settings
    var controller: DeskController
    
    init(btDelegate: CBManagerDelegate, settings: Settings) {
        self.btDelegate = btDelegate
        self.settings = settings
        self.controller = DeskController(for: btDelegate, settings: settings)
    }
    
    var body: some View {
        VStack {
            // MARK: - Active Controller Menu
            HStack {
                MenuButton(title: "Hoch", icon: "chevron.up", side: .left) {
                    self.controller.moveTable(.up)
                }
                MenuButton(title: "Runter", icon: "chevron.down", side: .right) {
                    self.controller.moveTable(.down)
                }
            }
            HStack {
                MenuButton(title: "Hoch") {
                    self.controller.moveTable(to: .high)
                }
                MenuButton(title: "Mittel") {
                    self.controller.moveTable(to: .mid)
                }
                MenuButton(title: "Niedrig") {
                    self.controller.moveTable(to: .low)
                }
            }
            
            if btDelegate.tableIsMoving {
                MenuButton(title: "Stop") {
                    btDelegate.moveTable(direction: .stop)
                }
            }
            
            // MARK: - Add a button to enable the user to quit the application
            Divider()
            SettingsView()
                .environmentObject(btDelegate)
                .environmentObject(settings)

            Button("Beenden") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }.padding()
    }
}

#Preview {
    MenuView(btDelegate: CBManagerDelegate(), settings: Settings())
}
