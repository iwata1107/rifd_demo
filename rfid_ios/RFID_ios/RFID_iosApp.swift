//
//  RFID_iosApp.swift
//  RFID_ios
//
//  Created by 岩田照太 on 2024/11/13.
//

import SwiftUI
import DENSOScannerSDK

@main
struct DensoScannerApp: App {
    @StateObject private var deps = AppDependencies()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(deps.scannerManager)
                .environmentObject(deps.settingManager)
                .environmentObject(deps.compareManager)
                .environmentObject(deps.itemRegistrationManager)
                .environmentObject(deps.inventoryMasterManager)

        }
    }
}

