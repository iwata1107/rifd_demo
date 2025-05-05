//
//  ScannerKeyStatusListener.h
//  DensoScannerSDK
//
//  Created by SP1 on 2019/05/08.
//  Copyright © 2019年 SP1. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CommScanner, CommKeyStatusChangedEvent;

/**
 キーステータスリスナー
 */
@protocol ScannerKeyStatusListener <NSObject>

/**
 トリガ状態変更通知
 
 @param scanner スキャナ
 @param event トリガ状態変更イベント
 */
- (void)OnScannerKeyStatusChanged:(CommScanner * )scanner event:(CommKeyStatusChangedEvent *)event NS_SWIFT_NAME(OnScannerKeyStatusChanged(scanner:event:));

@end
