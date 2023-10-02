//
//  DeskController.swift
//  Desk Controller
//
//  Created by Roman Zuchowski on 01.10.23.
//

import Foundation
import IOBluetooth
import SwiftUI
import Combine

class DeskController: ObservableObject {
    @ObservedObject var delegate: BluetoothSearchDelegate
    let inquiry: IOBluetoothDeviceInquiry
    private var timer: Timer?
    
    //MARK: - Published properties
    @Published var controllerState: ControllerState = .inactive
    @Published var devices: [IOBluetoothDevice] = []
    
    init() {
        // Erstellen Sie zuerst den BluetoothSearchDelegate
        let _delegate = BluetoothSearchDelegate()
        self.delegate = _delegate
        self.inquiry = IOBluetoothDeviceInquiry(delegate: _delegate)
        self.inquiry.updateNewDeviceNames = true
    }
    
    private func startInquiry() {
        inquiry.start()
        self.controllerState = .searching
        self.devices = self.delegate.devices
        self.startUpdatingDevices()
    }
    
    private func startUpdatingDevices() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            let bluetoohDevices: [IOBluetoothDevice] = self.inquiry.foundDevices() as? [IOBluetoothDevice] ?? []
            let newDevices = bluetoohDevices.compactMap { device in
                if !self.devices.contains(device) { return device }
                return nil
            }
            self.devices.append(contentsOf: newDevices)
        }
    }
    
    private func stopInquiery() {
        inquiry.stop()
        self.devices = self.inquiry.foundDevices() as? [IOBluetoothDevice] ?? []
    }
}

extension DeskController {
    func getMenuItems() -> [MenuItem] {
        switch controllerState {
        case .active:
            return [
                MenuItem(
                    title: "Verbinden",
                    icon: "point.3.connected.trianglepath.dotted",
                    function: {}
                )
            ]
        case .connected:
            return [
                MenuItem(
                    title: "Hoch",
                    icon: "chevron.up",
                    function: {}
                ),
                MenuItem(
                    title: "Runter",
                    icon: "chevron.down",
                    function: {}
                )
            ]
        case .searching:
            return [
                MenuItem(
                    title: "Stop",
                    icon: "clock.arrow.2.circlepath",
                    function: {
                        self.stopInquiery()
                    }
                )
            ]
        case .working:
            return [
                MenuItem(
                    title: "Hoch",
                    icon: "chevron.up",
                    function: {}
                ),
                MenuItem(
                    title: "Runter",
                    icon: "chevron.down",
                    function: {}
                )
            ]
        case .inactive:
            return [
                MenuItem(
                    title: "Suchen",
                    icon: "magnifyingglass",
                    function: {
                        self.startInquiry()
                    }
                )
            ]
        }
    }
}
