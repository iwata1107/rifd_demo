//
//  CommScannerParams.h
//  DensoScannerSDK
//
//  Created by SP1 on 2018/05/16.
//  Copyright © 2018年 SP1. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark CommScannerParams

@class Autopoweroff, Btbutton, Notification;
typedef NS_ENUM(NSInteger, BuzzerVolume);
typedef NS_ENUM(NSInteger, BuzzerTone);
typedef NS_ENUM(NSInteger, BuzzerDuration);

/**
 共通パラメータ設定値
 */
@interface CommScannerParams : NSObject

/// 低消費設定(true:低消費モード false:ノーマル)
@property bool powerSave;

/// パワーオン時ブザー鳴動(true：ブザー鳴動あり false：ブザー鳴動無し)
@property bool ponBuzzer;

/// 電源ボタン短押しによる残バッテリー確認許可（true：許可する false：許可しない)
@property bool batteryConf;

/// ブザー音量設定
@property enum BuzzerVolume buzzerVolume;

/// ブザー音高さ設定
@property enum BuzzerTone buzzerTone;

/// ブザー音時間設定
@property enum BuzzerDuration buzzerDuration;

/// オートパワーオフ設定
@property Autopoweroff *autopoweroff;

/// ブルートゥースボタン設定
@property Btbutton *btButton;

/// 通知設定
@property Notification *notification;

@end

#pragma mark CommScannerParams.autopoweroff

/**
 オートパワーオフ
 CommScannerParams.autopoweroff
 */
@interface Autopoweroff : NSObject

/// オートパワーオフ(true:オートパワーオフあり false:オートパワーオフなし)
@property bool settings;

/// オートパワーオフ時間(範囲:5分-640分[0x0005~0x0280]) *0x3c(60分)
@property int duration;

@end

#pragma mark CommScannerParams.btbutton

typedef NS_ENUM(NSInteger, ReConnect);

/**
 ブルートゥースボタン
 CommScannerParams.btbutton
 */
@interface Btbutton : NSObject

/// ペアリングボタン長押しによる切断許可(true:切断許可 false:切断禁止)
@property bool disconnectPermit;

/// 切断時の設定
@property enum ReConnect reConnect;

@end

#pragma mark CommScannerParams.btbutton.reConnect

/**
 切断時の設定
 CommScannerParams.btbutton.reConnect
 
 - RE_CONNECT_REPAIRING: ペアリングボタンで再接続
 - RE_CONNECT_WAITHOST: ホストからの接続待ち
 - RE_CONNECT_ANY: 再接続待ちへ必ず遷移
 */
typedef NS_ENUM(NSInteger, ReConnect) {
    RE_CONNECT_REPAIRING
    , RE_CONNECT_WAITHOST
	, RE_CONNECT_ANY
};

#pragma mark CommScannerParams.notification

@class Sound;

/**
 通知
 CommScannerParams.notification
 */
@interface Notification : NSObject

/// サウンド
@property Sound *sound;

/// LED点灯設定(true:有効 false:無効)
@property bool led;

@end

#pragma mark CommScannerParams.notification.sound

typedef NS_ENUM(NSInteger, Buzzer);

/**
 サウンド
 CommScannerParams.notification.sound
 */
@interface Sound : NSObject

/// ブザー鳴動設定
@property enum Buzzer buzzer;

@end

#pragma mark CommScannerParams.notification.sound.buzzer

/**
 ブザー鳴動設定
 CommScannerParams.notification.sound.buzzer
 
 - BUZZER_ENABLE: 有効
 - BUZZER_DISABLE: 無効
 */
typedef NS_ENUM(NSInteger, Buzzer) {
    BUZZER_ENABLE
    , BUZZER_DISABLE
};

#pragma mark CommScannerParams.buzzerVolume

/**
 ブザー音量設定
 CommScannerParams.buzzerVolume
 
 - BUZZER_VOLUME_LOW: 小
 - BUZZER_VOLUME_MIDDLE: 中
 - BUZZER_VOLUME_LOUD: 大
 */
typedef NS_ENUM(NSInteger, BuzzerVolume) {
    BUZZER_VOLUME_LOW
    , BUZZER_VOLUME_MIDDLE
    , BUZZER_VOLUME_LOUD
};

#pragma mark CommScannerParams.buzzerTone

/**
 ブザー音高さ設定
 CommScannerParams.buzzerTone
 
 - BUZZER_TONE_LOW: 低音
 - BUZZER_TONE_MIDDLE: 中音
 - BUZZER_TONE_HIGH: 高音
 */
typedef NS_ENUM(NSInteger, BuzzerTone) {
    BUZZER_TONE_LOW
    , BUZZER_TONE_MIDDLE
    , BUZZER_TONE_HIGH
};

#pragma mark CommScannerParams.buzzerDuration

/**
 ブザー音時間設定
 CommScannerParams.buzzerDuration
 
 - BUZZER_DURATION_SHORT: 短(60ms)
 - BUZZER_DURATION_MIDDLE: 中(80ms)
 - BBUZZER_DURATION_LONG: 長(120ms)
 */
typedef NS_ENUM(NSInteger, BuzzerDuration) {
    BUZZER_DURATION_SHORT
    , BUZZER_DURATION_MIDDLE
    , BBUZZER_DURATION_LONG
};
