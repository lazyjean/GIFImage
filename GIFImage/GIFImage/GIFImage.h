//
//  GIFImage.h
//  GIFPlayer
//
//  Created by Leeszi on 6/18/14.
//  Copyright (c) 2014 Evol. All rights reserved.
//

#import <Foundation/Foundation.h>

@import QuartzCore;
@import UIKit;
@import ImageIO;
@import ObjectiveC.runtime;

@interface GIFImage : NSObject

@property (strong, nonatomic) NSArray *images;
@property (assign, nonatomic) CGFloat duration;
@property (strong, nonatomic) NSArray *keyTimes;
@property (assign, readonly) CGSize size;

+ (GIFImage *)imageNamed:(NSString *)name;
- (instancetype)initWithData:(NSData *)data;
- (instancetype)initWithContentOfFile:(NSString *)file;

@end

//play gif image
@interface UIImageView(GIF)
@property (strong, nonatomic) GIFImage *gifImage;
@end

//encode gif image
