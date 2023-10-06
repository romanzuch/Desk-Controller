//
//  Settings.swift
//  Desk Controller
//
//  Created by Roman Zuchowski on 02.10.23.
//

import Foundation
import CoreBluetooth

class Settings: ObservableObject {
    @Published var savedPeripheral: CBPeripheral?
    @Published var deskSettingLow: Float = 62.0
    @Published var deskSettingMid: Float = 84.0
    @Published var deskSettingHigh: Float = 120.0
}
