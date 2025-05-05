//
//  ScannerAcceptStatusListener.h
//  DensoScannerSDK
//
//  Created by SP1 on 2018/07/20.
//  Copyright © 2018年 SP1. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CommScanner;

/**
 スキャナから接続されたときに通知するイベントリスナー
 */
@protocol ScannerAcceptStatusListener <NSObject>

/**
 CommManager#addAcceptStatusListenerにて待ち受けを開始し、スキャナから接続されたときに通知するイベントハンドラ。
 本イベントハンドラは、ScannerAcceptStatusListenerをオーバーライドし、addAcceptStatusListenerでリスナー登録したインスタンスに通知されます。

 @param scanner 接続された、スキャナクラスのインスタンス
 */
- (void)OnScannerAppeared:(CommScanner *)scanner NS_SWIFT_NAME(OnScannerAppeared(scanner:));

@end
