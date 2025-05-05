//
//  CommStatusChangedEvent.h
//  DensoScannerSDK
//
//  Created by SP1 on 2018/07/04.
//  Copyright © 2018年 SP1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DensoScannerSDK/CommConst.h>

/**
 スキャナのステータス受信イベント
 */
@interface CommStatusChangedEvent : NSObject

- (id)initWithStatus:(ScannerStatus)status;
- (ScannerStatus)getStatus;

@end
