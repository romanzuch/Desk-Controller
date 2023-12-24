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
                Button(action: {
                    self.controller.moveTable(.up)
                }, label: {
                    HStack {
                        Image(systemName: "chevron.up")
                        Text("DIRECTION_UP")
                    }
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.ultraThinMaterial)
                        }
                })
                .buttonStyle(.plain)
                Button(action: {
                    self.controller.moveTable(.down)
                }, label: {
                    HStack {
                        Text("DIRECTION_DOWN")
                        Image(systemName: "chevron.down")
                    }
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.ultraThinMaterial)
                        }
                })
                .buttonStyle(.plain)
            }
            HStack {
                Button(action: {
                    self.controller.moveTable(to: .high)
                }, label: {
                    Text("STATE_HIGH")
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.ultraThinMaterial)
                        }
                })
                .buttonStyle(.plain)
                Button(action: {
                    self.controller.moveTable(to: .mid)
                }, label: {
                    Text("STATE_MID")
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.ultraThinMaterial)
                        }
                })
                .buttonStyle(.plain)
                Button(action: {
                    self.controller.moveTable(to: .low)
                }, label: {
                    Text("STATE_LOW")
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.ultraThinMaterial)
                        }
                })
                .buttonStyle(.plain)
            }
            
            MenuButton(title: "Stop") {
                btDelegate.stopMoving()
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
        .environment(\.locale, .init(identifier: "en"))
}
