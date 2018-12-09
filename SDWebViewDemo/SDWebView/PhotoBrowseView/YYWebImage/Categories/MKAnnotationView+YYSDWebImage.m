//
//  MKAnnotationView+YYSDWebImage.m
//  YYSDWebImage <https://github.com/ibireme/YYSDWebImage>
//
//  Created by ibireme on 15/2/23.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "MKAnnotationView+YYSDWebImage.h"
#import "YYSDWebImageOperation.h"
#import "_YYSDWebImageSetter.h"
#import <objc/runtime.h>

// Dummy class for category
@interface MKAnnotationView_YYWebImage : NSObject @end
@implementation MKAnnotationView_YYWebImage @end


static int _YYWebImageSetterKey;

@implementation MKAnnotationView (YYSDWebImage)

- (NSURL *)YYSD_imageURL {
    _YYWebImageSetter *setter = objc_getAssociatedObject(self, &_YYWebImageSetterKey);
    return setter.imageURL;
}

- (void)setYy_imageURL:(NSURL *)imageURL {
    [self YYSD_setImageWithURL:imageURL
              placeholder:nil
                  options:kNilOptions
                  manager:nil
                 progress:nil
                transform:nil
               completion:nil];
}

- (void)YYSD_setImageWithURL:(NSURL *)imageURL placeholder:(UIImage *)placeholder {
    [self YYSD_setImageWithURL:imageURL
                 placeholder:placeholder
                     options:kNilOptions
                     manager:nil
                    progress:nil
                   transform:nil
                  completion:nil];
}

- (void)YYSD_setImageWithURL:(NSURL *)imageURL options:(YYSDWebImageOptions)options {
    [self YYSD_setImageWithURL:imageURL
                 placeholder:nil
                     options:options
                     manager:nil
                    progress:nil
                   transform:nil
                  completion:nil];
}

- (void)YYSD_setImageWithURL:(NSURL *)imageURL
               placeholder:(UIImage *)placeholder
                   options:(YYSDWebImageOptions)options
                completion:(YYSDWebImageCompletionBlock)completion {
    [self YYSD_setImageWithURL:imageURL
                 placeholder:placeholder
                     options:options
                     manager:nil
                    progress:nil
                   transform:nil
                  completion:completion];
}

- (void)YYSD_setImageWithURL:(NSURL *)imageURL
               placeholder:(UIImage *)placeholder
                   options:(YYSDWebImageOptions)options
                  progress:(YYSDWebImageProgressBlock)progress
                 transform:(YYSDWebImageTransformBlock)transform
                completion:(YYSDWebImageCompletionBlock)completion {
    [self YYSD_setImageWithURL:imageURL
                 placeholder:placeholder
                     options:options
                     manager:nil
                    progress:progress
                   transform:transform
                  completion:completion];
}

- (void)YYSD_setImageWithURL:(NSURL *)imageURL
               placeholder:(UIImage *)placeholder
                   options:(YYSDWebImageOptions)options
                   manager:(YYSDWebImageManager *)manager
                  progress:(YYSDWebImageProgressBlock)progress
                 transform:(YYSDWebImageTransformBlock)transform
                completion:(YYSDWebImageCompletionBlock)completion {
    if ([imageURL isKindOfClass:[NSString class]]) imageURL = [NSURL URLWithString:(id)imageURL];
    manager = manager ? manager : [YYSDWebImageManager sharedManager];
    
    _YYWebImageSetter *setter = objc_getAssociatedObject(self, &_YYWebImageSetterKey);
    if (!setter) {
        setter = [_YYWebImageSetter new];
        objc_setAssociatedObject(self, &_YYWebImageSetterKey, setter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    int32_t sentinel = [setter cancelWithNewURL:imageURL];
    
    _yy_dispatch_sync_on_main_queue(^{
        if ((options & YYSDWebImageOptionSetImageWithFadeAnimation) &&
            !(options & YYSDWebImageOptionAvoidSetImage)) {
            if (!self.highlighted) {
                [self.layer removeAnimationForKey:_YYWebImageFadeAnimationKey];
            }
        }
        if (!imageURL) {
            if (!(options & YYSDWebImageOptionIgnorePlaceHolder)) {
                self.image = placeholder;
            }
            return;
        }
        
        // get the image from memory as quickly as possible
        UIImage *imageFromMemory = nil;
        if (manager.cache &&
            !(options & YYSDWebImageOptionUseNSURLCache) &&
            !(options & YYSDWebImageOptionRefreshImageCache)) {
            imageFromMemory = [manager.cache getImageForKey:[manager cacheKeyForURL:imageURL] withType:YYSDImageCacheTypeMemory];
        }
        if (imageFromMemory) {
            if (!(options & YYSDWebImageOptionAvoidSetImage)) {
                self.image = imageFromMemory;
            }
            if(completion) completion(imageFromMemory, imageURL, YYSDWebImageFromMemoryCacheFast, YYSDWebImageStageFinished, nil);
            return;
        }
        
        if (!(options & YYSDWebImageOptionIgnorePlaceHolder)) {
            self.image = placeholder;
        }
        
        __weak typeof(self) _self = self;
        dispatch_async([_YYWebImageSetter setterQueue], ^{
            YYSDWebImageProgressBlock _progress = nil;
            if (progress) _progress = ^(NSInteger receivedSize, NSInteger expectedSize) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    progress(receivedSize, expectedSize);
                });
            };
            
            __block int32_t newSentinel = 0;
            __block __weak typeof(setter) weakSetter = nil;
            YYSDWebImageCompletionBlock _completion = ^(UIImage *image, NSURL *url, YYSDWebImageFromType from, YYSDWebImageStage stage, NSError *error) {
                __strong typeof(_self) self = _self;
                BOOL setImage = (stage == YYSDWebImageStageFinished || stage == YYSDWebImageStageProgress) && image && !(options & YYSDWebImageOptionAvoidSetImage);
                BOOL showFade = ((options & YYSDWebImageOptionSetImageWithFadeAnimation) && !self.highlighted);
                dispatch_async(dispatch_get_main_queue(), ^{
                    BOOL sentinelChanged = weakSetter && weakSetter.sentinel != newSentinel;
                    if (setImage && self && !sentinelChanged) {
                        if (showFade) {
                            CATransition *transition = [CATransition animation];
                            transition.duration = stage == YYSDWebImageStageFinished ? _YYWebImageFadeTime : _YYWebImageProgressiveFadeTime;
                            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                            transition.type = kCATransitionFade;
                            [self.layer addAnimation:transition forKey:_YYWebImageFadeAnimationKey];
                        }
                        self.image = image;
                    }
                    if (completion) {
                        if (sentinelChanged) {
                            completion(nil, url, YYSDWebImageFromNone, YYSDWebImageStageCancelled, nil);
                        } else {
                            completion(image, url, from, stage, error);
                        }
                    }
                });
            };
            
            newSentinel = [setter setOperationWithSentinel:sentinel url:imageURL options:options manager:manager progress:_progress transform:transform completion:_completion];
            weakSetter = setter;
        });
    });
}

- (void)YYSD_cancelCurrentImageRequest {
    _YYWebImageSetter *setter = objc_getAssociatedObject(self, &_YYWebImageSetterKey);
    if (setter) [setter cancel];
}

@end
