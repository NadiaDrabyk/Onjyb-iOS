//
//  GlobalUtils.h
//  PicaTalk
//
//  Created by LightSky on 7/5/14.
//  Copyright (c) 2014 Chris Ballinger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Define.h"
#import "SDWebImageManager.h"
#import "User.h"

@interface GlobalUtils : NSObject {
    
}

@property(nonatomic,strong) UIView * viewAlert;

+ (BOOL)isLoggedIn;
+ (BOOL)validateEmailWithString:(NSString*)checkString;
+ (void)setImageForUrlAndSize:(UIImageView*) imageOrg ID:(NSString *) ID url:(NSString *)iconURL size:(CGSize) imgSize placeImage:(NSString*) placeImage storeDir:(NSString*) storeDir;
+ (void)setButtonImgForUrlAndSize:(UIButton*) imageOrg ID:(NSString *) ID url:(NSString *)iconURL size:(CGSize) imgSize placeImage:(NSString*) placeImage storeDir:(NSString*) storeDir;

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (UIImage *)imageByCroppingImage:(UIImage *)image toSize:(CGSize)size;
+ (UIImage *)scaleImageToSize:(UIImage*) image to:(CGSize)newSize;
+ (CGFloat)widthOfString:(NSString *)string withFont:(UIFont *)font;
+ (CGFloat)heightOfString:(NSString *)string withFont:(UIFont *)font;
+ (void)saveUserObject:(User *)object key:(NSString *)key;
+ (User *)loadUserObjectWithKey:(NSString *)key;
+ (void) showAlertController:(UIViewController*) view title:(NSString *) title message:(NSString*) message cancel:(NSString *) cancel;

@end
