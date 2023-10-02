//
//  MenuItemsView.swift
//  Desk Controller
//
//  Created by Roman Zuchowski on 02.10.23.
//

import SwiftUI

struct MenuItemsView: View {
    
    @EnvironmentObject private var controller: DeskController
    
    var body: some View {
        // MenuItems
        ForEach(controller.getMenuItems(), id: \.title) { menuItem in
            Button(action: {
                menuItem.function()
            }, label: {
                HStack {
                    Image(systemName: menuItem.icon)
                    Text(menuItem.title)
                }
            })
        }
        if controller.controllerState == .searching {
            Divider()
            Text("<-- Geräte -->")
            // Devices
            ForEach(controller.devices, id: \.self) { device in
                Menu(device.nameOrAddress) {
                    Button("Verbinden") {}
                }
            }
        }
        
        // MARK: - Add a button to enable the user to quit the application
        Divider()
        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}

#Preview {
    MenuItemsView()
        .environmentObject(DeskController())
}
