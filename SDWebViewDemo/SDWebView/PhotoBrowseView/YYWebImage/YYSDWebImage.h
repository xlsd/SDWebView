//
//  YYSDWebImage.h
//  YYSDWebImage <https://github.com/ibireme/YYSDWebImage>
//
//  Created by ibireme on 15/2/23.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <UIKit/UIKit.h>

#if __has_include(<YYSDWebImage/YYSDWebImage.h>)
FOUNDATION_EXPORT double YYSDWebImageVersionNumber;
FOUNDATION_EXPORT const unsigned char YYSDWebImageVersionString[];
#import <YYSDWebImage/YYSDImageCache.h>
#import <YYSDWebImage/YYSDWebImageOperation.h>
#import <YYSDWebImage/YYSDWebImageManager.h>
#import <YYSDWebImage/UIImage+YYSDWebImage.h>
#import <YYSDWebImage/UIImageView+YYSDWebImage.h>
#import <YYSDWebImage/UIButton+YYSDWebImage.h>
#import <YYSDWebImage/CALayer+YYSDWebImage.h>
#import <YYSDWebImage/MKAnnotationView+YYSDWebImage.h>
#else
#import "YYSDImageCache.h"
#import "YYSDWebImageOperation.h"
#import "YYSDWebImageManager.h"
#import "UIImage+YYSDWebImage.h"
#import "UIImageView+YYSDWebImage.h"
#import "UIButton+YYSDWebImage.h"
#import "CALayer+YYSDWebImage.h"
#import "MKAnnotationView+YYSDWebImage.h"
#endif

#if __has_include(<YYSDImage/YYSDImage.h>)
#import <YYSDImage/YYSDImage.h>
#elif __has_include(<YYSDWebImage/YYSDImage.h>)
#import <YYSDWebImage/YYSDImage.h>
#import <YYSDWebImage/YYSDFrameImage.h>
#import <YYSDWebImage/YYSDSpriteSheetImage.h>
#import <YYSDWebImage/YYSDImageCoder.h>
#import <YYSDWebImage/YYSDAnimatedImageView.h>
#else
#import "YYSDImage.h"
#import "YYSDFrameImage.h"
#import "YYSDSpriteSheetImage.h"
#import "YYSDImageCoder.h"
#import "YYSDAnimatedImageView.h"
#endif

#if __has_include(<YYSDCache/YYSDCache.h>)
#import <YYSDCache/YYSDCache.h>
#elif __has_include(<YYSDWebImage/YYSDCache.h>)
#import <YYSDWebImage/YYSDCache.h>
#import <YYSDWebImage/YYSDMemoryCache.h>
#import <YYSDWebImage/YYSDDiskCache.h>
#import <YYSDWebImage/YYSDKVStorage.h>
#else
#import "YYSDCache.h"
#import "YYSDMemoryCache.h"
#import "YYSDDiskCache.h"
#import "YYSDKVStorage.h"
#endif

