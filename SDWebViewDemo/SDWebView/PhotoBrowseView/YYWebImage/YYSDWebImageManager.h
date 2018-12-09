//
//  YYSDWebImageManager.h
//  YYSDWebImage <https://github.com/ibireme/YYSDWebImage>
//
//  Created by ibireme on 15/2/19.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <UIKit/UIKit.h>

#if __has_include(<YYSDWebImage/YYSDWebImage.h>)
#import <YYSDWebImage/YYSDImageCache.h>
#else
#import "YYSDImageCache.h"
#endif

@class YYSDWebImageOperation;

NS_ASSUME_NONNULL_BEGIN

/// The options to control image operation.
typedef NS_OPTIONS(NSUInteger, YYSDWebImageOptions) {
    
    /// Show network activity on status bar when download image.
    YYSDWebImageOptionShowNetworkActivity = 1 << 0,
    
    /// Display progressive/interlaced/baseline image during download (same as web browser).
    YYSDWebImageOptionProgressive = 1 << 1,
    
    /// Display blurred progressive JPEG or interlaced PNG image during download.
    /// This will ignore baseline image for better user experience.
    YYSDWebImageOptionProgressiveBlur = 1 << 2,
    
    /// Use NSURLCache instead of YYSDImageCache.
    YYSDWebImageOptionUseNSURLCache = 1 << 3,
    
    /// Allows untrusted SSL ceriticates.
    YYSDWebImageOptionAllowInvalidSSLCertificates = 1 << 4,
    
    /// Allows background task to download image when app is in background.
    YYSDWebImageOptionAllowBackgroundTask = 1 << 5,
    
    /// Handles cookies stored in NSHTTPCookieStore.
    YYSDWebImageOptionHandleCookies = 1 << 6,
    
    /// Load the image from remote and refresh the image cache.
    YYSDWebImageOptionRefreshImageCache = 1 << 7,
    
    /// Do not load image from/to disk cache.
    YYSDWebImageOptionIgnoreDiskCache = 1 << 8,
    
    /// Do not change the view's image before set a new URL to it.
    YYSDWebImageOptionIgnorePlaceHolder = 1 << 9,
    
    /// Ignore image decoding.
    /// This may used for image downloading without display.
    YYSDWebImageOptionIgnoreImageDecoding = 1 << 10,
    
    /// Ignore multi-frame image decoding.
    /// This will handle the GIF/APNG/WebP/ICO image as single frame image.
    YYSDWebImageOptionIgnoreAnimatedImage = 1 << 11,
    
    /// Set the image to view with a fade animation.
    /// This will add a "fade" animation on image view's layer for better user experience.
    YYSDWebImageOptionSetImageWithFadeAnimation = 1 << 12,
    
    /// Do not set the image to the view when image fetch complete.
    /// You may set the image manually.
    YYSDWebImageOptionAvoidSetImage = 1 << 13,
    
    /// This flag will add the URL to a blacklist (in memory) when the URL fail to be downloaded,
    /// so the library won't keep trying.
    YYSDWebImageOptionIgnoreFailedURL = 1 << 14,
};

/// Indicated where the image came from.
typedef NS_ENUM(NSUInteger, YYSDWebImageFromType) {
    
    /// No value.
    YYSDWebImageFromNone = 0,
    
    /// Fetched from memory cache immediately.
    /// If you called "setImageWithURL:..." and the image is already in memory,
    /// then you will get this value at the same call.
    YYSDWebImageFromMemoryCacheFast,
    
    /// Fetched from memory cache.
    YYSDWebImageFromMemoryCache,
    
    /// Fetched from disk cache.
    YYSDWebImageFromDiskCache,
    
    /// Fetched from remote (web or file path).
    YYSDWebImageFromRemote,
};

/// Indicated image fetch complete stage.
typedef NS_ENUM(NSInteger, YYSDWebImageStage) {
    
    /// Incomplete, progressive image.
    YYSDWebImageStageProgress  = -1,
    
    /// Cancelled.
    YYSDWebImageStageCancelled = 0,
    
    /// Finished (succeed or failed).
    YYSDWebImageStageFinished  = 1,
};


/**
 The block invoked in remote image fetch progress.
 
 @param receivedSize Current received size in bytes.
 @param expectedSize Expected total size in bytes (-1 means unknown).
 */
typedef void(^YYSDWebImageProgressBlock)(NSInteger receivedSize, NSInteger expectedSize);

/**
 The block invoked before remote image fetch finished to do additional image process.
 
 @discussion This block will be invoked before `YYSDWebImageCompletionBlock` to give
 you a chance to do additional image process (such as resize or crop). If there's
 no need to transform the image, just return the `image` parameter.
 
 @example You can clip the image, blur it and add rounded corners with these code:
    ^(UIImage *image, NSURL *url) {
        // Maybe you need to create an @autoreleasepool to limit memory cost.
        image = [image YYSD_imageByResizeToSize:CGSizeMake(100, 100) contentMode:UIViewContentModeScaleAspectFill];
        image = [image YYSD_imageByBlurRadius:20 tintColor:nil tintMode:kCGBlendModeNormal saturation:1.2 maskImage:nil];
        image = [image YYSD_imageByRoundCornerRadius:5];
        return image;
    }
 
 @param image The image fetched from url.
 @param url   The image url (remote or local file path).
 @return The transformed image.
 */
typedef UIImage * _Nullable (^YYSDWebImageTransformBlock)(UIImage *image, NSURL *url);

/**
 The block invoked when image fetch finished or cancelled.
 
 @param image       The image.
 @param url         The image url (remote or local file path).
 @param from        Where the image came from.
 @param error       Error during image fetching.
 */
typedef void (^YYSDWebImageCompletionBlock)(UIImage * _Nullable image,
                                          NSURL *url,
                                          YYSDWebImageFromType from,
                                          YYSDWebImageStage stage,
                                          NSError * _Nullable error);




/**
 A manager to create and manage web image operation.
 */
@interface YYSDWebImageManager : NSObject

/**
 Returns global YYSDWebImageManager instance.
 
 @return YYSDWebImageManager shared instance.
 */
+ (instancetype)sharedManager;

/**
 Creates a manager with an image cache and operation queue.
 
 @param cache  Image cache used by manager (pass nil to avoid image cache).
 @param queue  The operation queue on which image operations are scheduled and run
                (pass nil to make the new operation start immediately without queue).
 @return A new manager.
 */
- (instancetype)initWithCache:(nullable YYSDImageCache *)cache
                        queue:(nullable NSOperationQueue *)queue NS_DESIGNATED_INITIALIZER;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

/**
 Creates and returns a new image operation, the operation will start immediately.
 
 @param url        The image url (remote or local file path).
 @param options    The options to control image operation.
 @param progress   Progress block which will be invoked on background thread (pass nil to avoid).
 @param transform  Transform block which will be invoked on background thread  (pass nil to avoid).
 @param completion Completion block which will be invoked on background thread  (pass nil to avoid).
 @return A new image operation.
 */
- (nullable YYSDWebImageOperation *)requestImageWithURL:(NSURL *)url
                                              options:(YYSDWebImageOptions)options
                                             progress:(nullable YYSDWebImageProgressBlock)progress
                                            transform:(nullable YYSDWebImageTransformBlock)transform
                                           completion:(nullable YYSDWebImageCompletionBlock)completion;

/**
 The image cache used by image operation. 
 You can set it to nil to avoid image cache.
 */
@property (nullable, nonatomic, strong) YYSDImageCache *cache;

/**
 The operation queue on which image operations are scheduled and run.
 You can set it to nil to make the new operation start immediately without queue.
 
 You can use this queue to control maximum number of concurrent operations, to obtain 
 the status of the current operations, or to cancel all operations in this manager.
 */
@property (nullable, nonatomic, strong) NSOperationQueue *queue;

/**
 The shared transform block to process image. Default is nil.
 
 When called `requestImageWithURL:options:progress:transform:completion` and
 the `transform` is nil, this block will be used.
 */
@property (nullable, nonatomic, copy) YYSDWebImageTransformBlock sharedTransformBlock;

/**
 The image request timeout interval in seconds. Default is 15.
 */
@property (nonatomic) NSTimeInterval timeout;

/**
 The username used by NSURLCredential, default is nil.
 */
@property (nullable, nonatomic, copy) NSString *username;

/**
 The password used by NSURLCredential, default is nil.
 */
@property (nullable, nonatomic, copy) NSString *password;

/**
 The image HTTP request header. Default is "Accept:image/webp,image/\*;q=0.8".
 */
@property (nullable, nonatomic, copy) NSDictionary<NSString *, NSString *> *headers;

/**
 A block which will be invoked for each image HTTP request to do additional
 HTTP header process. Default is nil.
 
 Use this block to add or remove HTTP header field for a specified URL.
 */
@property (nullable, nonatomic, copy) NSDictionary<NSString *, NSString *> *(^headersFilter)(NSURL *url, NSDictionary<NSString *, NSString *> * _Nullable header);

/**
 A block which will be invoked for each image operation. Default is nil.
 
 Use this block to provide a custom image cache key for a specified URL.
 */
@property (nullable, nonatomic, copy) NSString *(^cacheKeyFilter)(NSURL *url);

/**
 Returns the HTTP headers for a specified URL.
 
 @param url A specified URL.
 @return HTTP headers.
 */
- (nullable NSDictionary<NSString *, NSString *> *)headersForURL:(NSURL *)url;

/**
 Returns the cache key for a specified URL.
 
 @param url A specified URL
 @return Cache key used in YYSDImageCache.
 */
- (NSString *)cacheKeyForURL:(NSURL *)url;


/**
 Increments the number of active network requests.
 If this number was zero before incrementing, this will start animating the
 status bar network activity indicator.
 
 This method is thread safe.
 
 This method has no effect in App Extension.
 */
+ (void)incrementNetworkActivityCount;

/**
 Decrements the number of active network requests.
 If this number becomes zero after decrementing, this will stop animating the
 status bar network activity indicator.
 
 This method is thread safe.
 
 This method has no effect in App Extension.
 */
+ (void)decrementNetworkActivityCount;

/**
 Get current number of active network requests.
 
 This method is thread safe.
 
 This method has no effect in App Extension.
 */
+ (NSInteger)currentNetworkActivityCount;

@end

NS_ASSUME_NONNULL_END
