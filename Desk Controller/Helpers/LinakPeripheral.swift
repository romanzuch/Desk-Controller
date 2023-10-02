//
//  LinakPeripheral.swift
//  Desk Controller
//
//  Created by Roman Zuchowski on 02.10.23.
//

import CoreBluetooth

class LinakPeripheral: NSObject {
    
    public static let identifier: CBUUID = CBUUID(string: "4CF85C7A-AEC3-B44B-4F5A-0E732BACD5FD")
    
    public static let serviceDPG: CBUUID = CBUUID.init(string: "99FA0010-338A-1024-8A49-009C0215F78A")
    public static let servicePosition: CBUUID = CBUUID(string: "99FA0020-338A-1024-8A49-009C0215F78A")
    public static let serviceControl: CBUUID = CBUUID(string: "99FA0001-338A-1024-8A49-009C0215F78A")
    
    public static let characteristicDPG: CBUUID = CBUUID.init(string: "99FA0011-338A-1024-8A49-009C0215F78A")
    public static let characteristicPosition: CBUUID = CBUUID(string: "99FA0021-338A-1024-8A49-009C0215F78A")
    public static let characteristicControl: CBUUID = CBUUID(string: "99FA0002-338A-1024-8A49-009C0215F78A")
    
    public static let allServices: [CBUUID] = [
        serviceDPG,
        servicePosition,
        serviceControl
    ]
    
    public static let allCharacteristics: [CBUUID] = [
        characteristicDPG,
        characteristicPosition,
        characteristicControl
    ]

    public static let valueMoveUp: String = "4700"
    public static let valueMoveDown: String = "4600"
    public static let valueMoveStop: String = "FF00"
    
    var positionService: CBService?
    var positionCharacteristic: CBCharacteristic?
    var controlService: CBService?
    var controlCharacteristic: CBCharacteristic?
    
    var hasLoadedPositionCharacteristicValues = false
    var onPositionChange: (Float) -> Void = { _ in }
    
    let peripheral: CBPeripheral
    var speed: Float = 0.0
    var deskOffset: Float = 62.5
    public var position: Float? {
        didSet {
        // print("\(position)cm")
            if let position = position, hasLoadedPositionCharacteristicValues {
                onPositionChange(position)
            }
            
        }
    }
    
    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
        
        super.init()
        
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
}

extension LinakPeripheral: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        services.forEach { service in
            if service.uuid == LinakPeripheral.servicePosition {
                positionService = service
                // print("Discovered position service: \(service)")
            } else if service.uuid == LinakPeripheral.serviceControl {
                controlService = service
                // print("Discovered control service: \(service)")
            } else {
                return
            }
            
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
            
        guard peripheral == self.peripheral, let characteristics = service.characteristics else {
            return
        }
        
        characteristics.forEach { characteristic in
            if characteristic.uuid == LinakPeripheral.characteristicPosition {
                // print("Discovered position characteristic: \(characteristic)")
                positionCharacteristic = characteristic
                
                peripheral.readValue(for: characteristic)
                // Start monitoring the position / speed
                peripheral.setNotifyValue(true, for: characteristic)
            } else if characteristic.uuid == LinakPeripheral.characteristicControl {
                // print("Discovered control characteristic: \(characteristic)")
                controlCharacteristic = characteristic
            } else {
                return
            }
            
            print(characteristic.properties)
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
            
        if characteristic == positionCharacteristic, let value = characteristic.value {
            
            hasLoadedPositionCharacteristicValues = true
            
            // Position = 16 Little Endian – Unsigned
            // Speed = 16 Little Endian – Signed
            
            let positionValue = [value[0], value[1]].withUnsafeBytes {
                $0.load(as: UInt16.self)
            }
            
            let speedValue = [value[2], value[3]].withUnsafeBytes {
                $0.load(as: Int16.self)
            }
            
            speed = Float(speedValue)
            position = Float(positionValue) / 100 + self.deskOffset

        }
        
    }
}
