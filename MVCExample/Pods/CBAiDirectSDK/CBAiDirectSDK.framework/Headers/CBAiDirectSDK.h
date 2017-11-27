//
//  CBSDK.h
//  Pods
//
//  Created by Donny2g Hu on 2017/6/29.
//
//

#import <Foundation/Foundation.h>
#import "CBAnalyzeObject.h"

/*!
 @enum
 @discussion These options apply to switch light of aiDirect.
 */
typedef NS_ENUM(NSInteger, CBAiDirectLight){
    CBAiDirectUVLight = 0,  //Use the UV light for aiDirect.
    CBAiDirectPolarizedLight, //Use the  polarized light for aiDirect.
    CBAiDirectWhiteLight, //Use the white light for aiDirect.

    CBAiDirectLightClose //Turn off all lights,it can save power.

};


typedef NS_ENUM(NSInteger, CBGender)
{
    CBGenderFemle = 0,
    CBGenderMale
};

// The key is used to fetch image from ImageDict captured by aiDirect.
extern NSString * const UVLightImageKey;
extern NSString * const PolarizedLightImageKey;
extern NSString * const WhiteLightImageKey;


@protocol CBAiDirectSDKDelegate <NSObject>

@optional
/*!
 @method
 @abstract CosBeauty aiDirect connect result.
 */
- (void)aiDirectDidConnect;

/*!
 @method
 @abstract
 CosBeauty aiDirect disconnect.
 */
- (void)aiDirectDidDisconnect;

/*!
 @method
 @abstract
 CosBeauty aiDirect capture image succeeded callback.
 
 @param imageDict Contains images captured by aiDirect, Using 'UVLightImageKey' 'PolarizedLightImageKey' 'WhiteLightImageKey' to get the UVImage  PolarizedImage or WhiteImage if it's exists.
 */
- (void)aiDirectDidCaptureWithImage:(NSDictionary *)imageDict;

/*!
 @method
 @abstract
 CosBeauty aiDirect capture image failed callback.
 */
- (void)aiDirectCaptureImageFailed;

/*!
 @method
 @abstract
 CosBeauty aiDirect capture image successed callback.

 @param analysisResult the result of analyzing the skin dimension of the algorithm,see CBAnalyzeObject and CBAnalyzeComplexionObject.
 */
- (void)aiDirectCaptureFinishedWithResult:(NSArray<CBAnalyzeObject *> *)analysisResult;

/*!
 @method
 @abstract
 preview display.

 @param pixelBuffer can show on CAEAGLLayer.
 */
- (void)aiDirectCaptureOutputSampleBufferPreview:(CVPixelBufferRef)pixelBuffer;

/*!
 @method
 @abstract
 CosBeauty aiDirect work on lowpower mode.
 */
- (void)aiDirectDidChangetoLowpowerMode;

/*!
 @method
 @abstract
 CosBeauty aiDirect upgrade firmware callback.

 @param progress 0~1
 */
- (void)aiDirectUpgradeProgress:(CGFloat)progress;

@end


@interface CBAiDirectSDK : NSObject

/*!
 @method
 @abstract
 register SDK.
 @param delegate see CBAiDirectSDKDelegate.
 */
+ (void)prepareWithDelegate:(id<CBAiDirectSDKDelegate>)delegate;


/*!
 @method
 @abstract
 active user sign-in,this method will upload user's profile to us, then we can improve algorithm accuracy.
 
 @param gender the user gender, see CBGender.
 @param age the user age.
 @param location the user region.
 @discussion   location: input City - For example,SZ,SZ-CN,ShenZhen,China,深圳 and so on.
 */
+ (void)profileSignInWithGender:(CBGender)gender age:(NSInteger)age location:(NSString *)location;

/*!
 @method
 @abstract
 connect to CosBeauty aiDirect,at first you must connect CosBeauty aiDirect's WiFi.
 */
+ (void)connect;

/*!
 @method
 @abstract
 disconnect to CosBeauty aiDirect.
 */
+ (void)disconnect;


/*!
 @method
 @abstract
 start preview,the method will call the delegate method(aiDirectCaptureOutputSampleBufferPreview:)
 */
+ (void)startPreview;

/*!
 @method
 @abstract
 stop preview,After invoking this method,you will not receive preview image.
 */
+ (void)stopPreview;


/*!
 @method
 Change light of the aiDirect

 @param light see CBAiDirectLight.
 */
+ (void)switchLight:(CBAiDirectLight)light;


/*!
 @method
 capture image with select check type.

 @param type see CBCheckType.
 */
+ (void)takePhotoForCheckType:(CBCheckType)type;


/*!
 @method
 firmware

 @return firmware of CosBeauty aiDirect.
 */
+ (NSString *)getFirmwareVersion;



/*!
 @method
 upgrade firmware of CosBeauty aiDirect.

 @param firmwareData firmware file data.
 @param firmwareVersion firmware version.
 */
+ (void)upgradeFirmware:(NSData *)firmwareData firmwareVersion:(NSString *)firmwareVersion;

@end
