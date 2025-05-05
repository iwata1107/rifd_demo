//
//  ResponceDto.h
//  DensoScannerSDK
//
//  Created by SP1 on 2018/05/08.
//  Copyright © 2018年 SP1. All rights reserved.
//


#import <Foundation/Foundation.h>

/**
 レスポンス格納用のDto
 */
@interface ResponceDto : NSObject

/// レスポンス
@property NSString *responce;

@property NSData *responceBinary;

/// エラーコード
@property NSString *errorCode;

@end
