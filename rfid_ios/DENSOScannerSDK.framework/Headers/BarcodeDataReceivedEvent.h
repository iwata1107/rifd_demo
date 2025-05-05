//
//  BarcodeDataReceivedEvent.h
//  DensoScannerSDK
//
//  Created by SP1 on 2018/06/19.
//  Copyright © 2018年 SP1. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BarcodeData;

/**
 バーコードデータ受信イベント
 */
@interface BarcodeDataReceivedEvent : NSObject

- (id)initWithBarcodeDataList:(NSArray<BarcodeData *> *)list;
- (NSArray<BarcodeData *> *)getBarcodeData;

@end
