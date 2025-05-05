//
//  CommConst.h
//  DensoScannerSDK
//
//  Created by SP1 on 2018/05/08.
//  Copyright © 2018年 SP1. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 スキャンモード
 CommConst::CommScanMode

 - COMM_SCAN_MODE_BARCODE: バーコード
 - COMM_SCAN_MODE_RFID: RFID
 - COMM_SCAN_MODE_UNKNOWN: 不明な状態
 */
typedef NS_ENUM(NSInteger, CommScanMode) {
    COMM_SCAN_MODE_BARCODE
    , COMM_SCAN_MODE_RFID
    , COMM_SCAN_MODE_UNKNOWN
};

/**
 バッテリー残量モード
 CommConst::CommBattery

 - COMM_BATTERY_UNDER10: 残量10%未満
 - COMM_BATTERY_UNDER40: 残量40%未満
 - COMM_BATTERY_OVER40: 残量40%以上
 */
typedef NS_ENUM(NSInteger, CommBattery) {
    COMM_BATTERY_UNDER10
    , COMM_BATTERY_UNDER40
    , COMM_BATTERY_OVER40
};

/**
 スキャナのステータス
 CommConst::ScannerStatus
 - SCANNER_STATUS_CLAIMED: スキャナが獲得されました
 - SCANNER_STATUS_CLOSE_WAIT: クローズ待ちです。切断検知するとCommScanner#closeされるまでこの状態となります
 - SCANNER_STATUS_CLOSED:  スキャナが解放されました
 - SCANNER_STATUS_UNKNOWN: 不明な状態です
 */
typedef NS_ENUM(NSInteger, ScannerStatus) {
    SCANNER_STATUS_CLAIMED
    , SCANNER_STATUS_CLOSE_WAIT
    , SCANNER_STATUS_CLOSED
    , SCANNER_STATUS_UNKNOWN
};

/**
 キーの名前
 CommConst::ScannerKeyName
 
 - SCANNER_KEY_NAME_TRIGGER: トリガーキーの状態が変化
 - SCANNER_KEY_NAME_UNKNOWN: 不明なキーの状態が変化
 */
typedef NS_ENUM(NSInteger, ScannerKeyName) {
    SCANNER_KEY_NAME_TRIGGER
    , SCANNER_KEY_NAME_UNKNOWN
};

/**
 キー状態
 CommConst::ScannerKeyStatus
 
 - SCANNER_KEY_STATUS_RELEASE: キーが離された
 - SCANNER_KEY_STATUS_PRESS: キーが押された
 - SCANNER_KEY_STATUS_UNKNOWN: キー状態不明
 */
typedef NS_ENUM(NSInteger, ScannerKeyStatus) {
    SCANNER_KEY_STATUS_RELEASE
    , SCANNER_KEY_STATUS_PRESS
    , SCANNER_KEY_STATUS_UNKNOWN
};

/**
 ブザー鳴動タイプ
 CommConst::CommBuzzerType
 
 - COMM_BUZZER_B1: 約60ms鳴動
 - COMM_BUZZER_B2: 約80ms鳴動
 - COMM_BUZZER_B3: 約120ms鳴動
 */
typedef NS_ENUM(NSInteger, CommBuzzerType) {
    COMM_BUZZER_B1
    , COMM_BUZZER_B2
    , COMM_BUZZER_B3
};

/**
 LEDタイプ
 CommConst::CommLEDType
 
 - COMM_LED_TYPE_LED1: 表示LED1を約500ms点灯させる
 - COMM_LED_TYPE_LED2: 表示LED2を約500ms点灯させる
 - COMM_LED_TYPE_LED3: 表示LED3を約500ms点灯させる
 */
typedef NS_ENUM(NSInteger, CommLEDType) {
    COMM_LED_TYPE_LED1
    , COMM_LED_TYPE_LED2
    , COMM_LED_TYPE_LED3
};

/**
 LED指定色
 CommConst::CommLEDColor
 
 - COMM_LED_COLOR_RED: 赤色で点灯させる
 - COMM_LED_COLOR_ORANGE: 橙色で点灯させる
 - COMM_LED_COLOR_BLUE: 青色で点灯させる
 - COMM_LED_COLOR_GREEN: 綠色で点灯させる
 */
typedef NS_ENUM(NSInteger, CommLEDColor) {
    COMM_LED_COLOR_RED
    , COMM_LED_COLOR_ORANGE
    , COMM_LED_COLOR_BLUE
    , COMM_LED_COLOR_GREEN
};

/**
 初期化タイプ
 CommConst::CommInitType
 
 - COMM_PARAMS: 共通パラメータ初期化
 - BT_PARAMS: Bluetoothパラメータ初期化
 - RFID_PARAMS: RFIDパラメータ初期化
 - BARCODE_PARAMS: バーコードパラメータ初期化
 - ALL_PARAMS: 全てのパラメータ初期化
 */
typedef NS_ENUM(NSInteger, CommInitType) {
    COMM_PARAMS
    , BT_PARAMS
    , RFID_PARAMS
    , BARCODE_PARAMS
    , ALL_PARAMS
};

/**
 スキャナ種類
 CommConst::CommScannerType
 
 - TYPE_1D:1次元バーコードスキャナ
 - TYPE_2D:2次元バーコードスキャナ
 - TYPE_2D_LONG:ロングレンジ2次元バーコードスキャナ
 - TYPE_UNKNOWN:不明なバーコードスキャナ
 - TYPE_RFID:RFIDスキャナ
 - TYPE_2D_RFID:2次元バーコードとRFIDスキャナ複合機
 */
typedef NS_ENUM(NSInteger, CommScannerType) {
    TYPE_1D
    , TYPE_2D
    , TYPE_2D_LONG
    , TYPE_UNKNOWN
    , TYPE_RFID
    , TYPE_2D_RFID
};

