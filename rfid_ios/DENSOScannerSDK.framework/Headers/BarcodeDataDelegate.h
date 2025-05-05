//
//  BarcodeDataDelegate.h
//  DensoScannerSDK
//
//  Created by SP1 on 2018/06/22.
//  Copyright © 2018年 SP1. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CommScanner, BarcodeDataReceivedEvent;

/**
 バーコードデータデリゲート
 */
@protocol BarcodeDataDelegate <NSObject>

/**
 バーコードデータ受信

 @param scanner スキャナ
 @param barcodeEvent バーコードデータ受信イベント
 */
- (void)OnBarcodeDataReceived:(CommScanner *)scanner barcodeEvent:(BarcodeDataReceivedEvent *)barcodeEvent NS_SWIFT_NAME(OnBarcodeDataReceived(scanner:barcodeEvent:));

@end
