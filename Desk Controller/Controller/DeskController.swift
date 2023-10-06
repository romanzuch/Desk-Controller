//
//  DeskController.swift
//  Desk Controller
//
//  Created by Roman Zuchowski on 05.10.23.
//

import Foundation

class DeskController: ObservableObject {
    
    let bluetoohDelegate: CBManagerDelegate
    var settings: Settings
    
    init(for btDelegate: CBManagerDelegate, settings: Settings) {
        self.bluetoohDelegate = btDelegate
        self.settings = settings
    }
    
    func moveTable(_ direction: MovementDirection) {
        self.bluetoohDelegate.desk?.currentDeskState = .unknown
        self.bluetoohDelegate.moveTable(direction: direction)
    }
    
    func moveTable(to state: DeskState) {
        switch state {
        case .low:
            let tableTargetHeight: Float = settings.deskSettingLow
            self.bluetoohDelegate.moveTable(to: tableTargetHeight, with: .low)
        case .mid:
            let tableTargetHeight: Float = settings.deskSettingMid
            self.bluetoohDelegate.moveTable(to: tableTargetHeight, with: .mid)
        case .high:
            let tableTargetHeight: Float = settings.deskSettingHigh
            self.bluetoohDelegate.moveTable(to: tableTargetHeight, with: .high)
        case .unknown:
            return
        }
    }
    
}
