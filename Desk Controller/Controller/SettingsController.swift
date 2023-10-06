//
//  SettingsController.swift
//  Desk Controller
//
//  Created by Roman Zuchowski on 05.10.23.
//

import Foundation

class SettingsController {
    
    let btDelegate: CBManagerDelegate
    
    init(for btDelegate: CBManagerDelegate) {
        self.btDelegate = btDelegate
    }
    
    func getFormattedHeightString() -> String {
        return String(format: "%.2f", self.btDelegate.desk?.position ?? 0.0).replacingOccurrences(of: ".", with: ",")
    }
}
