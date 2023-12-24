//
//  SettingsViewModel.swift
//  Desk Controller
//
//  Created by Roman Zuchowski on 24.12.23.
//

import Foundation
import CoreBluetooth

class SettingsViewModel: ObservableObject {
    func getPeripheralName(for peripheral: CBPeripheral) -> String {
        let linakPeripheral: LinakPeripheral = LinakPeripheral(peripheral: peripheral)
        if let peripheralName = linakPeripheral.peripheral.name {
            return peripheralName
        } else {
            return ""
        }
    }
}
