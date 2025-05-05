//
//  RFIDScannerResponse.h
//  DensoScannerSDK
//
//  Created by user on 2019/06/12.
//  Copyright © 2019 SP1. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, Format);
@interface RFIDScannerResponse : NSObject
// フォーマット情報付加
@property  Format format;
// PC情報付加
@property  bool pc;
// RSSI情報付加
@property  bool rssi;
// アンテナ情報付加
@property  bool antenna;
// 偏波情報付加
@property  bool polarization;
// 周波数情報付加
@property  bool ch;
// 位相情報付加
@property  bool phase;
// DLP情報(autoLinkProfile)付加
@property  bool autolinkprofile;
@end
// フォーマット
typedef NS_ENUM(NSInteger, Format) {
    FORMAT_BINARY  // バイナリモード
    , FORMAT_TEXT  // テキストモード
};


