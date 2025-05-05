//
//  EPD.h
//  DensoScannerSDK
//
//  Created by SP1 on 2019/11/18.
//  Copyright © 2019 SP1. All rights reserved.
//

#import <DENSOScannerSDK/RFIDScanner.h>
#import <DENSOScannerSDK/EPDBitmap.h>
#import <DENSOScannerSDK/RFIDConst.h>

@interface EPD : NSObject


// RFIDスキャナ
@property  RFIDScanner *rfidScanner;

// SDKにおける共通処理
- (void)setSdkCommon:(SDKCommon *)sdkCommon;
- (SDKCommon *)getSdkCommon;

- (void)createWorkPanel:(int) width height: (int) height color:(RFIDColor) color error:(NSError **)error;
- (void)editWorkPanel:(int) x y:(int) y width:(int) width height: (int) height color:(RFIDColor) color data:(NSData*)data error:(NSError **)error;
- (void)savePanel:(int) index error: (NSError **)error;
- (void)loadPanel:(int) index error: (NSError **)error;
- (void)downloadPanel:(int) index width:(int) width height: (int) height data:(NSData*)data error: (NSError **)error;
- (EPDBitmap *)uploadPanel:(int) index error: (NSError **)error NS_SWIFT_NOTHROW;

- (EPDBitmap *)splitEPDBitmapResponse:(NSString*)response responseBinary:(NSData*)responseBinary error:(NSError **)error;

- (void)writeEpaper:(int) type pwd:(NSData*)pwd uii:(NSData*)uii timeout:(long)timeout  error:(NSError **)error;

@end
