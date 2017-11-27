//
//  CBGLLayer.h
//  CBSDK
//
//  Created by Donny2g Hu on 2017/6/29.
//  Copyright © 2017年 hudundun90@gmail.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#include <CoreVideo/CoreVideo.h>

@interface CBGLLayer : CAEAGLLayer
@property CVPixelBufferRef pixelBuffer;
- (id)initWithFrame:(CGRect)frame;
- (void)resetRenderBuffer;

@end
