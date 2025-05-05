//
//  RFIDScanner.h
//  DensoScannerSDK
//
//  Created by SP1 on 2018/05/08.
//  Copyright © 2018年 SP1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DensoScannerSDK/ErrorCode.h>
#import <DensoScannerSDK/RFIDScannerFilter.h>
#import <DensoScannerSDK/RFIDScannerSettings.h>
#import <DensoScannerSDK/RFIDScannerResponse.h>
#import <DensoScannerSDK/RFIDScannerAutoLinkProfileSettings.h>

#pragma mark RFIDScanner

@class CommScanner, EPD,RFIDScannerSettings, SDKCommon, TagResponse;
@protocol RFIDDataDelegate;

/**
 RFIDスキャナ
 */
@interface RFIDScanner : NSObject

/// 共通クラス
@property CommScanner *commonScanner;

/// EPD電子ペーパー用クラス
@property EPD *epd;

/// RFIDデータデリゲート
@property(readonly) id<RFIDDataDelegate> rfidDataDelegate;

/// RFID読み取り関連設定値
@property RFIDScannerSettings *rfidScannerSettings;

/// Filter制御関連設定値
@property NSArray<RFIDScannerFilter *> *rfidScannerFilter;

/// RFタグ通信結果
@property TagResponse *getTagResponse;

/// Index有無
@property bool responseIndex;

/// PC転送
@property bool responsePc;

/// RSSI転送
@property bool responseRssi;

/// 取得アンテナ情報転送
@property bool responseAntenna;

/// 偏波情報転送
@property bool responsePolarization;

/// 周波数情報転送
@property bool responseCh;

/// 位相差情報転送
@property bool responsePhase;

/// DLP情報(autoLinkProfile)転送
@property bool responseAutoLinkProfile;

/// RFID AutoLinkProfile関連設定値
@property RFIDScannerAutoLinkProfileSettings *rfidScannerAutoLinkProfileSettings;

/// AutoLinkProfile動作 有効/無効 (Scanner設定)
@property bool isAutoLinkProfileActive;

- (void)setSdkCommon:(SDKCommon *)sdkCommon;
- (void)setRFIDScanMode:(NSError **)error;
- (SDKCommon *)getSdkCommon;
- (bool)command:(NSString *)command;

- (void)setDataDelegate:(id<RFIDDataDelegate>)delegate NS_SWIFT_NAME(setDataDelegate(delegate:));
- (void)setSettings:(RFIDScannerSettings *)settings error:(NSError **)error;
- (void)openInventory:(NSError **)error;
- (void)openInventory:(int)index error:(NSError **)error;
- (void)openRead:(RFIDBank)bank addr:(short)addr size:(short)size pwd:(NSData *)pwd UII:(NSData *)UII error:(NSError **)error;
- (void)openRead:(RFIDBank)bank addr:(short)addr size:(short)size pwd:(NSData *)pwd error:(NSError **)error;
- (void)openRead:(RFIDBank)bank addr:(short)addr size:(short)size pwd:(NSData *)pwd index:(int)index error:(NSError **)error;
- (void)close:(NSError **)error;
- (void)writeOneTag:(RFIDBank)bank addr:(short)addr size:(short)size pwd:(NSData *)pwd data:(NSData *)data UII:(NSData *)UII timeout:(long)timeout error:(NSError **)error;
- (void)lockOneTag:(Byte)target type:(RFIDLock)type pwd:(NSData *)pwd UII:(NSData *)UII timeout:(long)timeout error:(NSError **)error;
- (void)killOneTag:(NSData *)pwd UII:(NSData *)UII timeout:(long)timeout error:(NSError **)error;
- (void)setFilter:(NSArray<RFIDScannerFilter *> *)filter l_ope:(RFIDLogicalOpe)l_ope error:(NSError **)error;
- (void)clearFilter:(NSError **)error;
- (RFIDScannerSettings *)getSettings:(NSError **)error NS_SWIFT_NOTHROW;
- (int)getCount:(int)index error:(NSError **)error;
- (void)pullData:(int)index error:(NSError **)error;
- (void)clearDoubleReadingBuffer:(NSError **)error;
- (void)setResponse:(RFIDScannerResponse *)response error:(NSError **)error;
- (RFIDScannerResponse *)getResponse:(NSError **)error NS_SWIFT_NOTHROW;
- (EPD *)getEPD;
- (void)setAutoLinkProfile:(bool)useAutoLinkProfile error:(NSError **)error;
- (bool)getAutoLinkProfile:(NSError **)error NS_SWIFT_NOTHROW;
- (void)setAutoLinkProfileSettings:(RFIDScannerAutoLinkProfileSettings *)settings error:(NSError **)error;
- (RFIDScannerAutoLinkProfileSettings *)getAutoLinkProfileSettings:(NSError **)error NS_SWIFT_NOTHROW;



@end

#pragma mark RFIDScanner.getTagResponse

@interface TagResponse : NSObject

@property ErrorCode errorCode;

- (id)initWithErrorCode:(ErrorCode)errorCode;

@end
