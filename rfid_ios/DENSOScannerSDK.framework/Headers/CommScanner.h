//
//  CommScanner.h
//  DensoScannerSDK
//
//  Created by SP1 on 2018/05/08.
//  Copyright © 2018年 SP1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DensoScannerSDK/CommConst.h>

@import ExternalAccessory;

@class CommScannerParams, RFIDScanner, BarcodeScanner, ResponceDto, CommScannerBtSettings;
@protocol ScannerStatusListener;
@protocol ScannerKeyStatusListener;

/**
 * 共通クラス
 */
@interface CommScanner : NSObject

@property CommScannerParams *commScannerParams;

@property EAAccessory *accessory;

@property (readonly) NSArray<id<ScannerStatusListener>> *statusListener;

- (void)write:(NSString *)command;

- (void)addStatusListener:(id<ScannerStatusListener>)listener;
- (void)removeStatusListener:(id<ScannerStatusListener>)listener;
- (void)addKeyStatusListener:(id<ScannerKeyStatusListener>)listener NS_SWIFT_NAME(addKeyStatusListener(listener:));
- (void)removeKeyStatusListener:(id<ScannerKeyStatusListener>)listener NS_SWIFT_NAME(removeKeyStatusListener(listener:));

- (ScannerKeyStatus)getCurrentKeyStatus:(ScannerKeyName)name error:(NSError **)error;
- (NSString *)getSerialNum;
- (NSString *)getPartNum;
- (CommBattery)getRemainingBattery:(NSError **)error;
- (NSString *)getVersion;
- (void)claim:(NSError **)error;
- (void)close:(NSError **)error;
- (void)setParams:(CommScannerParams *)params error:(NSError **)error;
- (void)saveParams:(NSError **)error;
- (CommScannerParams *)getParams:(NSError **)error NS_SWIFT_NOTHROW;
- (RFIDScanner *)getRFIDScanner;
- (BarcodeScanner *)getBarcodeScanner;
- (NSString *)getModel;
- (void)buzzer:(CommBuzzerType)b_type error:(NSError **)error;
- (void)setLED:(CommLEDType)led_type color:(CommLEDColor)color error:(NSError **)error;
- (NSString *)getBTAddress;
- (NSString *)getBTLocalName;
- (void)setBtSettings:(CommScannerBtSettings *)bt_settings error:(NSError **)error;
- (CommScannerBtSettings *)getBtSettings:(NSError **) error NS_SWIFT_NOTHROW;
- (CommScannerType)getType;
- (void)upgradeFirmware:(NSInputStream *)upgrade_stream error:(NSError **)error;
- (void)init:(CommInitType)init_type error:(NSError **)error;
- (NSString *)getRegion;


@end
