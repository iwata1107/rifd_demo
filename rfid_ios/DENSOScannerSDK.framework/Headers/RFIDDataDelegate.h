//
//  RFIDDataDelegate.h
//  DensoScannerSDK
//
//  Created by SP1 on 2018/05/08.
//  Copyright © 2018年 SP1. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CommScanner, RFIDDataReceivedEvent;

/**
 RFIDデータデリゲート
 */
@protocol RFIDDataDelegate <NSObject>

/**
 RFIDデータ受信
 
 @param scanner スキャナ
 @param rfidEvent RFIDデータ受信イベント
 */
- (void)OnRFIDDataReceived:(CommScanner *)scanner rfidEvent:(RFIDDataReceivedEvent *)rfidEvent NS_SWIFT_NAME(OnRFIDDataReceived(scanner:rfidEvent:));

@end
