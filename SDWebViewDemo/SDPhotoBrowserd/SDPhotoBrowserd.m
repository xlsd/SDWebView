//
//  SDPhotoBrowserd.m
//  YTXEducation
//
//  Created by 薛林 on 17/4/4.
//  Copyright © 2017年 YunTianXia. All rights reserved.
//

#import "SDPhotoBrowserd.h"
#import "UIImageView+WebCache.h"
#import "SDImageView.h"
#import "SDBrowserdConfig.h"


@interface SDPhotoBrowserd ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIView *scourceView;
@property (nonatomic, strong) UIView *recordView;
@property (nonatomic, strong) UIVisualEffectView *effectView;
@end


@implementation SDPhotoBrowserd {
    UIScrollView *_scrollView;  //  滚动视图
    BOOL _hasShowedFistView;
    UILabel *_indexLabel;
    UIActivityIndicatorView *_indicatorView;
    BOOL _willDisappear;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (void)didMoveToSuperview {
    [self setupScrollView];
    
    [self setupCountLabel];
}

- (void)dealloc {
    [[UIApplication sharedApplication].keyWindow removeObserver:self forKeyPath:@"frame"];
}

- (void)setupCountLabel {
    // 1. 序标
    if (self.imageCount > 1) {
        UILabel *indexLabel = [[UILabel alloc] init];
        indexLabel.bounds = CGRectMake(0, 0, 80, 30);
        indexLabel.textAlignment = NSTextAlignmentCenter;
        indexLabel.textColor = [UIColor whiteColor];
        indexLabel.font = [UIFont boldSystemFontOfSize:20];
        indexLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        indexLabel.layer.cornerRadius = indexLabel.bounds.size.height * 0.5;
        indexLabel.clipsToBounds = YES;
        indexLabel.text = [NSString stringWithFormat:@"1/%ld", (long)self.imageCount];
        _indexLabel = indexLabel;
        [self addSubview:indexLabel];
    }
}
- (void)mune {
    [self addSubview:self.effectView];
    [UIView animateWithDuration:SDPhotoBrowserShowImageAnimationDuration delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.5 options:UIViewAnimationOptionLayoutSubviews animations:^{
        self.effectView.transform = CGAffineTransformMakeTranslation(0, -self.effectView.frame.size.height);
    } completion:^(BOOL finished) {}];
}
- (void)cancelAction {
    [UIView animateWithDuration:SDPhotoBrowserShowImageAnimationDuration animations:^{
        self.effectView.transform = CGAffineTransformMakeTranslation(0, 88);
    } completion:^(BOOL finished) {
        [self.effectView removeFromSuperview];
    }];
}
- (void)saveImage {
    int index = _scrollView.contentOffset.x / _scrollView.bounds.size.width;
    UIImageView *currentImageView = _scrollView.subviews[index];
    
    UIImageWriteToSavedPhotosAlbum(currentImageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    indicator.center = self.center;
    _indicatorView = indicator;
    [[UIApplication sharedApplication].keyWindow addSubview:indicator];
    [indicator startAnimating];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [_indicatorView removeFromSuperview];
    
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.90f];
    label.layer.cornerRadius = 5;
    label.clipsToBounds = YES;
    label.bounds = CGRectMake(0, 0, 150, 30);
    label.center = self.center;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:17];
    [[UIApplication sharedApplication].keyWindow addSubview:label];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:label];
    if (error) {
        label.text = SDPhotoBrowserSaveImageFailText;
    }   else {
        label.text = SDPhotoBrowserSaveImageSuccessText;
        [self.effectView removeFromSuperview];
    }
    [label performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.0];
}

- (void)setupScrollView {
    _scrollView = [[UIScrollView alloc] init];
    UIView *toolbar;
    if ([UIVisualEffectView class]) {
        toolbar = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    } else {
        toolbar = [UIToolbar new];
    }
    toolbar.frame = self.frame;
    [self addSubview:toolbar];
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    [self addSubview:_scrollView];
    
    for (int i = 0; i < self.imageCount; i++) {
        SDImageView *imageView = [[SDImageView alloc] init];
        imageView.tag = i;
        
        // 单击图片
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoClick:)];
        // 双击放大图片
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewDoubleTaped:)];
        doubleTap.numberOfTapsRequired = 2;
        //长按图片保存
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self  action:@selector(mune)];
        
        [singleTap requireGestureRecognizerToFail:doubleTap];
        
        [imageView addGestureRecognizer:singleTap];
        [imageView addGestureRecognizer:doubleTap];
        [imageView addGestureRecognizer:longPress];
        [_scrollView addSubview:imageView];
    }
    
    [self setupImageOfImageViewForIndex:self.currentImageIndex];
    
}

// 加载图片
- (void)setupImageOfImageViewForIndex:(NSInteger)index {
    if (index > self.imageCount-1) return;
    SDImageView *imageView = _scrollView.subviews[index];
    self.currentImageIndex = index;
    if (imageView.hasLoadedImage) return;
    if ([self highQualityImageURLForIndex:index]) {
        [imageView setImageWithURL:[self highQualityImageURLForIndex:index] placeholderImage:[self placeholderImageForIndex:index]];
    } else {
        imageView.image = [self placeholderImageForIndex:index];
    }
    imageView.hasLoadedImage = YES;
}

- (void)photoClick:(UITapGestureRecognizer *)recognizer {
    _scrollView.hidden = YES;
    _willDisappear = YES;
    
    SDImageView *currentImageView = (SDImageView *)recognizer.view;
    NSInteger currentIndex = currentImageView.tag;
    
    UIView *sourceView = nil;
    if ([self.sourceImagesContainerView isKindOfClass:UICollectionView.class]) {
        UICollectionView *view = (UICollectionView *)self.sourceImagesContainerView;
        NSIndexPath *path = [NSIndexPath indexPathForItem:currentIndex inSection:0];
        sourceView = [view cellForItemAtIndexPath:path];
    } else {
        sourceView = self.scourceView;
    }
    self.recordView = sourceView;
    CGRect targetTemp = [self.sourceImagesContainerView convertRect:sourceView.frame toView:self];
    
    UIImageView *tempView = [[UIImageView alloc] init];
    tempView.contentMode = sourceView.contentMode;
    tempView.clipsToBounds = YES;
    tempView.image = currentImageView.image;
    CGFloat h = (self.bounds.size.width / currentImageView.image.size.width) * currentImageView.image.size.height;
    
    if (!currentImageView.image) { // 防止 因imageview的image加载失败 导致 崩溃
        h = self.bounds.size.height;
    }
    tempView.bounds = CGRectMake(0, 0, self.bounds.size.width, h);
    tempView.center = self.center;
    [self addSubview:tempView];
//    [UIView animateWithDuration:2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
//        [tempView.layer setValue:@(1.01) forKeyPath:@"transform.scale"];
//    }completion:^(BOOL finished) {
//        [UIView animateWithDuration:2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
//            [tempView.layer setValue:@(1.0) forKeyPath:@"transform.scale"];
//        }completion:^(BOOL finished) {
//            tempView.clipsToBounds = YES;
//        }];
//    }];
    if (self.recordView == self.scourceView) {
        [UIView animateWithDuration:SDPhotoBrowserShowImageAnimationDuration animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    } else{
        [UIView animateWithDuration:SDPhotoBrowserHideImageAnimationDuration animations:^{
            tempView.frame = targetTemp;
            self.backgroundColor = [UIColor clearColor];
            _indexLabel.alpha = 0.1;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
}

- (void)imageViewDoubleTaped:(UITapGestureRecognizer *)recognizer {
    SDImageView *imageView = (SDImageView *)recognizer.view;
    CGFloat scale;
    if (imageView.isScaled) {
        scale = 1.0;
    } else {
        scale = 2.0;
    }
    
    SDImageView *view = (SDImageView *)recognizer.view;
    
    [view doubleTapToZommWithScale:scale];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect rect = self.bounds;
    rect.size.width += SDPhotoBrowserImageViewMargin * 2;
    
    _scrollView.bounds = rect;
    _scrollView.center = self.center;
    
    CGFloat y = 0;
    CGFloat w = _scrollView.frame.size.width - SDPhotoBrowserImageViewMargin * 2;
    CGFloat h = _scrollView.frame.size.height;
    
    [_scrollView.subviews enumerateObjectsUsingBlock:^(SDImageView *obj, NSUInteger idx, BOOL *stop) {
        CGFloat x = SDPhotoBrowserImageViewMargin + idx * (SDPhotoBrowserImageViewMargin * 2 + w);
        obj.frame = CGRectMake(x, y, w, h);
    }];
    
    _scrollView.contentSize = CGSizeMake(_scrollView.subviews.count * _scrollView.frame.size.width, 0);
    _scrollView.contentOffset = CGPointMake(self.currentImageIndex * _scrollView.frame.size.width, 0);
    if (!_hasShowedFistView) {
        [self showFirstImage];
    }
    _indexLabel.center = CGPointMake(self.bounds.size.width * 0.5, 35);
}

- (void)show {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.frame = window.bounds;
    [window addObserver:self forKeyPath:@"frame" options:0 context:nil];
    self.alpha = 0;
    [window addSubview:self];
    [UIView animateWithDuration:SDPhotoBrowserShowImageAnimationDuration animations:^{
        self.alpha = 1;
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(UIView *)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"frame"]) {
        self.frame = object.bounds;
        SDImageView *currentImageView = _scrollView.subviews[_currentImageIndex];
        if ([currentImageView isKindOfClass:[SDImageView class]]) {
            [currentImageView clear];
        }
    }
}

- (void)showFirstImage {
    UIView *sourceView = nil;
    
    if ([self.sourceImagesContainerView isKindOfClass:UICollectionView.class]) {
        UICollectionView *view = (UICollectionView *)self.sourceImagesContainerView;
        NSIndexPath *path = [NSIndexPath indexPathForItem:self.currentImageIndex inSection:0];
        sourceView = [view cellForItemAtIndexPath:path];
        
    } else {
        
        sourceView = self.scourceView;
        
    }
    self.recordView = sourceView;
    CGRect rect = [self.sourceImagesContainerView convertRect:sourceView.frame toView:self];
    
    UIImageView *tempView = [[UIImageView alloc] init];
    tempView.image = [self placeholderImageForIndex:self.currentImageIndex];
    
    [self addSubview:tempView];
    
    CGRect targetTemp = [_scrollView.subviews[self.currentImageIndex] bounds];
    
    tempView.frame = rect;
    tempView.contentMode = [_scrollView.subviews[self.currentImageIndex] contentMode];
    _scrollView.hidden = YES;
    
    
    [UIView animateWithDuration:SDPhotoBrowserShowImageAnimationDuration animations:^{
        tempView.center = self.center;
        tempView.bounds = (CGRect){CGPointZero, targetTemp.size};
    } completion:^(BOOL finished) {
        _hasShowedFistView = YES;
        [tempView removeFromSuperview];
        _scrollView.hidden = NO;
    }];
}

- (UIImage *)placeholderImageForIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(photoBrowser:placeholderImageForIndex:)]) {
        return [self.delegate photoBrowser:self placeholderImageForIndex:index];
    }
    return nil;
}

- (NSURL *)highQualityImageURLForIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(photoBrowser:highQualityImageURLForIndex:)]) {
        return [self.delegate photoBrowser:self highQualityImageURLForIndex:index];
    }
    return nil;
}

#pragma mark - scrollview代理方法

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int index = (scrollView.contentOffset.x + _scrollView.bounds.size.width * 0.5) / _scrollView.bounds.size.width;
    
    // 有过缩放的图片在拖动一定距离后清除缩放
    CGFloat margin = 150;
    CGFloat x = scrollView.contentOffset.x;
    if ((x - index * self.bounds.size.width) > margin || (x - index * self.bounds.size.width) < - margin) {
        if (index > self.imageCount - 1) return;
        SDImageView *imageView = _scrollView.subviews[index];
        if (imageView.isScaled) {
            [UIView animateWithDuration:0.5 animations:^{
                imageView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                [imageView eliminateScale];
            }];
        }
    }
    if (!_willDisappear) {
        _indexLabel.text = [NSString stringWithFormat:@"%d/%ld", index + 1, (long)self.imageCount];
    }
    [self setupImageOfImageViewForIndex:index];
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self cancelAction];
}

- (UIView *)scourceView {
    if (!_scourceView) {
        _scourceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
        _scourceView.center = self.center;
    }
    return _scourceView;
}
//  MARK: - 长按弹出的两个按钮视图
- (UIVisualEffectView *)effectView {
    if (!_effectView) {
        _effectView = [[UIVisualEffectView alloc] initWithEffect: [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
        _effectView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height,  [UIScreen mainScreen].bounds.size.width, 88);
        UIButton *saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _effectView.frame.size.width, _effectView.frame.size.height * 0.5)];
        [saveBtn setTitle:SDPhotoBrowserSaveImageSuccessText forState:UIControlStateNormal];
        saveBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [saveBtn addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
        UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, _effectView.frame.size.height*0.5, _effectView.frame.size.width, _effectView.frame.size.height * 0.5)];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [saveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
        [_effectView.contentView addSubview:saveBtn];
        [_effectView.contentView addSubview:cancelBtn];
        CALayer *lineLayer = [CALayer layer];
        lineLayer.backgroundColor = [UIColor lightGrayColor].CGColor;
        lineLayer.frame = CGRectMake(0, _effectView.frame.size.height*0.5, _effectView.frame.size.width, 0.5);
        [_effectView.layer addSublayer:lineLayer];
    }
    return _effectView;
}


@end
