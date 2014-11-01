//
//  GIFImage.m
//  GIFPlayer
//
//  Created by Leeszi on 6/18/14.
//  Copyright (c) 2014 Evol. All rights reserved.
//

#import "GIFImage.h"

@implementation GIFImage

#pragma mark - life cycle
+ (GIFImage *)imageNamed:(NSString *)name
{
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"gif"];
    
    GIFImage *gifImage = [[self alloc] initWithContentOfFile:path];
    
    //
    if (!gifImage.images) {
        gifImage = nil;
    }
    
    return gifImage;
}

- (instancetype)initWithData:(NSData *)data
{
    self = [super init];
    if (self)
    {
        CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
        [self decodeGIFWithImageSource:imageSource];
        CFRelease(imageSource);
    }
    return self;
}

- (instancetype)initWithContentOfFile:(NSString *)file
{
    self = [super init];
    if (self)
    {
        NSURL *url = [NSURL fileURLWithPath:file];
        CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
        [self decodeGIFWithImageSource:imageSource];
        CFRelease(imageSource);
    }
    return self;
}

- (void)decodeGIFWithImageSource:(CGImageSourceRef)imageSource
{
    NSMutableArray *images = [NSMutableArray array];
    NSMutableArray *keyTimes = [NSMutableArray array];
    [keyTimes addObject:@(0)];

    CGFloat duration = 0.0;
    
    size_t count = CGImageSourceGetCount(imageSource);
    
    for (int i = 0; i < count; i++)
    {
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(imageSource, i, NULL);
        
        //get duration.
        CFDictionaryRef propRef = CGImageSourceCopyPropertiesAtIndex(imageSource, i, NULL);
        NSDictionary *prop = (__bridge NSDictionary *)propRef;
        NSDictionary *gifProp = [prop valueForKey:@"{GIF}"];

        if (gifProp) {
            NSString *delayTime = gifProp[@"DelayTime"];
            if (delayTime) {
                duration += [delayTime floatValue];
                [keyTimes addObject:@([delayTime floatValue])];
            }
        }
        
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        [images addObject:(id)image.CGImage];
        
        CFRelease(propRef);
        CFRelease(imageRef);
    }
    
    //convert keytime to 0.0~1.0
    float keyTime = 0;
    for (int i = 0; i < [keyTimes count]; i++) {
        float time = [keyTimes[i] floatValue];
        keyTime += time;
        
        float key = keyTime/duration;
        key = MIN(key, 1);
        [keyTimes replaceObjectAtIndex:i withObject:@(key)];
    }
    
    self.keyTimes = keyTimes;
    
    self.images = images;
    self.duration = duration;
    self.keyTimes = keyTimes;
}

- (CGSize)size
{
    if ([self.images count] > 0) {
        CGImageRef imageRef = (__bridge CGImageRef)self.images[0];
        CGFloat width = CGImageGetWidth(imageRef);
        CGFloat height = CGImageGetHeight(imageRef);
        return CGSizeMake(width, height);
    }
    return CGSizeZero;
}

@end

static char gifImageKey;

@implementation UIImageView (GIF)

- (void)playGIF
{
    CAKeyframeAnimation *keyframeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    keyframeAnimation.duration = self.gifImage.duration;
    keyframeAnimation.values = self.gifImage.images;
    keyframeAnimation.keyTimes = self.gifImage.keyTimes;
    keyframeAnimation.repeatCount = INFINITY;
    keyframeAnimation.calculationMode = kCAAnimationDiscrete;
    [self.layer addAnimation:keyframeAnimation forKey:@"GIFPlayer"];
}

- (void)setGifImage:(GIFImage *)gifImage
{
    if (self.gifImage != gifImage) {
        objc_setAssociatedObject(self, &gifImageKey, gifImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self playGIF];
    }
}

- (GIFImage *)gifImage
{
    return objc_getAssociatedObject(self, &gifImageKey);
}

@end
