//
//  RFIDScannerFilter.h
//  DensoScannerSDK
//
//  Created by SP1 on 2018/05/24.
//  Copyright © 2018年 SP1. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark RFIDScannerFilter

typedef NS_ENUM(NSInteger, RFIDLogicalOpe);
typedef NS_ENUM(NSInteger, Bank);

/**
 Filter制御関連設定値
 */
@interface RFIDScannerFilter : NSObject

/// バンク指定
@property enum Bank bank;

/// ビットオフセット(0x0000000〜0x0007FFFF)
@property long bitOffset;

/// 有効ビット長(0x01~0xFF)
@property short bitLength;

/// フィルタデータ(最大256bit)
@property NSArray *filterData;

@end

#pragma mark RFIDScannerFilter::RFIDLogicalOpe

/**
 フィルターの複合条件
 RFIDScannerFilter::RFIDLogicalOpe
 
 - RFID_LOGICAL_OPE_AND: AND
 - RFID_LOGICAL_OPE_OR: OR
 */
typedef NS_ENUM(NSInteger, RFIDLogicalOpe) {
    RFID_LOGICAL_OPE_AND NS_SWIFT_NAME(RFID_LOGICAL_OPE_AND)
    , RFID_LOGICAL_OPE_OR NS_SWIFT_NAME(RFID_LOGICAL_OPE_OR)
};

#pragma mark RFIDScannerFilter.bank

/**
 バンク指定
 RFIDScannerFilter.bank
 
 - BANK_UII: UII bank
 - BANK_TID: TID bank
 - BANK_USER: USER bank
 */
typedef NS_ENUM(NSInteger, Bank) {
    BANK_UII
    , BANK_TID
    , BANK_USER
};
