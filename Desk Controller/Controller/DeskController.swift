////
////  DeskController.swift
////  Desk Controller
////
////  Created by Roman Zuchowski on 01.10.23.
////
//
//import Foundation
//import IOBluetooth
//import CoreBluetooth
//import SwiftUI
//import Combine
//
//class DeskController: ObservableObject {
//    @ObservedObject var btDelegate: CBManagerDelegate
//    let btManager: CBCentralManager
//    var timer: Timer?
//    
//    //MARK: - Published properties
//    @Published var controllerState: ControllerState = .inactive
//    
//    //MARK: - Movement values
//    @Published var currentPosition: Double = 0.0
//    private var moveToPositionValue: Double? = nil
//    private var moveToPositionTimer: Timer?
//    private let valueMoveUp: UInt16 = 71 // pack("<H", [71, 0])
//    private let valueMoveDown: UInt16 = 70 // pack("<H", [70, 0])
//    private let valueStopMove: UInt16 = 255 // pack("<H", [255, 0])
//    private let deskOffset = 62.5
//    
//    init() {
//        // Erstellen Sie zuerst den BluetoothSearchDelegate
//        let _btDelegate = CBManagerDelegate()
//        self.btDelegate = _btDelegate
//        self.btManager = CBCentralManager(delegate: _btDelegate, queue: DispatchQueue.main)
//        self.startCheckingForConnections()
//    }
//    
//    private func startCheckingForConnections() {
//        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
//            print("Checking for table connection.")
//            if self.btDelegate.tableIsConnected == true {
//                self.controllerState = .connected
//                timer.invalidate()
//            }
//        })
//    }
//}
//
//// MARK: - DESK MOVEMENT
//extension DeskController {
//    func moveTable(direction: MovementDirection) {
//        guard let tablePeripheral = self.btDelegate.tablePeripheral else { return }
//        switch direction {
//        case .up:
//            var dataMoveUp = withUnsafeBytes(of: valueMoveUp.littleEndian) { Data($0) }
//            tablePeripheral.writeValue(dataMoveUp, for: self.btDelegate.characteristicControl, type: CBCharacteristicWriteType.withResponse)
//            break
//        case .down:
//            var dataMoveDown = withUnsafeBytes(of: valueMoveDown.littleEndian) { Data($0) }
//            tablePeripheral.writeValue(dataMoveDown, for: self.btDelegate.characteristicControl, type: CBCharacteristicWriteType.withResponse)
//            break
//        }
//    }
//}
//
//extension DeskController {
//    func updatePosition(characteristic: CBCharacteristic) {
//        if (characteristic.value != nil && characteristic.uuid == LinakPeripheral.characteristicPosition) {
//            let byteArray: [UInt8] = [UInt8](characteristic.value!)
//            if (byteArray.indices.contains(0) && byteArray.indices.contains(1)) {
//                do {
//                    if let position = byteArray[0] as? Int {
//                        let formattedPosition = Double(round(Double(position) + (self.deskOffset * 100)) / 100)
//                        let roundedPosition = Double(round(formattedPosition * 0.5) / 0.5)
//                        self.currentPosition = roundedPosition
//                        
//                        let requiredPosition = self.moveToPositionValue ?? .nan
//                        if (requiredPosition != .nan) {
//                            if (formattedPosition > (requiredPosition - 0.75) && formattedPosition < (requiredPosition + 0.75)) {
//                                self.moveToPositionTimer?.invalidate()
//                                self.moveToPositionValue = nil
//                                self.stopMoving()
//                            }
//                        }
//                    }
//                } catch let error as NSError {
//                    print("Error, update position: \(error)")
//                }
//            }
//        }
//    }
//    func stopMoving() {
//        var dataStopMoving = withUnsafeBytes(of: valueStopMove.littleEndian) { Data($0) }
//        self.btDelegate.tablePeripheral?.writeValue(dataStopMoving, for: self.btDelegate.characteristicControl, type: CBCharacteristicWriteType.withResponse)
//    }
//    func moveToPosition(position: Double) {
//        self.moveToPositionValue = position
//        self.handleMoveToPosition()
//        print("STARTING TO MOVE TO POSITION \(position)")
//        
//        self.moveToPositionTimer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true, block: { timer in
//            print("Moving >>> \(self.currentPosition)")
//            if self.moveToPositionValue == nil {
//                timer.invalidate()
//            } else {
//                self.handleMoveToPosition()
//            }
//        })
//    }
//    func handleMoveToPosition() {
//        let positionRequired = self.moveToPositionValue ?? .nan
//        if positionRequired < self.currentPosition {
//            self.moveTable(direction: .down)
//        } else if positionRequired > self.currentPosition {
//            self.moveTable(direction: .up)
//        }
//    }
//}
//
//extension DeskController {
//    func getMenuItems() -> [MenuItem] {
//        switch btDelegate.controllerState {
//        case .active:
//            return [
//                MenuItem(
//                    title: "Verbinden",
//                    icon: "point.3.connected.trianglepath.dotted",
//                    function: {
//                        guard let tablePeripheral = self.btDelegate.tablePeripheral else {
//                            return
//                        }
//                        self.btManager.connect(tablePeripheral)
//                    }
//                )
//            ]
//        case .connected:
//            return [
//                MenuItem(
//                    title: "Hoch",
//                    icon: "chevron.up",
//                    function: {
//                        self.moveTable(direction: .up)
//                    }
//                ),
//                MenuItem(
//                    title: "Runter",
//                    icon: "chevron.down",
//                    function: {
//                        self.moveTable(direction: .down)
//                    }
//                ),
//                MenuItem(
//                    title: "Niedrig",
//                    icon: "dial.low",
//                    function: {
//                        self.moveToPosition(position: 62.0)
//                    },
//                    divider: true
//                ),
//                MenuItem(
//                    title: "Mittel",
//                    icon: "dial.medium",
//                    function: {
//                        self.moveToPosition(position: 87.0)
//                    }
//                ),
//                MenuItem(
//                    title: "Hoch",
//                    icon: "dial.high",
//                    function: {
//                        self.moveToPosition(position: 120.0)
//                    }
//                )
//            ]
//        case .inactive:
//            return [
//                MenuItem(
//                    title: "Suchen",
//                    icon: "magnifyingglass",
//                    function: {
//                        self.btManager.scanForPeripherals(withServices: nil)
//                    }
//                )
//            ]
//        }
//    }
//}
