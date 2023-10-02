//
//  MenuItem.swift
//  Desk Controller
//
//  Created by Roman Zuchowski on 01.10.23.
//

import Foundation

struct MenuItem {
    let uuid: UUID = UUID()
    var title: String
    var icon: String
    var function: () -> Void
    var divider: Bool?
}
