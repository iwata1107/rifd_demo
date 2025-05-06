//  SettingsView.swift
//  RFID_ios
//
//  Created by 岩田照太 on 2025/05/05.
//

import SwiftUI
import DENSOScannerSDK   // CommBattery 型参照

struct SettingsView: View {

    @EnvironmentObject var settingManager: SettingManager

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Buzzer")) {
                    Toggle("Buzzer ON", isOn: $settingManager.isBuzzerOn)
                        .disabled(!settingManager.isConnected)

                    Picker("Pattern", selection: $settingManager.selectedBuzzer) {
                        Text("System (B1)").tag(CommBuzzerType.COMM_BUZZER_B1)
                        Text("120 ms (B2)").tag(CommBuzzerType.COMM_BUZZER_B2)
                        Text("240 ms (B3)").tag(CommBuzzerType.COMM_BUZZER_B3)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .disabled(!settingManager.isBuzzerOn || !settingManager.isConnected)

                    Button("Test Buzzer") { settingManager.playSelectedBuzzer() }
                        .disabled(!settingManager.isBuzzerOn || !settingManager.isConnected)
                }

                // 追加: 読み取り強度（パワーレベル）設定
                Section(header: Text("RFID Read Power")) {
                    Picker("Power Level (dBm)", selection: $settingManager.selectedReadPower) {
                        ForEach(settingManager.readPowerRange, id: \ .self) { v in
                            Text("\(v) dBm").tag(v)
                        }
                    }
                    .pickerStyle(.wheel)
                    .disabled(!settingManager.isConnected)
                }

                Section(header: Text("Scanner Info")) {
                    HStack {
                        Text("Battery Status")
                        Spacer()
                        batteryStatusView(
                            for: settingManager.batteryLevel,
                            isConnected: settingManager.isConnected
                        )
                    }
                    Button("Refresh Battery") {
                        settingManager.refreshBatteryLevel()
                    }
                    .disabled(!settingManager.isConnected)
                }
            }
            .navigationTitle("Settings")
        }
    }

    // MARK: - 表示ヘルパー -----------------------------------------------------

    @ViewBuilder
    private func batteryStatusView(for level: CommBattery,
                                   isConnected: Bool) -> some View {
        if !isConnected {
            Text("Disconnected").foregroundColor(.gray)
        } else {
            HStack {
                Text(batteryLevelText(for: level))
                    .foregroundColor(batteryColor(for: level))
                Image(systemName: batteryImageName(for: level))
                    .foregroundColor(batteryColor(for: level))
            }
        }
    }

    private func batteryLevelText(for level: CommBattery) -> String {
        switch level {
        case .COMM_BATTERY_UNDER10: return "< 10%"
        case .COMM_BATTERY_UNDER40: return "< 40%"
        case .COMM_BATTERY_OVER40:  return "≥ 40%"
        default:                    return "Unknown"
        }
    }

    private func batteryImageName(for level: CommBattery) -> String {
        switch level {
        case .COMM_BATTERY_UNDER10: return "battery.0"
        case .COMM_BATTERY_UNDER40: return "battery.25"
        case .COMM_BATTERY_OVER40:  return "battery.100"
        default:                    return "battery.100.bolt"
        }
    }

    private func batteryColor(for level: CommBattery) -> Color {
        switch level {
        case .COMM_BATTERY_UNDER10: return .red
        case .COMM_BATTERY_UNDER40: return .orange
        case .COMM_BATTERY_OVER40:  return .green
        default:                    return .gray
        }
    }
}
