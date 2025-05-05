//
//  BarcodeScannerSettings.h
//  DensoScannerSDK
//
//  Created by SP1 on 2018/06/18.
//  Copyright © 2018年 SP1. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark BarcodeScannerSettings

@class BarcodeScan, Decode, Editing, PowerOffDelay;

/**
 バーコード読み取り関連設定値
 */
@interface BarcodeScannerSettings : NSObject

/// バーコード読み取り動作関連設定値
@property BarcodeScan *scan;

/// デコード関連設定値
@property Decode *decode;

/// バーコードから読み取ったデータの編集関連設定値
@property Editing *editing;

/// バーコードスキャナモジュールを電源OFFするまでの時間
@property PowerOffDelay *powerOffDelay;

@end

#pragma mark BarcodeScannerSettings.scan

typedef NS_ENUM(NSInteger, BarcodeScannerSettingsTriggerMode);
typedef NS_ENUM(NSInteger, LightMode);
typedef NS_ENUM(NSInteger, MarkerMode);
typedef NS_ENUM(NSInteger, SideLightMode);

/**
 バーコード読み取り動作関連設定値
 BarcodeScannerSettings.scan
 */
@interface BarcodeScan : NSObject

/// トリガモード
@property enum BarcodeScannerSettingsTriggerMode triggerMode;

/// 照明モード
@property enum LightMode lightMode;

/// マーカモード
@property enum MarkerMode markerMode;

/// 補助照明
@property enum SideLightMode sideLightMode;

@end

#pragma mark BarcodeScannerSettings.scan.triggerMode

/**
 トリガモード（バーコード）
 BarcodeScannerSettings.scan.triggerMode
 
 - BARCODE_TRIGGER_MODE_AUTO_OFF: オートオフモード
 - BARCODE_TRIGGER_MODE_MOMENTARY: モメンタリモード
 - BARCODE_TRIGGER_MODE_ALTERNATE: オルタネートモード
 - BARCODE_TRIGGER_MODE_CONTINUOUS: 連続読み取りモード
 - BARCODE_TRIGGER_MODE_TRIGGER_RELEASE: トリガリリースモード
 */
typedef NS_ENUM(NSInteger, BarcodeScannerSettingsTriggerMode) {
    BARCODE_TRIGGER_MODE_AUTO_OFF
    , BARCODE_TRIGGER_MODE_MOMENTARY
    , BARCODE_TRIGGER_MODE_ALTERNATE
    , BARCODE_TRIGGER_MODE_CONTINUOUS
    , BARCODE_TRIGGER_MODE_TRIGGER_RELEASE
};

#pragma mark BarcodeScannerSettings.scan.lightMode

/**
 照明モード
 BarcodeScannerSettings.scan.lightMode
 
 - LIGHT_MODE_AUTO: 自動
 - LIGHT_MODE_ALWAYS_ON: 常時ON
 - LIGHT_MODE_OFF: 消灯
 */
typedef NS_ENUM(NSInteger, LightMode) {
    LIGHT_MODE_AUTO
    , LIGHT_MODE_ALWAYS_ON
    , LIGHT_MODE_OFF
};

#pragma mark BarcodeScannerSettings.scan.markerMode

/**
 マーカモード
 BarcodeScannerSettings.scan.markerMode
 
 - MARKER_MODE_NORMAL: ノーマル
 - MARKER_MODE_AHEAD: マーカ先行
 - MARKER_MODE_OFF: マーカ無し
 */
typedef NS_ENUM(NSInteger, MarkerMode) {
    MARKER_MODE_NORMAL
    , MARKER_MODE_AHEAD
    , MARKER_MODE_OFF
};

#pragma mark BarcodeScannerSettings.scan.sideLightMode

/**
 補助照明
 BarcodeScannerSettings.scan.sideLightMode
 
 - SIDE_LIGHT_MODE_ON: ON
 - SIDE_LIGHT_MODE_OFF: OFF
 */
typedef NS_ENUM(NSInteger, SideLightMode) {
    SIDE_LIGHT_MODE_ON
    , SIDE_LIGHT_MODE_OFF
};

#pragma mark BarcodeScannerSettings.decode

@class MultiLineMode, Symbologies;
typedef NS_ENUM(NSInteger, InvertMode);
typedef NS_ENUM(NSInteger, PointScanMode);
typedef NS_ENUM(NSInteger, ReverseMode);
typedef NS_ENUM(NSInteger, MirrorReflection);

/**
 デコード関連設定値
 BarcodeScannerSettings.decode
 */
@interface Decode : NSObject

/// 二度読み防止解除時間  *防止解除時間(x100ms)
@property short sameBarcodeIntervalTime;

/// 白黒反転読取
@property enum InvertMode invertMode;

/// デコードレベル  *レベル 1～9
@property short decodeLevel;

/// ITF最小桁数 最小桁数(2～20)
@property short lengthMinItfParam;

/// STF最小桁数 最小桁数(1～20)
@property short lengthMinStfParam;

/// Codabar最小桁数(3～20)
@property short lengthMinCodabarParam;

/// ポイントスキャンモード
@property enum PointScanMode pointScanMode;

/// 表裏反転読取
@property ReverseMode reverseMode;

/// バーコードのencoding方式(charset指定文字列)
@property NSString *charset;

/// 鏡面反射読取
@property enum MirrorReflection mirrorReflection;

/// 多段コード読み取り関連設定値
@property MultiLineMode *multiLineMode;

/// 読み取り許可コード関連設定値
@property Symbologies *symbologies;

@end

#pragma mark BarcodeScannerSettings.decode.multiLineMode

@class Symbology;

/**
 多段コード読み取り関連設定値
 BarcodeScannerSettings.decode.multiLineMode
 */
@interface MultiLineMode : NSObject

/// 多段読取 [true:許可 false:禁止]
@property bool enabled;

/// コード種
@property Symbology *symbology1st;
@property Symbology *symbology2nd;
@property Symbology *symbology3rd;

@end

#pragma mark BarcodeScannerSettings.decode.multiLineMode.symbology1st/2nd/3rd

typedef NS_ENUM(NSInteger, MultiLineSymbologyType);

/**
 1段目/2段目/3段目の読取コード情報
 BarcodeScannerSettings.decode.multiLineMode.symbology1st/2nd/3rd
 */
@interface Symbology : NSObject

/// 多段読取 [true:許可 false:禁止]
@property enum MultiLineSymbologyType symbologyType;

/// 1桁目の文字(コード種が POS の場合のみ有効)
/// ""(空文字列) : 限定しない, "?" : 限定しない, "0" ～ "9" : 読取可能なラベルの1桁目の文字
@property NSString *firstCharacter;

/// 2桁目の文字(コード種が POS の場合のみ有効)
/// ""(空文字列) : 限定しない, "?" : 限定しない, "0" ～ "9" : 読取可能なラベルの2桁目の文字
@property NSString *secondCharacter;

/// スタート/ストップキャラクタ(コード種が Codabar の場合のみ有効)
/// 指定されたスタート/ストップキャラクタを持つラベルのみ読み取り可能
/// ""(空文字列) : スタートストップを限定しない
/// スタートキャラクタとストップキャラクタを連結させた文字列 [ ex) "AA", "AB" ]
/// "?"を指定すると、スタート/ストップ のいずれか一方のみ指定可能 [ ex) "A?", "?D" ]
@property NSString *startStopCharacter;

/// 最小桁数(コード種が POS 以外の場合のみ有効)
/// 0 : 最小桁数指定なし, 2～99(ITF,STFの場合), 3～99(Codabarの場合), 1～99(ITF,Codabar以外の場合)
@property short lengthMin;

/// 最大桁数(コード種が POS 以外の場合のみ有効)
/// 0 : 最大桁数指定なし, 2～99(ITFの場合), 3～99(Codabarの場合), 1～99(ITF,Codabar以外の場合)
@property short lengthMax;

/// チェックデジット検証(コード種が POS,Code39,Code93 以外の場合のみ有効)
/// true : 有効, false : 無効
@property bool verifyCheckDigit;

@end

#pragma mark BarcodeScannerSettings.decode.multiLineMode.symbology1st/2nd/3rd.symbologyType

/**
 コード種
 BarcodeScannerSettings.decode.multiLineMode.symbology1st/2nd/3rd.symbologyType
 
 - MULTILINE_SYMBOLOGY_TYPE_NONE: 未指定(読取禁止)
 - MULTILINE_SYMBOLOGY_TYPE_EAN13UPCA: EAN13/UPC-A
 - MULTILINE_SYMBOLOGY_TYPE_EAN8: EAN-8
 - MULTILINE_SYMBOLOGY_TYPE_UPCE: UPC-E
 - MULTILINE_SYMBOLOGY_TYPE_INTERLEAVED2OF5: インターリーブド 2of5(ITF)
 - MULTILINE_SYMBOLOGY_TYPE_STANDARD2OF5: スタンダード 2of5(STF)
 - MULTILINE_SYMBOLOGY_TYPE_CODABAR: CODABAR(NW-7)
 - MULTILINE_SYMBOLOGY_TYPE_CODE39: CODE-39
 - MULTILINE_SYMBOLOGY_TYPE_CODE93: CODE-93
 - MULTILINE_SYMBOLOGY_TYPE_CODE128: CODE128
 */
typedef NS_ENUM(NSInteger, MultiLineSymbologyType) {
    MULTILINE_SYMBOLOGY_TYPE_NONE
    , MULTILINE_SYMBOLOGY_TYPE_EAN13UPCA
    , MULTILINE_SYMBOLOGY_TYPE_EAN8
    , MULTILINE_SYMBOLOGY_TYPE_UPCE
    , MULTILINE_SYMBOLOGY_TYPE_INTERLEAVED2OF5
    , MULTILINE_SYMBOLOGY_TYPE_STANDARD2OF5
    , MULTILINE_SYMBOLOGY_TYPE_CODABAR
    , MULTILINE_SYMBOLOGY_TYPE_CODE39
    , MULTILINE_SYMBOLOGY_TYPE_CODE93
    , MULTILINE_SYMBOLOGY_TYPE_CODE128
};

#pragma mark BarcodeScannerSettings.decode.symbologies

@class Ean13UpcA, DecodeEan8, DecodeUpcE, DecodeItf, DecodeStf, DecodeCodabar, DecodeCode39, Code93, Code128, Msi, Gs1DataBar, Gs1DataBarLimited, Gs1DataBarExpanded, GS1Composite, QrCode, MicroQr, SQRC, IqrCode, DataMatrix, Pdf417, MicroPdf417, MaxiCode, Plessey, Aztec;

/**
 読み取り許可コード関連設定値
 BarcodeScannerSettings.decode.symbologies
 */
@interface Symbologies : NSObject

/// EAN-13,UPC-A関連設定値
@property Ean13UpcA *ean13upcA;

/// EAN-8関連設定値
@property DecodeEan8 *ean8;

/// UPC-E関連設定値
@property DecodeUpcE *upcE;

/// ITF関連設定値
@property DecodeItf *itf;

/// STF関連設定値
@property DecodeStf *stf;

/// Codabar関連設定値
@property DecodeCodabar *codabar;

/// Code39関連設定値
@property DecodeCode39 *code39;

/// Code93関連設定値
@property Code93 *code93;

/// Code128関連設定値
@property Code128 *code128;

/// MSI関連設定値
@property Msi *msi;

/// GS1 Databar 関連設定値
@property Gs1DataBar *gs1DataBar;

/// GS1 Databar Limited 関連設定値
@property Gs1DataBarLimited *gs1DataBarLimited;

/// GS1 Databar Expanded 関連設定値
@property Gs1DataBarExpanded *gs1DataBarExpanded;

/// GS1 Composite 関連設定値
@property GS1Composite *gs1Composite;

/// QRコード関連設定値
@property QrCode *qrCode;

/// Micro QRコード 関連設定値
@property MicroQr *microQr;

/// SQRC 関連設定値
@property SQRC *sqrc;

/// IQRコード関連設定値
@property IqrCode *iqrCode;

/// Data Matrix コード関連設定値
@property DataMatrix *dataMatrix;

/// PDF417コード関連設定値
@property Pdf417 *pdf417;

/// Micro PDF417 コード関連設定値
@property MicroPdf417 *microPdf417;

/// Maxiコード関連設定値
@property MaxiCode *maxiCode;

/// Plesseyコード関連設定値
@property Plessey *plessey;

/// Aztecコード関連設定値
@property Aztec *aztec;

@end

#pragma mark BarcodeScannerSettings.decode.symbologies.ean13upcA

@class Ean13UpcAAddOn;

/**
 EAN-13,UPC-A関連設定値
 BarcodeScannerSettings.decode.symbologies.ean13upcA
 */
@interface Ean13UpcA : NSObject

/// 読取許可(true:読取許可, false:読取禁止)
@property bool enabled;

/// 1桁目の文字
/// ""(空文字列) : 限定しない, "?" : 限定しない, "0" ～ "9" : 読取可能なコードの1桁目の文字
@property NSString *firstCharacter;

/// 2桁目の文字
/// ""(空文字列) : 限定しない, "?" : 限定しない, "0" ～ "9" : 読取可能なコードの2桁目の文字
@property NSString *secondCharacter;

/// EAN-13,UPC-Aアドオン関連設定値
@property Ean13UpcAAddOn *addOn;

@end

#pragma mark BarcodeScannerSettings.decode.symbologies.ean13upcA.addOn

/**
 EAN-13,UPC-Aアドオン関連設定値
 BarcodeScannerSettings.decode.symbologies.ean13upcA.addOn
 */
@interface Ean13UpcAAddOn : NSObject

/// アドオン付き(true:読取許可, false:読取禁止)
@property bool enabled;

/// 2桁アドオン付き(true:読取許可, false:読取禁止)
@property bool addOn2Digit;

/// 5桁アドオン付き(true:読取許可, false:読取禁止)
@property bool addOn5Digit;

/// アドオン付きのみ(true:アドオン付きのみに限定する, false:アドオン付きのみに限定しない)
@property bool onlyWithAddOn;

@end

#pragma mark BarcodeScannerSettings.decode.symbologies.ean8

@class Ean8AddOn;

/**
 デコードにおけるEAN-8関連設定値
 BarcodeScannerSettings.decode.symbologies.ean8
 */
@interface DecodeEan8 : NSObject

/// 読取許可(true:読取許可, false:読取禁止)
@property bool enabled;

/// 1桁目の文字
/// ""(空文字列) : 限定しない, "?" : 限定しない, "0" ～ "9" : 読取可能なコードの1桁目の文字
@property NSString *firstCharacter;

/// 2桁目の文字
/// ""(空文字列) : 限定しない, "?" : 限定しない, "0" ～ "9" : 読取可能なコードの2桁目の文字
@property NSString *secondCharacter;

/// EAN-8アドオン関連設定値
@property Ean8AddOn *addOn;

@end

#pragma mark BarcodeScannerSettings.decode.symbologies.ean8.addOn

/**
 EAN-8アドオン関連設定値
 BarcodeScannerSettings.decode.symbologies.ean8.addOn
 */
@interface Ean8AddOn : NSObject

/// アドオン付き(true:読取許可, false:読取禁止)
@property bool enabled;

/// 2桁アドオン付き(true:読取許可, false:読取禁止)
@property bool addOn2Digit;

/// 5桁アドオン付き(true:読取許可, false:読取禁止)
@property bool addOn5Digit;

/// アドオン付きのみ(true:アドオン付きのみに限定する, false:アドオン付きのみに限定しない)
@property bool onlyWithAddOn;

@end

#pragma mark BarcodeScannerSettings.decode.symbologies.upcE

@class UpcEAddOn;

/**
 デコードにおけるUPC-E関連設定値
 BarcodeScannerSettings.decode.symbologies.upcE
 */
@interface DecodeUpcE : NSObject

/// 読取許可(true:読取許可, false:読取禁止)
@property bool enabled;

/// 1桁目の文字
/// ""(空文字列) : 限定しない, "?" : 限定しない, "0" ～ "9" : 読取可能なコードの1桁目の文字
@property NSString *firstCharacter;

// 2桁目の文字
// ""(空文字列) : 限定しない, "?" : 限定しない, "0" ～ "9" : 読取可能なコードの2桁目の文字
@property NSString *secondCharacter;

/// デコードにおけるUPC-Eアドオン関連設定値
@property UpcEAddOn *addOn;

@end

#pragma mark BarcodeScannerSettings.decode.symbologies.upcE.addOn

/**
 UPC-Eアドオン関連設定値
 BarcodeScannerSettings.decode.symbologies.upcE.addOn
 */
@interface UpcEAddOn : NSObject

/// アドオン付き(true:読取許可, false:読取禁止)
@property bool enabled;

/// 2桁アドオン付き(true:読取許可, false:読取禁止)
@property bool addOn2Digit;

/// 5桁アドオン付き(true:読取許可, false:読取禁止)
@property bool addOn5Digit;

/// アドオン付きのみ(true:アドオン付きのみに限定する, false:アドオン付きのみに限定しない)
@property bool onlyWithAddOn;

@end

#pragma mark BarcodeScannerSettings.decode.symbologies.itf

/**
 デコードにおけるITF関連設定値
 BarcodeScannerSettings.decode.symbologies.itf
 */
@interface DecodeItf : NSObject

/// 読取許可(true:読取許可, false:読取禁止)
@property bool enabled;

/// 最小桁数(2～99)
@property short lengthMin;

/// 最大桁数(2～99)
@property short lengthMax;

/// チェックデジット検証(true:有効, false:無効)
@property bool verifyCheckDigit;

@end

#pragma mark BarcodeScannerSettings.decode.symbologies.stf

/**
 デコードにおけるSTF関連設定値
 BarcodeScannerSettings.decode.symbologies.stf
 */
@interface DecodeStf : NSObject

/// 読取許可(true:読取許可, false:読取禁止)
@property bool enabled;

/// 最小桁数(2～99)
@property short lengthMin;

/// 最大桁数(2～99)
@property short lengthMax;

/// チェックデジット検証(true:有効, false:無効)
@property bool verifyCheckDigit;

/// スタート/ストップキャラクタ形式("":限定しない, "S":Short, "N":Normal)
@property NSString *startStopCharacter;

@end

#pragma mark BarcodeScannerSettings.decode.symbologies.codabar

/**
 デコードにおけるCodabar関連設定値
 BarcodeScannerSettings.decode.symbologies.codabar
 */
@interface DecodeCodabar : NSObject

/// 読取許可(true:読取許可, false:読取禁止)
@property bool enabled;

/// 最小桁数(3～99)
@property short lengthMin;

/// 最大桁数(3～99)
@property short lengthMax;

/// チェックデジット検証(true:有効, false:無効)
@property bool verifyCheckDigit;

// スタート/ストップキャラクタ(A,B,C,D,?)
// 指定されたスタート/ストップキャラクタを持つラベルのみ読取可能
// ""(空文字列) : スタート・ストップを限定しない
// スタートキャラクタとストップキャラクタを連結させた文字列 [ ex) "AA", "AB" ]
// "?"を指定すると、スタート/ストップ のいずれか一方のみ指定可能 [ ex) "A?", "?D" ]
@property NSString *startStopCharacter;

@end

#pragma mark BarcodeScannerSettings.decode.symbologies.code39

/**
 デコードにおけるCode39関連設定値
 BarcodeScannerSettings.decode.symbologies.code39
 */
@interface DecodeCode39 : NSObject

/// 読取許可(true:読取許可, false:読取禁止)
@property bool enabled;

/// 最小桁数(1～99)
@property short lengthMin;

/// 最大桁数(1～99)
@property short lengthMax;

/// チェックデジット検証(true:有効, false:無効)
@property bool verifyCheckDigit;

@end

#pragma mark BarcodeScannerSettings.decode.symbologies.code93

/**
 Code93関連設定値
 BarcodeScannerSettings.decode.symbologies.code93
 */
@interface Code93 : NSObject

/// 読取許可(true:読取許可, false:読取禁止)
@property bool enabled;

/// 最小桁数(1～99)
@property short lengthMin;

/// 最大桁数(1～99)
@property short lengthMax;

@end

#pragma mark BarcodeScannerSettings.decode.symbologies.code128

/**
 Code128関連設定値
 BarcodeScannerSettings.decode.symbologies.code128
 */
@interface Code128 : NSObject

/// 読取許可(true:読取許可, false:読取禁止)
@property bool enabled;

/// 最小桁数(1～99)
@property short lengthMin;

/// 最大桁数(1～99)
@property short lengthMax;

@end

#pragma mark BarcodeScannerSettings.decode.symbologies.msi

/**
 MSI関連設定値
 BarcodeScannerSettings.decode.symbologies.msi
 */
@interface Msi : NSObject

/// 読取許可(true:読取許可, false:読取禁止)
@property bool enabled;

/// 最小桁数(1～99)
@property short lengthMin;

/// 最大桁数(1～99)
@property short lengthMax;

/// チェックデジットに使用する桁数(1:1桁 , 2:2桁)
@property short numberOfCheckDigitVerification;

@end

#pragma mark BarcodeScannerSettings.decode.symbologies.gs1DataBar

/**
 GS1 Databar 関連設定値
 BarcodeScannerSettings.decode.symbologies.gs1DataBar
 */
@interface Gs1DataBar : NSObject

/// 読取許可(true:読取許可, false:読取禁止)
@property bool enabled;

/// スタック形式読取許可(true:読取許可, false:読取禁止)
@property bool stacked;

@end

#pragma mark BarcodeScannerSettings.decode.symbologies.gs1DataBarLimited

/**
 GS1 Databar Limited 関連設定値
 BarcodeScannerSettings.decode.symbologies.gs1DataBarLimited
 */
@interface Gs1DataBarLimited : NSObject

/// 読取許可(true:読取許可, false:読取禁止)
@property bool enabled;

@end

#pragma mark BarcodeScannerSettings.decode.symbologies.gs1DataBarExpanded

/**
 GS1 Databar Expanded 関連設定値
 BarcodeScannerSettings.decode.symbologies.gs1DataBarExpanded
 */
@interface Gs1DataBarExpanded : NSObject

/// 読取許可(true:読取許可, false:読取禁止)
@property bool enabled;

/// スタック形式読取許可(true:読取許可, false:読取禁止)
@property bool stacked;

/// 最小桁数(1～99)
@property short lengthMin;

/// 最大桁数(1～99)
@property short lengthMax;

@end

#pragma mark BarcodeScannerSettings.decode.symbologies.gs1Composite

/**
 GS1 Composite 関連設定値
 BarcodeScannerSettings.decode.symbologies.gs1Composite
 */
@interface GS1Composite : NSObject

/// 読取許可(true:読取許可, false:読取禁止)
@property bool enabled;

@end

#pragma mark BarcodeScannerSettings.decode.symbologies.qrCode

@class Model1, Model2;
typedef NS_ENUM(NSInteger, SplitModeQr);

/**
 QRコード関連設定値
 BarcodeScannerSettings.decode.symbologies.qrCode
 */
@interface QrCode : NSObject

/// 読取許可(true:読取許可, false:読取禁止)
@property bool enabled;

/// 連続読み取りモード
@property SplitModeQr splitMode;

/// QRモデル1コード関連設定値
@property Model1 *model1;

/// QRモデル2コード関連設定値
@property Model2 *model2;

@end

#pragma mark BarcodeScannerSettings.decode.symbologies.qrCode.model1

/**
 QRモデル1コード関連設定値
 BarcodeScannerSettings.decode.symbologies.qrCode.model1
 */
@interface Model1 : NSObject

/// 読取許可(true:読取許可, false:読取禁止)
@property bool enabled;

/// 最小コードバージョン(1～22)
@property short versionMin;

/// 最大コードバージョン(1～22)
@property short versionMax;

@end

#pragma mark BarcodeScannerSettings.decode.symbologies.qrCode.model2

/**
 QRモデル2コード関連設定値
 BarcodeScannerSettings.decode.symbologies.qrCode.model2
 */
@interface Model2 : NSObject

/// 読取許可(true:読取許可, false:読取禁止)
@property bool enabled;

/// 最小コードバージョン(1～40)
@property short versionMin;

/// 最大コードバージョン(1～40)
@property short versionMax;

@end

#pragma mark BarcodeScannerSettings.decode.symbologies.qrCode.splitMode

/**
 連結読取モード
 BarcodeScannerSettings.decode.symbologies.qrCode.splitMode
 
 - SPLIT_MODE_QR_DISABLED: 連結読取禁止
 - SPLIT_MODE_QR_EDIT: 編集モード
 - SPLIT_MODE_QR_NON_EDIT: 未編集モード
 */
typedef NS_ENUM(NSInteger, SplitModeQr) {
    SPLIT_MODE_QR_DISABLED
    , SPLIT_MODE_QR_EDIT
    , SPLIT_MODE_QR_BATCH_EDIT
    , SPLIT_MODE_QR_NON_EDIT
};

#pragma mark BarcodeScannerSettings.decode.symbologies.microQr

/**
 Micro QR コード関連設定値
 BarcodeScannerSettings.decode.symbologies.microQr
 */
@interface MicroQr : NSObject

/// 読取許可(true:読取許可, false:読取禁止)
@property bool enabled;

/// 最小コードバージョン(1～4)
@property short versionMin;

/// 最大コードバージョン(1～4)
@property short versionMax;

@end

#pragma mark BarcodeScannerSettings.decode.symbologies.sqrc

/**
 SQRC　コード関連設定値
 BarcodeScannerSettings.decode.symbologies.sqrc
 */
@interface SQRC : NSObject

/// 読取許可(true:読取許可, false:読取禁止)
@property bool enabled;

/// 最小コードバージョン(1～40)
@property short versionMin;

/// 最大コードバージョン(1～40)
@property short versionMax;

@end

#pragma mark BarcodeScannerSettings.decode.symbologies.iqrCode

@class IqrCodeSquare, IqrCodeRectangle;
typedef NS_ENUM(NSInteger, SplitModeIqr);

/**
 iQRコード関連設定値
 BarcodeScannerSettings.decode.symbologies.iqrCode
 */
@interface IqrCode : NSObject

/// 読取許可(true:読取許可, false:読取禁止)
@property bool enabled;

/// 連結読取モード
@property enum SplitModeIqr splitMode;

/// iQRコード(正方形)関連設定値
@property IqrCodeSquare *square;

/// iQRコード(長方形)関連設定値
@property IqrCodeRectangle *rectangle;

@end

#pragma mark BarcodeScannerSettings.decode.symbologies.iqrCode.square

/**
 iQRコード(正方形)関連設定値
 BarcodeScannerSettings.decode.symbologies.iqrCode.square
 */
@interface IqrCodeSquare : NSObject

/// 読取許可(true:読取許可, false:読取禁止)
@property bool enabled;

/// 最小コードバージョン(1～61)
@property short versionMin;

/// 最大コードバージョン(1～61)
@property short versionMax;

@end

#pragma mark BarcodeScannerSettings.decode.symbologies.iqrCode.rectangle

/**
 iQRコード(長方形)関連設定値
 BarcodeScannerSettings.decode.symbologies.iqrCode.rectangle
 */
@interface IqrCodeRectangle : NSObject

/// 読取許可(true:読取許可, false:読取禁止)
@property bool enabled;

/// 最小コードバージョン(1～15)
@property short versionMin;

/// 最大コードバージョン(1～15)
@property short versionMax;

@end

#pragma mark BarcodeScannerSettings.decode.symbologies.iqrCode.splitMode

/**
 連結読取モード
 BarcodeScannerSettings.decode.symbologies.iqrCode.splitMode
 
 - SPLIT_MODE_IQR_DISABLED: 読取禁止
 - SPLIT_MODE_IQR_EDIT: 編集モード
 - SPLIT_MODE_IQR_NON_EDIT: 未編集モード
 */
typedef NS_ENUM(NSInteger, SplitModeIqr) {
    SPLIT_MODE_IQR_DISABLED
    , SPLIT_MODE_IQR_EDIT
    , SPLIT_MODE_IQR_NON_EDIT
};

#pragma mark BarcodeScannerSettings.decode.symbologies.dataMatrix

@class DataMatrixSquare, DataMatrixRectangle;

/**
 Data Matrix コード関連設定値
 BarcodeScannerSettings.decode.symbologies.dataMatrix
 */
@interface DataMatrix : NSObject

/// 読取許可(true:読取許可, false:読取禁止)
@property bool enabled;

/// Data Matrix (正方形) コード関連設定値
@property DataMatrixSquare *square;

/// Data Matrix (長方形) コード関連設定値
@property DataMatrixRectangle *rectangle;

@end

#pragma mark BarcodeScannerSettings.decode.symbologies.dataMatrix.square

/**
 Data Matrix (正方形) コード関連設定値
 BarcodeScannerSettings.decode.symbologies.dataMatrix.square
 */
@interface DataMatrixSquare : NSObject

/// 読取許可(true:読取許可, false:読取禁止)
@property bool enabled;

/// 最小コードバージョン(1～24)
@property short codeNumberMin;

/// 最大コードバージョン(1～24)
@property short codeNumberMax;

@end

#pragma mark BarcodeScannerSettings.decode.symbologies.dataMatrix.rectangle

/**
 Data Matrix (長方形) コード関連設定値
 BarcodeScannerSettings.decode.symbologies.dataMatrix.rectangle
 */
@interface DataMatrixRectangle : NSObject

/// 読取許可(true:読取許可, false:読取禁止)
@property bool enabled;

/// 最小コード番号(1～6)
@property short codeNumberMin;

/// 最大コード番号(1～6)
@property short codeNumberMax;

@end

#pragma mark BarcodeScannerSettings.decode.symbologies.pdf417

/**
 PDF417コード関連設定値
 BarcodeScannerSettings.decode.symbologies.pdf417
 */
@interface Pdf417 : NSObject

/// 読取許可(true:読取許可, false:読取禁止)
@property bool enabled;

@end

#pragma mark BarcodeScannerSettings.decode.symbologies.microPdf417

/**
 Micro PDF417 コード関連設定値
 BarcodeScannerSettings.decode.symbologies.microPdf417
 */
@interface MicroPdf417 : NSObject

/// 読取許可(true:読取許可, false:読取禁止)
@property bool enabled;

@end

#pragma mark BarcodeScannerSettings.decode.symbologies.maxiCode

/**
 Maxiコード関連設定値
 BarcodeScannerSettings.decode.symbologies.maxiCode
 */
@interface MaxiCode : NSObject

/// 読取許可(true:読取許可, false:読取禁止)
@property bool enabled;

@end

#pragma mark BarcodeScannerSettings.decode.symbologies.plessey

/**
 Plesseyコード関連設定値
 BarcodeScannerSettings.decode.symbologies.plessey
 */
@interface Plessey : NSObject

/// 読取許可(true:読取許可, false:読取禁止)
@property bool enabled;

@end

#pragma mark BarcodeScannerSettings.decode.symbologies.aztec

/**
 Aztecコード関連設定値
 BarcodeScannerSettings.decode.symbologies.aztec
 */
@interface Aztec : NSObject

/// 読取許可(true:読取許可, false:読取禁止)
@property bool enabled;

@end

#pragma mark BarcodeScannerSettings.decode.invertMode

/**
 白黒反転読取
 BarcodeScannerSettings.decode.invertMode
 
 - INVERT_MODE_DISABLED: 禁止
 - INVERT_MODE_INVERSION_ONLY: 許可（反転のみ）
 - INVERT_MODE_AUTO: 許可（自動判別）
 */
typedef NS_ENUM(NSInteger, InvertMode) {
    INVERT_MODE_DISABLED
    , INVERT_MODE_INVERSION_ONLY
    , INVERT_MODE_AUTO
};

#pragma mark BarcodeScannerSettings.decode.pointScanMode

/**
 ポイントスキャンモード
 BarcodeScannerSettings.decode.pointScanMode
 
 - POINT_SCAN_MODE_DISABLED: 禁止
 - POINT_SCAN_MODE_ENABLED: 許可
 */
typedef NS_ENUM(NSInteger, PointScanMode) {
    POINT_SCAN_MODE_DISABLED
    , POINT_SCAN_MODE_ENABLED
};

#pragma mark BarcodeScannerSettings.decode.reverseMode

/**
 表裏反転読取
 BarcodeScannerSettings.decode.reverseMode
 
 - REVERSE_MODE_DISABLED: 禁止
 - REVERSE_MODE_ENABLED: 許可
 */
typedef NS_ENUM(NSInteger, ReverseMode) {
    REVERSE_MODE_DISABLED
    , REVERSE_MODE_ENABLED
};

#pragma mark BarcodeScannerSettings.decode.mirrorReflection

/**
 鏡面反射読取
 BarcodeScannerSettings.decode.mirrorReflection
 
 - MIRROR_REFLECTION_DISABLED: 禁止
 - MIRROR_REFLECTION_ENABLED: 許可
 */
typedef NS_ENUM(NSInteger, MirrorReflection) {
    MIRROR_REFLECTION_DISABLED
    , MIRROR_REFLECTION_ENABLED
};

#pragma mark BarcodeScannerSettings.editing

@class Ean13, UpcA, EditingEan8, EditingUpcE, EditingCode39, EditingCodabar, EditingItf, EditingStf, EditingSQRC;

/**
 バーコードから読み取ったデータの編集関連設定値
 BarcodeScannerSetting.editing
 */
@interface Editing : NSObject

/// バーコードから読み取ったEAN-13データの編集関連設定値
@property Ean13 *ean13;

/// バーコードから読み取ったUPC-Aコードのデータ編集関連設定値
@property UpcA *upcA;

/// バーコードから読み取ったEAN-8コードのデータ編集関連設定値
@property EditingEan8 *ean8;

/// バーコードから読み取ったUPC-Eコードのデータ編集関連設定値
@property EditingUpcE *upcE;

/// バーコードから読み取ったCode39コードのデータ編集関連設定値
@property EditingCode39 *code39;

/// バーコードから読み取ったCodabarコードのデータ編集関連設定値
@property EditingCodabar *codabar;

/// バーコードから読み取ったITFコードのデータ編集関連設定値
@property EditingItf *itf;

/// バーコードから読み取ったSTFコードのデータ編集関連設定値
@property EditingStf *stf;

/// バーコードから読み取ったSQRCコードのデータ編集関連設定値
@property EditingSQRC *sqrc;

/// バーコードスキャナモジュールを電源OFFするまでの時間
@property PowerOffDelay *powerOffDelay;

@end

#pragma mark BarcodeScannerSetting.editing.ean13

/**
 バーコードから読み取ったEAN-13データの編集関連設定値
 BarcodeScannerSetting.editing.ean13
 */
@interface Ean13 : NSObject

/// チェックデジット付加(true:付加する, false:付加しない)
@property bool reportCheckDigit;

@end

#pragma mark BarcodeScannerSetting.editing.upcA

/**
 バーコードから読み取ったUPC-Aコードのデータ編集関連設定値
 BarcodeScannerSetting.editing.upcA
 */
@interface UpcA : NSObject

/// チェックデジット付加(true:付加する, false:付加しない)
@property bool reportCheckDigit;

/// 転送桁数調整用先頭キャラクタ付加(true:付加する, false:付加しない)
@property bool addLeadingZero;

@end

#pragma mark BarcodeScannerSetting.editing.ean8

/**
 バーコードから読み取ったEAN-8コードのデータ編集関連設定値
 BarcodeScannerSetting.editing.ean8
 */
@interface EditingEan8 : NSObject

/// チェックデジット付加(true:付加する, false:付加しない)
@property bool reportCheckDigit;

/// EAN13への変換(true:変換する, false:変換しない)
@property bool convertToEan13;

@end

#pragma mark BarcodeScannerSetting.editing.upcE

/**
 バーコードから読み取ったUPC-Eコードのデータ編集関連設定値
 BarcodeScannerSetting.editing.upcE
 */
@interface EditingUpcE : NSObject

/// チェックデジット付加(true:付加する, false:付加しない)
@property bool reportCheckDigit;

/// 転送桁数調整用先頭キャラクタ付加(true:付加する, false:付加しない)
@property bool addLeadingZero;

/// UPC-Aへの変換(true:変換する, false:変換しない)
@property bool convertToUpcA;

/// UPC-Aへ変換した場合のナンバーシステム付加(true:付加する, false:付加しない)
@property bool reportNumberSystemCharacterOfConvertedUpcA;

@end

#pragma mark BarcodeScannerSetting.editing.code39

/**
 バーコードから読み取ったCode39コードのデータ編集関連設定値
 BarcodeScannerSetting.editing.code39
 */
@interface EditingCode39 : NSObject

/// チェックデジット付加(true:付加する, false:付加しない)
@property bool reportCheckDigit;

/// スタートストップ付加(true:付加する, false:付加しない)
@property bool reportStartStopCharacter;

@end

#pragma mark BarcodeScannerSetting.editing.codabar

/**
 バーコードから読み取ったCodabarコードのデータ編集関連設定値
 BarcodeScannerSetting.editing.codabar
 */
@interface EditingCodabar : NSObject

/// チェックデジット付加(true:付加する, false:付加しない)
@property bool reportCheckDigit;

/// スタートストップ付加(true:付加する, false:付加しない)
@property bool reportStartStopCharacter;

/// スタートストップの大文字変換(true:変換する, false:変換しない)
@property bool convertToUpperCase;

@end

#pragma mark BarcodeScannerSetting.editing.itf

/**
 バーコードから読み取ったITFコードのデータ編集関連設定値
 BarcodeScannerSetting.editing.itf
 */
@interface EditingItf : NSObject

/// チェックデジット付加(true:付加する, false:付加しない)
@property bool reportCheckDigit;

@end

#pragma mark BarcodeScannerSetting.editing.stf

/**
 バーコードから読み取ったSTFコードのデータ編集関連
 BarcodeScannerSetting.editing.stf
 */
@interface EditingStf : NSObject

/// チェックデジット付加(true:付加する, false:付加しない)
@property bool reportCheckDigit;

@end

#pragma mark BarcodeScannerSetting.editing.sqrc

/**
 バーコードから読み取ったSQRCコードのデータ編集関連
 BarcodeScannerSetting.editing.sqrc
 */
@interface EditingSQRC : NSObject

typedef NS_ENUM(NSInteger, CorrectKeyDecode);
typedef NS_ENUM(NSInteger, IncorrectKeyDecode);

#pragma mark BarcodeScannerSettings.editing.sqrc.CorrectKeyDecode

/**
 SQRC 出力データ部の設定
 BarcodeScannerSettings.scan.correctKeyDecode
 
 - PUBLIC_AND_PRIVATE_DATA: 公開部と非公開部
 - ONLY_PRIVATE_DATA: 非公開部のみ
 */

typedef NS_ENUM(NSInteger, CorrectKeyDecode) {
    PUBLIC_AND_PRIVATE_DATA
    , ONLY_PRIVATE_DATA
};

#pragma mark BarcodeScannerSettings.editing.sqrc.IncorrectKeyDecode

/**
 SQRC暗号キー不一致時の出力データ部の設定
 BarcodeScannerSettings.scan.incorrectKeyDecode
 
 - NONE: 出力なし
 - ONLY_PUBLIC_DATA: 公開部のみ
 */

typedef NS_ENUM(NSInteger, IncorrectKeyDecode) {
    NONE
    , ONLY_PUBLIC_DATA
};


// SQRC出力データ部
@property CorrectKeyDecode correctKeyDecode;

// SQRC暗号キー不一致時の出力データ部
@property IncorrectKeyDecode incorrectKeyDecode;

@end

#pragma mark BarcodeScannerSettings.powerOffDelay

/**
 バーコードスキャナモジュールを電源OFFするまでの時間
 BarcodeScannerSettings.powerOffDelay
 */
@interface PowerOffDelay : NSObject

/// closeBarcode後、バーコードスキャナモジュールを電源OFFするまでの時間(ミリ秒)
@property int time;

@end
