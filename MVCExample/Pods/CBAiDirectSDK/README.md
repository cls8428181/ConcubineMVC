# CBAiDirectSDK iOS
CBAiDirectSDK iOS is a library for CosBeauty aiDirect,which makes you control CosBeauty aiDirect easily and get the analysis of skin.
CBAiDirectSDK iOS requires IOS8 or later.

##Preparing Your Apps for iOS9
IOS 9 introduces changes that are likely to impact your app and its CosBeauty integration. This guide will instruct you how to enhance the best app experience when using the CBAiDirectSDK SDK for iOS. 
[
 Learn what's new in iOS 9 from Apple](https://developer.apple.com/library/ios/releasenotes/General/WhatsNewIniOS/Articles/iOS9.html)
###NSAppTransportSecurity
You should to add just the NSAllowsArbitraryLoads key to YES in NSAppTransportSecurity dictionary in your info.plist file.
```
<dict>
<key>NSExceptionDomains</key>
<dict>
<key>mirror.cos-beauty.net</key>
<dict>
<key>NSExceptionDomains</key>
<true/>
</dict>
<key>mirror2.cos-beauty.net</key>
<dict>
<key>NSExceptionDomains</key>
<true/>
</dict>
</dict>
</dict>

```
## Installation
### Install Cocoapods
### Podfile

```ruby
source 'https://git.oschina.net/cosbeautyapp/CosBeautyRepos.git'
source 'https://github.com/CocoaPods/Specs.git'
target 'TargetName' do
pod 'CBAiDirectSDK'
end
```
Then, run the following command:

```bash
$ pod install
```

After installing the cocoapod into your project import CBAiDirectSDK with #import <CBAiDirectSDK/CBAiDirectSDK.h>

## Usage

Please check out CBAiDirectSDKDemo for demo usage. 

###Instantiate CBAiDirectSDK
```
[CBAiDirectSDK prepareWithDelegate:self]
```
###Upload User Profile
Upload user's profile to us, then we can improve algorithm accuracy.
```
[CBAiDirectSDK profileSignInWithGender:CBGenderFemle age:25 location:@"SZ-CN"]
```
###Connect To CosBeauty aiDirect
Make sure aiDirect is connected to your smart phone via WiFi.Then call the method
```
[CBAiDirectSDK connect];
```
If connected,you can do some thing in delegate callback.
```
- (void)aiDirectDidConnect
{
}
```
###Start Preview
Call + startPreView method after connected. For example:
```
[CBAiDirectSDK startPreview];
```
Then receive preview image buffer in the callback method.
```
- (void)aiDirectCaptureOutputSampleBufferPreview:(CVPixelBufferRef)pixelBuffer
{
}
```
###Stop preview
After invoked this method,you will not receive preview buffer.Also,CosBeauty aiDirect will close all  lights. For example:
```
[CBAiDirectSDK stopPreview];
```
###Switch aiDirect Light
You should invoke this method on preview mode.If you call it,you can see different mode preview and light.You can even turn off light by this method.
###Take Photo
It will cost a few seconds.At first,you should set CBAiDirectSDKDelegate.For example:
```
[CBAiDirectSDK takePhotoForCheckType: CBCheckPigmentType | CBCheckBlackheadType];
```
If successed, you will receive the result of analyzing the skin dimension of the algorithm. 
```
- (void)aiDirectCaptureFinishedWithResult:(NSArray<CBAnalyzeObject *> *)analysisResult
{
//Add any custom logic if success 
}
- (void)aiDirectCaptureImageFailed
{
//Add any custom logic if failed
}
```
###upgrade firmware
If there is a new firmware for CosBeauty aiDirect.you can upgrade firmware with this method.
```
- (void)upgradeAction
{
NSString *version; //firmware version
NSData *firmwareData ; //firmware data
[CBAiDirectSDK upgradeFirmware:firmwareData firmwareVersion:filePath];
}
```
###Work on low power mode
you can listen this callback method to notify if CosBeauty aiDirect is working on low power mode.
```
- (void)aiDirectDidChangetoLowpowerMode
{
}
```
## Future
We will improve the algorithm and provide more analysis items.

## License

The LGPL License.
