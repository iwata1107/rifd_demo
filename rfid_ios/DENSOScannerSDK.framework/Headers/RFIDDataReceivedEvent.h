//
//  RFIDReceivedEvent.h
//  DensoScannerSDK
//
//  Created by SP1 on 2018/05/22.
//  Copyright © 2018年 SP1. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RFIDData;

/**
 RFIDデータ受信イベント
 */
@interface RFIDDataReceivedEvent : NSObject

- (id)initWithRFIDDataList:(NSArray<RFIDData *> *)list;
- (NSArray<RFIDData *> *)getRFIDData;

@end
