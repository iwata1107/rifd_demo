//
//  EPDBitmap.h
//  DensoScannerSDK
//
//  Created by SP1 on 2019/11/18.
//  Copyright © 2019 SP1. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EPDBitmap  : NSObject
// 画像水平サイズ
@property  int width;
// 画像垂直サイズ
@property  int height;
// 画像データ
@property  NSData* data;

@end
