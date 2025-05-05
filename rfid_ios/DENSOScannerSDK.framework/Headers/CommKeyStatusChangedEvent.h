//
//  CommKeyStatusChangedEvent.h
//  DensoScannerSDK
//
//  Created by SP1 on 2019/05/08.
//  Copyright © 2019年 SP1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DensoScannerSDK/CommConst.h>

/**
 スキャナのキー状態受信イベント
 */
@interface CommKeyStatusChangedEvent : NSObject

- (id)initWithKeyName:(ScannerKeyName)keyName keyStatus:(ScannerKeyStatus)keyStatus;
- (ScannerKeyName)getKeyName;
- (ScannerKeyStatus)getKeyStatus;

@end
