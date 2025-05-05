//
//  RFIDConst.h
//  DensoScannerSDK
//
//  Created by SP1 on 2019/11/18.
//  Copyright © 2019 SP1. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 LED色の種類
 CommConst::RFIDColor
 
 - RFID_COLOR_NONE: 無し
 - RFID_COLOR_WHITE: 白
 - RFID_COLOR_BLACK: 黒
 */
typedef NS_ENUM(NSInteger, RFIDColor) {
    RFID_COLOR_NONE NS_SWIFT_NAME(RFID_COLOR_NONE)
    , RFID_COLOR_WHITE NS_SWIFT_NAME(RFID_COLOR_WHITE)
    , RFID_COLOR_BLACK NS_SWIFT_NAME(RFID_COLOR_BLACK)
};
