//
//  RFIDScannerAutoLinkProfileSettings.h
//  DensoScannerSDK
//
//  Created by user on 2021/06/01.
//  Copyright © 2021 SP1. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark RFIDScannerAutoLinkProfileSettings

/**
 RFID AutoLinkProfile関連
 */
@interface RFIDScannerAutoLinkProfileSettings : NSObject

/// LinkProfileSequence 値 (Int型)
@property int sequence;

/// minimum Q値 (Int型)
@property int minQ;

/// max Q値 (Int型)
@property int maxQ;

@end
