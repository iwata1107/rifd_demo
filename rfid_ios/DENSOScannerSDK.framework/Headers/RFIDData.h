//
//  RFIDData.h
//  DensoScannerSDK
//
//  Created by SP1 on 2018/05/22.
//  Copyright © 2018年 SP1. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark RFIDData

typedef NS_ENUM(NSInteger, RFIDResult);

/**
 RFIDデータ
 */
@interface RFIDData : NSObject

- (id)initWithBinary:(NSData *)response resIndex:(bool)resIndex resPc:(bool)resPc resRssi:(bool)resRssi resAntenna:(bool)resAntenna resPolarization:(bool)resPolarization resCh:(bool)resCh resPhase:(bool)resPhase resAutoLinkProfile:(bool)resAutoLinkProfile;
- (id)initWithASCII:(NSString *)response resPc:(bool)resPc resRssi:(bool)resRssi resAntenna:(bool)resAntenna resPolarization:(bool)resPolarization;
- (NSInteger)getIndex;
- (NSData *)getUII;
- (NSInteger)getPC;
- (NSInteger)getRSSI;
- (NSInteger)getAntenna;
- (SignedByte)getPolarization;
- (RFIDResult)getResult;
- (NSData *)getData;
- (SignedByte)getCh;
- (SignedByte)getPhase;
- (NSInteger)getAutoLinkProfile;

@end

#pragma mark RFIDData::RFIDResult

/**
 RFタグ通信結果
 RFIDData::RFIDResult
 
 - RFID_RESULT_OK: 正常終了
 - RFID_RESULT_ERROR_MEM_RANGE: メモリ範囲外アクセスエラー
 - RFID_RESULT_ERROR_LOCK_MEM_ACCESS: ロックメモリへのアクセスエラー
 - RFID_RESULT_ERROR_LACK_OF_POWER: メモリライト電力不足
 - RFID_RESULT_ERROR_OTHER: その他エラー
 */
typedef NS_ENUM(NSInteger, RFIDResult) {
    RFID_RESULT_OK
    , RFID_RESULT_ERROR_MEM_RANGE
    , RFID_RESULT_ERROR_LOCK_MEM_ACCESS
    , RFID_RESULT_ERROR_LACK_OF_POWER
    , RFID_RESULT_ERROR_OTHER
};
