//
//  MenuItemsView.swift
//  Desk Controller
//
//  Created by Roman Zuchowski on 02.10.23.
//

import SwiftUI

struct MenuItemsView: View {
    
    @EnvironmentObject private var btDelegate: CBManagerDelegate
    
    var body: some View {
        // MenuItems
        ForEach(self.btDelegate.getMenuItems(), id: \.uuid) { item in
            if item.divider == true {
                Divider()
            }
            Button {
                item.function()
            } label: {
                HStack {
                    Image(systemName: item.icon)
                    Text(item.title)
                }
            }
        }
        
        if btDelegate.tableIsMoving {
            Button {
                btDelegate.moveTable(direction: .stop)
            } label: {
                HStack {
                    Image(systemName: "stop.circle")
                    Text("Stop")
                }
            }

        }
        
        // MARK: - Add a button to enable the user to quit the application
        Divider()
        Button("Beenden") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}

#Preview {
    MenuItemsView()
        .environmentObject(CBManagerDelegate())
}
