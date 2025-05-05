//
//  BarcodeScanner.h
//  DensoScannerSDK
//
//  Created by SP1 on 2018/05/08.
//  Copyright © 2018年 SP1. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BarcodeScannerSettings, CommScanner, SDKCommon;
@protocol BarcodeDataDelegate;

/**
 バーコードスキャナ
 */
@interface BarcodeScanner : NSObject

/// 共通クラス
@property CommScanner *commonScanner;

/// バーコードデータデリゲート
@property (readonly) id<BarcodeDataDelegate> barcodeDataDelegate;

/// バーコード読み取り関連設定値
@property BarcodeScannerSettings *barcodeScannerSettings;

- (void)setSdkCommon:(SDKCommon *)sdkCommon;
- (SDKCommon *)getSdkCommon;

- (void)setDataDelegate:(id<BarcodeDataDelegate>)delegate NS_SWIFT_NAME(setDataDelegate(delegate:));

- (void)openReader:(NSError **)error;
- (void)closeReader:(NSError **)error;

- (void)setSettings:(BarcodeScannerSettings *)settings error:(NSError **)error;
- (BarcodeScannerSettings *)getSettings:(NSError **)error NS_SWIFT_NOTHROW;

@end


