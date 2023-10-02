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
}
