//
//  BluetoothSearchDelegate.swift
//  Desk Controller
//
//  Created by Roman Zuchowski on 01.10.23.
//

import SwiftUI
import IOBluetooth

class BluetoothSearchDelegate : NSObject, ObservableObject, IOBluetoothDeviceInquiryDelegate {
    
    @Published var devices: [IOBluetoothDevice] = []
    
    func deviceInquiryDeviceFound(_ sender: IOBluetoothDeviceInquiry, device: IOBluetoothDevice) {
        print("Found Device \(device.name ?? "nil")")
        DispatchQueue.main.async {
            self.devices.append(device)
            print("Added device to \(self.devices)")
        }
    }
    
    func deviceInquiryStarted(_ sender: IOBluetoothDeviceInquiry) {
        print("started")
    }
    
    func deviceInquiryComplete(_ sender: IOBluetoothDeviceInquiry, error: IOReturn, aborted: Bool) {
        print("completed")
    }
    
}
