//
//  DeskController.swift
//  Desk Controller
//
//  Created by Roman Zuchowski on 05.10.23.
//

import Foundation

class DeskController: ObservableObject {
    
    let btDelegate: CBManagerDelegate
    var settings: Settings
    var disconnectTimer: Timer?
    
    init(for btDelegate: CBManagerDelegate, settings: Settings) {
        self.btDelegate = btDelegate
        self.settings = settings
    }
    
    private func cancelConnectionAfterTimeout() {
        // invalidate timer then start a new one
        if let timer = self.disconnectTimer {
            timer.invalidate()
        }
        disconnectTimer = Timer.scheduledTimer(withTimeInterval: 20.0, repeats: false, block: { timer in
            if let peripheral = self.btDelegate.peripheral {
                self.btDelegate.cbManager.cancelPeripheralConnection(peripheral)
                print("Cancel connection to desk!")
            }
        })
    }
    
    func checkForDeskConnection() {
        if btDelegate.peripheral == nil {
            self.btDelegate.initiateConnectToDesk()
        }
    }
    
    func moveTable(_ direction: MovementDirection) {
        if btDelegate.peripheral == nil {
            self.btDelegate.initiateConnectToDesk { result in
                switch result {
                case .success(let _):
                    self.btDelegate.desk?.currentDeskState = .unknown
                    self.btDelegate.moveTable(direction: direction)
                    self.cancelConnectionAfterTimeout()
                case .failure(let _):
                    return
                }
            }
        } else {
            self.btDelegate.desk?.currentDeskState = .unknown
            self.btDelegate.moveTable(direction: direction)
            self.cancelConnectionAfterTimeout()
        }
    }
    
    func moveTable(to state: DeskState) {
        self.checkForDeskConnection()
        switch state {
        case .low:
            let tableTargetHeight: Float = settings.deskSettingLow
            self.btDelegate.moveTable(to: tableTargetHeight, with: .low)
        case .mid:
            let tableTargetHeight: Float = settings.deskSettingMid
            self.btDelegate.moveTable(to: tableTargetHeight, with: .mid)
        case .high:
            let tableTargetHeight: Float = settings.deskSettingHigh
            self.btDelegate.moveTable(to: tableTargetHeight, with: .high)
        case .unknown:
            return
        }
        self.cancelConnectionAfterTimeout()
    }
    
}
