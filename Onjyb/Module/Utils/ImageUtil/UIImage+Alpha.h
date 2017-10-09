//
//  UIImage+Alpha.h
//  PicaTalk
//
//  Created by Choe on 7/28/14.
//  Copyright (c) 2014 Chris Ballinger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface UIImage (Alpha)
- (BOOL)hasAlpha;
- (UIImage *)imageWithAlpha;
- (UIImage *)transparentBorderImage:(NSUInteger)borderSize;
- (CGImageRef)newBorderMask:(NSUInteger)borderSize size:(CGSize)size;

@end
