//
//  BluetoothSearchDelegate.swift
//  Desk Controller
//
//  Created by Roman Zuchowski on 01.10.23.
//

import SwiftUI
import CoreBluetooth

class CBManagerDelegate: NSObject, ObservableObject, CBCentralManagerDelegate {
    
    @Published var cbManager: CBCentralManager = CBCentralManager()
    @Published var tableIsConnected: Bool = false
    @Published var tableIsMoving: Bool = false
    @Published var peripheral: CBPeripheral?
    @Published var desk: LinakPeripheral?
    @Published var controllerState: ControllerState = .inactive
    @Published var characteristicControl: CBCharacteristic!
    @Published var characteristicPosition: CBCharacteristic!
    
    //MARK: - Movement Values
    private var moveToPositionValue: Float? = nil
    private var moveToPositionTimer: Timer?
    private var currentMoveDirection: MovementDirection = .stop
    
    // MARK: - Initialization
    override init() {
        super.init()
        cbManager.delegate = self
    }
    
    //MARK: - Central Manager
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("The state of the bluetooth manager changed to \(central.state).")
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print(">>> Connection failed when trying to connect to \(peripheral).")
        print(">>> \(error?.localizedDescription)")
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
    {
        if peripheral.identifier.uuidString == LinakPeripheral.identifier.uuidString {
            let desk: LinakPeripheral = LinakPeripheral(peripheral: peripheral)
            self.peripheral = peripheral
            self.desk = desk
            central.connect(peripheral)
            central.stopScan()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral)")
        self.controllerState = .connected
        self.tableIsConnected = true
        self.peripheral!.discoverServices(LinakPeripheral.allServices)
    }
    
    //MARK: - Peripheral
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("Discovering services for \(peripheral.name!)")
        print("Services in peripheral: \(peripheral.services)")
        if let services = peripheral.services {
            for service in services {
                print("Trying to discover characteristics.")
                self.peripheral?.discoverCharacteristics(LinakPeripheral.allCharacteristics, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                print(characteristic.uuid)
                if characteristic.uuid == LinakPeripheral.characteristicControl {
                    print("Setting characteristicControl >>> \(characteristic)")
                    self.characteristicControl = characteristic
                }
                if characteristic.uuid == LinakPeripheral.characteristicPosition {
                    print("Setting characteristicPosition >>> \(characteristic)")
                    self.characteristicPosition = characteristic
                }
//                if characteristic.uuid == LinakPeripheral.characteristicDPG {
//                    print("Setting characteristicDPG >>> \(characteristic)")
//                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // self.updatePosition(characteristic: characteristic)
    }
    
    //MARK: - Table Movement
    func moveTable(direction: MovementDirection) {
        guard let peripheral: CBPeripheral = self.peripheral else { return }
        let movementData: Data = self.getMovementData(direction: direction)
        self.tableIsMoving = true
        peripheral.writeValue(movementData, for: self.desk!.controlCharacteristic!, type: CBCharacteristicWriteType.withResponse)
    }
    
    func updatePosition(characteristic: CBCharacteristic) {
        print("Updating position...")
        if (characteristic.value != nil && characteristic.uuid == LinakPeripheral.characteristicPosition) {
            let byteArray: [UInt8] = [UInt8](characteristic.value!)
            if (byteArray.indices.contains(0) && byteArray.indices.contains(1)) {
                do {
                    if let position = byteArray[0] as? Int {
                        let deskPosition: Float = desk!.position ?? 0.0
                        let deskOffset: Float = desk!.deskOffset
                        let formattedPosition = Float(round(deskPosition + (deskOffset * 100)) / 100)
//                        let formattedPosition = Double(round(Double(desk!.position) + (desk!.deskOffset * 100)) / 100)
                        let roundedPosition = Float(round(formattedPosition * 0.5) / 0.5)
                        self.desk?.position = roundedPosition
                        
                        let requiredPosition = self.moveToPositionValue ?? .nan
                        if (requiredPosition != .nan) {
                            if (formattedPosition > (requiredPosition - 0.75) && formattedPosition < (requiredPosition + 0.75)) {
                                self.moveToPositionTimer?.invalidate()
                                self.moveToPositionValue = nil
                                self.stopMoving()
                            }
                        }
                    }
                } catch let error as NSError {
                    print("Error, update position: \(error)")
                }
            }
        }
    }
    
    private func getMovementData(direction: MovementDirection) -> Data {
        switch direction {
        case .up:
            return Data(hexString: LinakPeripheral.valueMoveUp)!
        case .down:
            return Data(hexString: LinakPeripheral.valueMoveDown)!
        case .stop:
            return Data(hexString: LinakPeripheral.valueMoveStop)!
        }
    }
    
    private func stopMoving() {
        self.tableIsMoving = false
        var movementData = getMovementData(direction: .stop)
        self.peripheral?.writeValue(movementData, for: (self.desk?.controlCharacteristic!)!, type: CBCharacteristicWriteType.withResponse)
    }
    
    func moveToPosition(state: DeskState) {
        
        if self.desk?.currentDeskState != state {
            self.desk?.currentDeskState = state
            var position: Float?
            switch state {
            case .low:
                position = 62.0
            case .mid:
                position = 87.0
            case .high:
                position = 120.0
            case .unknown:
                position = 87.0
            }
            
            if let position = position {
                self.moveToPositionValue = position
                self.handleMoveToPosition()
                print("STARTING TO MOVE TO POSITION \(position)")
                
                self.moveToPositionTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { timer in
                    print("Moving >>> \(self.desk?.position! ?? 0.0)")
                    let distance: Float = (self.desk?.position ?? 0.0) - position
                    print("Distance to desired position: \(distance)")
                    if self.moveToPositionValue == nil || (distance >= -0.5 && distance <= 0.5) {
                        self.stopMoving()
                        timer.invalidate()
                    } else {
                        self.handleMoveToPosition()
                    }
                })
            }
        } else { return }
    }
    
    func handleMoveToPosition() {
        self.updatePosition(characteristic: (self.desk?.positionCharacteristic)!)
        let positionRequired = self.moveToPositionValue ?? .nan
        if positionRequired < self.desk?.position ?? 0.0 {
            self.moveTable(direction: .down)
        } else if positionRequired > self.desk?.position ?? 0.0 {
            self.moveTable(direction: .up)
        } else if (positionRequired.distance(to: (self.desk?.position!)!) <= 1) {
            print("Stopping to move...")
            self.moveToPositionValue = nil
        }
    }
    
    func getMenuItems() -> [MenuItem] {
        switch self.controllerState {
        case .inactive:
            return []
        case .active:
            return []
        case .connected:
            return [
                MenuItem(
                    title: "Hoch",
                    icon: "chevron.up",
                    function: {
                        self.desk?.currentDeskState = .unknown
                        self.moveTable(direction: .up)
                    }
                ),
                MenuItem(
                    title: "Runter",
                    icon: "chevron.down",
                    function: {
                        self.desk?.currentDeskState = .unknown
                        self.moveTable(direction: .down)
                    }
                ),
                MenuItem(
                    title: "Niedrig",
                    icon: "dial.low",
                    function: {
                        self.moveToPosition(state: .low)
                    },
                    divider: true
                ),
                MenuItem(
                    title: "Mittel",
                    icon: "dial.medium",
                    function: {
                        self.moveToPosition(state: .mid)
                    }
                ),
                MenuItem(
                    title: "Hoch",
                    icon: "dial.high",
                    function: {
                        self.moveToPosition(state: .high)
                    }
                )
            ]
        }
    }
}
