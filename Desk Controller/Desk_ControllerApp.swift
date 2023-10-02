//
//  Desk_ControllerApp.swift
//  Desk Controller
//
//  Created by Roman Zuchowski on 01.10.23.
//

import SwiftUI
import Combine

@main
struct Desk_ControllerApp: App {
    @StateObject private var btDelegate: CBManagerDelegate = CBManagerDelegate()
    
    var body: some Scene {
        // MARK: - Remove the actual app window & dock item, so that there will only be the menu bar item
        // Remove the WindowGroup so that the window doesn't show
        // WindowGroup { ContentView() }
        // Change Info.plist so that Application is agent (UIElement) is set to YES
        // MARK: - MenuBarExtra
        MenuBarExtra {
            MenuItemsView()
                .environmentObject(btDelegate)
        } label: {
            Label("Table Controller", systemImage: btDelegate.controllerState != .inactive ? "table.furniture.fill" : "table.furniture")
        }
    }
}
