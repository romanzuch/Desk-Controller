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
    @Published var peripheralsAdditional: [CBPeripheral] = []
    @Published var peripheral: CBPeripheral?
    @Published var desk: LinakPeripheral?
    @Published var controllerState: ControllerState = .inactive
    @Published var characteristicControl: CBCharacteristic!
    @Published var characteristicPosition: CBCharacteristic!
    
    //MARK: - Movement Values
    private var moveToPositionValue: Float? = nil
    private var moveToPositionTimer: Timer?
    private var currentMoveDirection: MovementDirection = .stop
    
    //MARK: - Connection
    private var connectionTimer: Timer?
    
    // MARK: - Initialization
    override init() {
        super.init()
        cbManager.delegate = self
    }
    
    //MARK: - Central Manager
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("The state of the bluetooth manager changed to \(central.state).")
        self.initiateConnectToDesk()
    }
    
    func initiateConnectToDesk() {
        if self.cbManager.state == .poweredOn {
            print("Trying to establish connection.")
            self.cbManager.scanForPeripherals(withServices: nil)
        }
    }
    
    func initiateConnectToDesk(handler: @escaping ((Result<CBPeripheral, Error>) -> Void)) {
        switch self.cbManager.state {
        case .unknown:
            handler(.failure(NSError(domain: "Bluetooth Connection Error", code: 404)))
        case .resetting:
            handler(.failure(NSError(domain: "Bluetooth Connection Error", code: 204)))
        case .unsupported:
            handler(.failure(NSError(domain: "Bluetooth Connection Error", code: 500)))
        case .unauthorized:
            handler(.failure(NSError(domain: "Bluetooth Connection Error", code: 501)))
        case .poweredOff:
            handler(.failure(NSError(domain: "Bluetooth Connection Error", code: 502)))
        case .poweredOn:
            self.cbManager.scanForPeripherals(withServices: nil)
            self.connectionTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                if let peripheral = self.peripheral {
                    if let controlCharacteristic = self.desk?.controlCharacteristic {
                        handler(.success(self.peripheral!))
                        timer.invalidate()
                    }
                }
            }
            handler(.failure(NSError(domain: "Bluetooth Connection Error", code: 500)))
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print(">>> Connection failed when trying to connect to \(peripheral).")
        print(">>> \(String(describing: error?.localizedDescription))")
        if let timer = self.connectionTimer {
            timer.invalidate()
        }
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
        if (!peripheralsAdditional.contains(peripheral)) {
            if let peripheralName = peripheral.name {
                if peripheralName.contains("Desk") { peripheralsAdditional.append(peripheral) }
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral)")
        self.controllerState = .connected
        self.tableIsConnected = true
        self.peripheral!.discoverServices(LinakPeripheral.allServices)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.tableIsConnected = false
        self.peripheral = nil
    }
    
    //MARK: - Peripheral
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("Discovering services for \(peripheral.name!)")
        print("Services in peripheral: \(String(describing: peripheral.services))")
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
        if let controlCharacteristic = self.desk?.controlCharacteristic {
            peripheral.writeValue(movementData, for: controlCharacteristic, type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    func updatePosition(characteristic: CBCharacteristic) {
        print("Updating position...")
        if (characteristic.value != nil && characteristic.uuid == LinakPeripheral.characteristicPosition) {
            let byteArray: [UInt8] = [UInt8](characteristic.value!)
            if (byteArray.indices.contains(0) && byteArray.indices.contains(1)) {
                let deskPosition: Float = desk!.position ?? 0.0
                let deskOffset: Float = desk!.deskOffset
                let formattedPosition = Float(round(deskPosition + (deskOffset * 100)) / 100)
                let roundedPosition = Float(round(formattedPosition * 0.5) / 0.5)
                self.desk?.position = roundedPosition
                
                let requiredPosition = self.moveToPositionValue ?? .nan
                if !requiredPosition.isNaN {
                    if (formattedPosition > (requiredPosition - 0.75) && formattedPosition < (requiredPosition + 0.75)) {
                        self.moveToPositionTimer?.invalidate()
                        self.moveToPositionValue = nil
                        self.stopMoving()
                    }
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
    
    func stopMoving() {
        self.tableIsMoving = false
        let movementData = getMovementData(direction: .stop)
        self.peripheral?.writeValue(movementData, for: (self.desk?.controlCharacteristic!)!, type: CBCharacteristicWriteType.withResponse)
    }
    
    func moveTable(to height: Float, with state: DeskState) {
        // check whether the setting has changed since it was last triggered
        // currently, when changing the setting, it won't move after triggered
        if self.desk?.currentDeskState != state {
            self.desk?.currentDeskState = state
            self.handleMovement(height: height)
        }
    }
    
    func moveToPosition(state: DeskState) {
        
        if self.desk?.currentDeskState != state {
            self.desk?.currentDeskState = state
            var position: Float?
            switch state {
            case .low:
                position = 62.0
            case .mid:
                position = 84.0
            case .high:
                position = 120.0
            case .unknown:
                position = 87.0
            }
            
            if let position = position {
                self.handleMovement(height: position)
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
    
    func handleMovement(height: Float) {
        self.moveToPositionValue = height
        self.handleMoveToPosition()
        print("STARTING TO MOVE TO POSITION \(height)")
        
        self.moveToPositionTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { timer in
            print("Moving >>> \(self.desk?.position! ?? 0.0)")
            let distance: Float = (self.desk?.position ?? 0.0) - height
            print("Distance to desired position: \(distance)")
            if self.moveToPositionValue == nil || (distance >= -0.5 && distance <= 0.5) {
                self.stopMoving()
                timer.invalidate()
            } else {
                self.handleMoveToPosition()
            }
        })
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
