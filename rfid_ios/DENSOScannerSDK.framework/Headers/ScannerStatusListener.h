//
//  ScannerStatusListener.h
//  DensoScannerSDK
//
//  Created by SP1 on 2018/07/04.
//  Copyright © 2018年 SP1. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CommScanner, CommStatusChangedEvent;

/**
 ステータスリスナー
 */
@protocol ScannerStatusListener <NSObject>

/**
 Bluetooth接続状態変更通知

 @param scanner スキャナ
 @param state 新しいBluetooth接続状態
 */
- (void)OnScannerStatusChanged:(CommScanner *)scanner state:(CommStatusChangedEvent *)state NS_SWIFT_NAME(OnScannerStatusChanged(scanner:state:));

@end
