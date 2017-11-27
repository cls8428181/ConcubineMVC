//
//  CBAnalyzeObject.h
//  Pods
//
//  Created by Donny2g Hu on 2017/6/28.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/*!
 @enum
 check dimension type of CBAiDirectSDK.

 - CBCheckCleaningType: cleaning,include CBTinyDimensionGreaseResidueType and CBTinyDimensionResidueType tiny type.
 
 - CBCheckPigmentType: pigment,include CBTinyDimensionSurfacePigmentType and CBTinyDimensionBottomSkinPigmentType tiny type.
 
 - CBCheckBlackheadType: blackhead,include CBTinyDimensionSurfaceBlackheadType and CBTinyDimensionBottomSkinBlackheadType tiny type.
 
 - CBCheckSensitiveType: sensitive,include CBTinyDimensionSensitiveType tiny type.
 
 - CBCheckMoistType: moist,include CBTinyDimensionMoistureType and CBTinyDimensionOilType tiny type.
 
 - CBCheckComplexionType: complexion,include CBTinyDimensionComplexionType tiny type.
 
 - CBCheckSmoothType: smooth,include CBTinyDimensionSmoothType tiny type.
 
 - CBCheckSunscreenType: sunscreen,include CBTinyDimensionSunScreenType tiny type.

 - CBCheckFirmnessType: firmness,include CBTinyDimensionTextureType tiny type.

 */
typedef NS_OPTIONS(NSUInteger, CBCheckType){
    CBCheckCleaningType = 1 << 0,
    CBCheckPigmentType = 1 << 1,
    CBCheckBlackheadType = 1 << 2,
    CBCheckSensitiveType = 1 << 3,
    CBCheckMoistType = 1 << 4,
    CBCheckComplexionType = 1 << 5,
    CBCheckSmoothType = 1 << 6,
    CBCheckSunscreenType = 1 << 7,
    CBCheckFirmnessType = 1 << 8
};


/*!
 @enum
 tiny dimension type of CBAiDirectSDK.
 */
typedef NS_ENUM(NSInteger, CBTinyDimensionType) {
    CBTinyDimensionGreaseResidueType,   //grease residue
    CBTinyDimensionResidueType,         //residue
    CBTinyDimensionSurfacePigmentType,  //pigment of top skin
    CBTinyDimensionBottomSkinPigmentType, //pigment of bottom skin
    CBTinyDimensionSurfaceBlackheadType,  //blackhead of top skin
    CBTinyDimensionBottomSkinBlackheadType,  //blackhead of bottom skin

    CBTinyDimensionSensitiveType,    //sensitive
    CBTinyDimensionMoistureType,    //moisture
    CBTinyDimensionOilType,         //oil
    CBTinyDimensionComplexionType,  //complexion,include complexion level
    CBTinyDimensionSmoothType,       //smooth
    CBTinyDimensionTextureType,      //texture
    CBTinyDimensionSunScreenType     //SunScreen
};

@interface CBTinyDimensionObject : NSObject
/*!
 @property
 tiny dimension type,see CBTinyDimensionType.
 */
@property (nonatomic) CBTinyDimensionType type;


/*!
 @property
 score for tiny dimension.
 */
@property (nonatomic) NSInteger score;

/*!
 @property
 image for tiny dimension.
 */
@property (nonatomic, strong, nonnull)  UIImage * dimensionImage;

/*!
 @property
 processed image by algorithm for tiny dimension.
 */
@property (nonatomic, strong, nullable) UIImage *processedImage;

@end


@interface CBAnalyzeObject : NSObject
/*!
 @property
 check type
 */
@property (nonatomic) CBCheckType checkType;


/*!
 @property
 total score for check type.
 */
@property (nonatomic) NSInteger score;

/*!
 @property
 tiny dimension analyzed by taken photos of this checkType.
 */
@property (nonatomic, strong, nullable) NSArray<CBTinyDimensionObject *> *tinyDimensions;

@end


@interface CBAnalyzeComplexionObject : CBAnalyzeObject


/*!
 @property
 complexion level for CBCheckComplexionType.
 level : 1~15
 */
@property (nonatomic) NSInteger complexionLevel;

@end
