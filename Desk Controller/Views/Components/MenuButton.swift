//
//  MenuButton.swift
//  Desk Controller
//
//  Created by Roman Zuchowski on 05.10.23.
//

import SwiftUI

struct MenuButton: View {
    
    var title: String
    var action: () -> Void
    var icon: String?
    var side: IconPlacementSide?
    
    init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    init(title: String, icon: String, side: IconPlacementSide, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.side = side
        self.action = action
    }
    
    var body: some View {
        switch side {
        case .left:
            buttonWithIconOnLeft
        case .right:
            buttonWithIconOnRight
        case nil:
            buttonWithoutIcon
        }
    }
    
    var buttonWithoutIcon: some View {
        Button(action: {
            action()
        }, label: {
            Text(title)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.ultraThinMaterial)
                }
        })
        .buttonStyle(.plain)
    }
    
    var buttonWithIconOnLeft: some View {
        Button(action: {
            action()
        }, label: {
            HStack {
                Image(systemName: icon!)
                Text(title)
            }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.ultraThinMaterial)
                }
        })
        .buttonStyle(.plain)
    }
    
    var buttonWithIconOnRight: some View {
        Button(action: {
            action()
        }, label: {
            HStack {
                Text(title)
                Image(systemName: icon!)
            }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.ultraThinMaterial)
                }
        })
        .buttonStyle(.plain)
    }
    
}

#Preview {
    MenuButton(title: "Hoch") {
        // do something
    }
    .environment(\.locale, .init(identifier: "en"))
}
