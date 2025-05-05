//
//  CommScannerBtSettings.h
//  DensoScannerSDK
//
//  Created by SP1 on 2018/08/01.
//  Copyright © 2018年 SP1. All rights reserved.
//

#import <Foundation/Foundation.h>

// CommScannerBTSettings関連
#pragma mark CommScannerBtSettings

@class Master, Slave;

typedef NS_ENUM(NSInteger, Mode);

/**
 BlueToothの設定値
 */
@interface CommScannerBtSettings : NSObject

@property enum Mode mode;

// A MSN220810A 「ストリームクローズ時のBT維持」追加 from
// false : しない（デフォルト）　true : する
@property bool keepConnectionOnStreamClose;
// A MSN220810A to

@property Master *master;

@property Slave *slave;

@end

#pragma mark CommScannerBTSettings.master

typedef NS_ENUM(NSInteger, ConnectedTo);
typedef NS_ENUM(NSInteger, TryingTime);

// CommScannerBTSettings.master関連
@interface Master : NSObject;

// マスター接続先設定
@property enum ConnectedTo connectedTo;

// 接続先Bluetoothアドレス
// Bluetoothアドレスを「0-9,A-F」の12文字の16進数文字列で指定
// マスター接続先Bluetoothアドレス
@property NSString *btAddress;

// 接続先ローカルネーム
// ローカルネームを1文字から16文字までの可変長文字列で、英数字又は記号で指定
// マスター接続先ローカルネーム
@property NSString *localName;

// 接続時PINコード
// PINコードを8桁以下の英数字又は記号で指定
// マスター接続時PINコード
@property NSString *pincode;

// 接続試行時間
@property enum TryingTime tryingTime;

@end

#pragma mark ommScannerBTSettings.slave

typedef NS_ENUM(NSInteger, WaitingTime);

// CommScannerBTSettings.slave関連
@interface Slave : NSObject;

// 接続待ち時間
@property enum WaitingTime waitingTime;

// ステルスモード(true:ステルスモード, false:通常モード)
@property bool stealth;

// 接続時PINコード
// PINコードを8桁以下の英数字又は記号で指定
// スレーブ接続時PINコード
@property NSString *pincode;


@end

#pragma mark CommScannerBTSettings.mode

// マスター・スレーブ設定
typedef NS_ENUM(NSInteger, Mode) {
    MODE_MASTER     // マスター動作
    , MODE_SLAVE    // スレーブ動作
	, MODE_AUTO     // AUTO動作
};

#pragma mark CommScannerBTSettings.ConnectedTo

// マスター接続先設定
typedef NS_ENUM(NSInteger, ConnectedTo) {
    CONNECTED_TO_BtAddress       // BTアドレスでの接続
    , CONNECTED_TO_LocalName     // ローカルネームでの接続
};

#pragma mark CommScannerBTSettings.WaitingTime

// 接続待ち時間
typedef NS_ENUM(NSInteger, WaitingTime) {
    WAITING_TIME_2MIN       // スレーブ待ち時間 2分
    , WAITING_TIME_4MIN     // スレーブ待ち時間 4分
    , WAITING_TIME_10MIN    // スレーブ待ち時間 10分
    , WAITING_TIME_30MIN    // スレーブ待ち時間 30分
	, WAITING_TIME_NONE     // タイムアウト無し
};

#pragma mark CommScannerBTSettings.TryingTime

// 接続試行時間
typedef NS_ENUM(NSInteger, TryingTime) {
	TRYING_TIME_30SEC       // マスター試行時間 30秒
	, TRYING_TIME_NONE      // タイムアウト無し
};
