//
//  RFIDScannerSettings.h
//  DensoScannerSDK
//
//  Created by SP1 on 2018/05/22.
//  Copyright © 2018年 SP1. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark RFIDScannerSettings

@class RFIDScannerScan;
typedef NS_ENUM(NSInteger, RFIDBank);
typedef NS_ENUM(NSInteger, RFIDLock);
typedef NS_ENUM(NSInteger, SessionFlag);
typedef NS_ENUM(NSInteger, Polarization);
typedef NS_ENUM(NSInteger, DoubleReading);
typedef NS_ENUM(NSInteger, PowerSaveExt);

/**
 RFID読み取り関連設定値
 */
@interface RFIDScannerSettings : NSObject

/// スキャン設定
@property RFIDScannerScan *scan;

@end

#pragma mark RFIDScannerSettings::RFIDBank

/**
 バンク
 
 - RFID_BANK_RESERVED: Reserved bank
 - RFID_BANK_UII: UII bank
 - RFID_BANK_TID: TID bank
 - RFID_BANK_USER: USER bank
 */
typedef NS_ENUM(NSInteger, RFIDBank) {
    RFID_BANK_RESERVED NS_SWIFT_NAME(RFID_BANK_RESERVED)
    , RFID_BANK_UII NS_SWIFT_NAME(RFID_BANK_UII)
    , RFID_BANK_TID NS_SWIFT_NAME(RFID_BANK_TID)
    , RFID_BANK_USER NS_SWIFT_NAME(RFID_BANK_USER)
};

#pragma mark RFIDScannerSettings::RFIDLock

/**
 ロックタイプ
 
 - RFID_LOCK_UNLOCK: アンロック
 - RFID_LOCK_LOCK: ロック
 - RFID_LOCK_PERMANENT_UNLOCK: 永久アンロック
 - RFID_LOCK_PERMANENT_LOCK: 永久ロック
 */
typedef NS_ENUM(NSInteger, RFIDLock) {
    RFID_LOCK_UNLOCK NS_SWIFT_NAME(RFID_LOCK_UNLOCK)
    , RFID_LOCK_LOCK NS_SWIFT_NAME(RFID_LOCK_LOCK)
    , RFID_LOCK_PERMANENT_UNLOCK NS_SWIFT_NAME(RFID_LOCK_PERMANENT_UNLOCK)
    , RFID_LOCK_PERMANENT_LOCK NS_SWIFT_NAME(RFID_LOCK_PERMANENT_LOCK)
};

#pragma mark RFIDScannerSettings.scan

typedef NS_ENUM(NSInteger, RFIDScannerSettingsTriggerMode);

/**
 読み取り動作関連
 */
@interface RFIDScannerScan : NSObject

/// トリガーモード
@property enum RFIDScannerSettingsTriggerMode triggerMode;

/// ワンショット時間　* トリガーモード「オートオフ/ワンショット」用
@property short oneshot;

/// Read時の出力(0x028 〜　0x012c)
@property int powerLevelRead;

/// Write時の出力(0x028 〜　0x012c)
@property int powerLevelWrite;

/// 周波数設定(0x00000000 ~ 0x0007FFFF) * 0x00001FF8(Ch24~Ch32許可)
@property long channel;

/// Q値(0~7)
@property short qParam;

/// セッションフラグ
@property enum SessionFlag sessionFlag;

/// セッション初期化(true:有効　false:禁止)
@property bool sessionInit;

/// 偏波設定
@property enum Polarization polarization;

/// 省電力設定(true:有効　false:禁止)
@property bool powerSave;

/// 二度読み防止
@property enum DoubleReading doubleReading;

/// Write時Verify(true:ベリファイあり　false:ベリファイ無し)
@property bool writeVeri;

/// Link Profile番号設定(1と4と5のみ使用可能 )
@property short linkProfile;

/// 拡張省電力設定
@property enum PowerSaveExt powerSaveExt;

@end

#pragma mark RFIDScannerSettings.scan.triggerMode

/**
 トリガーモード（RFID）
 
 - RFID_TRIGGER_MODE_AUTO_OFF: オートオフモード
 - RFID_TRIGGER_MODE_MOMENTARY: モメンタリモード
 - RFID_TRIGGER_MODE_ALTERNATE: オルタネートモード
 - RFID_TRIGGER_MODE_CONTINUOUS1: 連続読み取りモード1
 - RFID_TRIGGER_MODE_CONTINUOUS2: 連続読み取りモード2
 */
typedef NS_ENUM(NSInteger, RFIDScannerSettingsTriggerMode) {
    RFID_TRIGGER_MODE_AUTO_OFF NS_SWIFT_NAME(RFID_TRIGGER_MODE_AUTO_OFF)
    , RFID_TRIGGER_MODE_MOMENTARY NS_SWIFT_NAME(RFID_TRIGGER_MODE_MOMENTARY)
    , RFID_TRIGGER_MODE_ALTERNATE NS_SWIFT_NAME(RFID_TRIGGER_MODE_ALTERNATE)
    , RFID_TRIGGER_MODE_CONTINUOUS1 NS_SWIFT_NAME(RFID_TRIGGER_MODE_CONTINUOUS1)
    , RFID_TRIGGER_MODE_CONTINUOUS2 NS_SWIFT_NAME(RFID_TRIGGER_MODE_CONTINUOUS2)
};

#pragma mark RFIDScannerSettings.sessionFlag

/**
 セッションフラグ
 
 - SESSION_FLAG_S0: RFタグ通信待機状態後、再度同じRFタグのUII取得可能となる
 - SESSION_FLAG_S1: RFタグのUII取得後、規定時間以上経過すれば再度同じRFタグのUII取得可能となる
 - SESSION_FLAG_S2: RFタグ通信待機状態後、規定時間以上経過すれば再度同じRFタグのUII取得可能となる
 - SESSION_FLAG_S3: S2と同じ
 */
typedef NS_ENUM(NSInteger, SessionFlag) {
    SESSION_FLAG_S0
    , SESSION_FLAG_S1
    , SESSION_FLAG_S2
    , SESSION_FLAG_S3
};

#pragma mark RFIDScannerSettings.polarization

/**
 偏波設定
 
 - POLARIZATION_V: 垂直のみ
 - POLARIZATION_H: 水平のみ
 - POLARIZATION_BOTH: 垂直、水平両方
 */
typedef NS_ENUM(NSInteger, Polarization) {
    POLARIZATION_V
    , POLARIZATION_H
    , POLARIZATION_BOTH
};

#pragma mark RFIDScannerSettings.doubleReading

/**
 二度読み防止
 
 - DOUBLE_READING_FREE: 二度読み防止なし
 - DOUBLE_READING_PREVENT1: RFタグ通信動作中二度読み防止実施
 - DOUBLE_READING_PREVENT2: 読み取り動作中二度読み防止実施
 */
typedef NS_ENUM(NSInteger, DoubleReading) {
    DOUBLE_READING_FREE
    , DOUBLE_READING_PREVENT1
    , DOUBLE_READING_PREVENT2
};

#pragma mark RFIDScannerSettings.powerSaveExt

/**
 拡張省電力モード
 
 - POWERSAVE_EXT_DISABLE: 省電力無効
 - POWERSAVE_EXT_MODE1: 省電力モード1
 - POWERSAVE_EXT_MODE2: 省電力モード2
*/
typedef NS_ENUM(NSInteger, PowerSaveExt) {
    POWERSAVE_EXT_DISABLE
    , POWERSAVE_EXT_MODE1
    , POWERSAVE_EXT_MODE2
};
