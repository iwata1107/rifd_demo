//
//  DensoScannerSDK.h
//  DensoScannerSDK
//
//  Created by SP1 on 2018/06/29.
//  Copyright © 2018年 SP1. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for DensoScannerSDK.
FOUNDATION_EXPORT double DensoScannerSDKVersionNumber;

//! Project version string for DensoScannerSDK.
FOUNDATION_EXPORT const unsigned char DensoScannerSDKVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <DensoScannerSDK/PublicHeader.h>
// ここに公開用のヘッダーを記載する際、アプリ側プロジェクトで参照できるよう Build Phases > Headers > Public にヘッダーファイルを指定する必要がある。
// また、ヘッダーの記述にプロジェクトのフォルダ階層は含めない。例えば、Framework/Group/Foo.h をインポートするときは、#import <Framework/Foo.h> と記載する。
#import <DensoScannerSDK/BarcodeData.h>
#import <DensoScannerSDK/BarcodeDataReceivedEvent.h>
#import <DensoScannerSDK/BarcodeScanner.h>

#import <DensoScannerSDK/CommManager.h>
#import <DensoScannerSDK/CommScanner.h>
#import <DensoScannerSDK/CommStatusChangedEvent.h>
#import <DensoScannerSDK/CommKeyStatusChangedEvent.h>

#import <DensoScannerSDK/CommConst.h>

#import <DensoScannerSDK/ErrorCode.h>

#import <DensoScannerSDK/CommScannerBtSettings.h>
#import <DensoScannerSDK/BarcodeScannerSettings.h>
#import <DensoScannerSDK/CommScannerParams.h>
#import <DensoScannerSDK/ResponceDto.h>
#import <DensoScannerSDK/RFIDScannerFilter.h>
#import <DensoScannerSDK/RFIDScannerSettings.h>
#import <DensoScannerSDK/RFIDScannerAutoLinkProfileSettings.h>

#import <DensoScannerSDK/BarcodeDataDelegate.h>
#import <DensoScannerSDK/RFIDDataDelegate.h>
#import <DensoScannerSDK/ScannerAcceptStatusListener.h>
#import <DensoScannerSDK/ScannerStatusListener.h>
#import <DensoScannerSDK/ScannerKeyStatusListener.h>

#import <DensoScannerSDK/RFIDData.h>
#import <DensoScannerSDK/RFIDDataReceivedEvent.h>
#import <DensoScannerSDK/RFIDScanner.h>

// 電子ペーパー対応
#import <DensoScannerSDK/EPD.h>
#import <DensoScannerSDK/RFIDConst.h>
#import <DensoScannerSDK/EPDBitmap.h>
