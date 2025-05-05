//
//  BarcodeData.h
//  DensoScannerSDK
//
//  Created by SP1 on 2018/06/19.
//  Copyright © 2018年 SP1. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 バーコードデータ
 */
@interface BarcodeData : NSObject

@property NSInteger readStartPosition;

- (id)initWithResponse:(NSData *)response enabledMultiLineMode:(bool)enabledMultiLineMode startPosition:(NSInteger)startPosition;

- (NSString *)getSymbologyDenso;
- (NSString *)getSymbologyAim;
- (NSData *)getData;
- (NSInteger)getPrivateDataLength;

@end
