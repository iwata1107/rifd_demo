//
//  CommManager.h
//  DensoScannerSDK
//
//  Created by SP1 on 2018/05/17.
//  Copyright © 2018年 SP1. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CommScanner;
@protocol ScannerAcceptStatusListener;

/**
 共通マネージャー
 */
@interface CommManager : NSObject

+ (instancetype)sharedInstance;

- (void)addAcceptStatusListener:(id<ScannerAcceptStatusListener>)listener NS_SWIFT_NAME(addAcceptStatusListener(listener:));
- (void)removeAcceptStatusListener:(id<ScannerAcceptStatusListener>)listener NS_SWIFT_NAME(removeAcceptStatusListener(listener:));

+ (NSArray<CommScanner *> *)getScanners;

- (void)startAccept;
- (void)endAccept;

@end
