//
//  UIImage+RoundedCorner.h
//  PicaTalk
//
//  Created by Choe on 7/28/14.
//  Copyright (c) 2014 Chris Ballinger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface UIImage (RoundedCorner)
- (UIImage *)roundedCornerImage:(NSInteger)cornerSize borderSize:(NSInteger)borderSize;
- (UIImage *) roundedImage:(CGSize)bounds;
- (void)addRoundedRectToPath:(CGRect)rect context:(CGContextRef)context ovalWidth:(CGFloat)ovalWidth ovalHeight:(CGFloat)ovalHeight;

@end
