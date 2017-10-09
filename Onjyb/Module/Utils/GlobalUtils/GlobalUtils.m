//
//  GlobalUtils.m
//  PicaTalk
//
//  Created by LightSky on 7/5/14.
//  Copyright (c) 2014 Chris Ballinger. All rights reserved.



#import "GlobalUtils.h"


@implementation GlobalUtils

+ (BOOL)isLoggedIn{
    BOOL isLoggedIn = [[NSUserDefaults standardUserDefaults] boolForKey:global_key_is_logged_in];
    if (isLoggedIn) return YES;
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:global_key_is_logged_in];
    return NO;
}

+ (BOOL)validateEmailWithString:(NSString*)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}



#pragma mark SDWebImage

+ (void)setImageForUrlAndSize:(UIImageView*) imageOrg ID:(NSString *) ID url:(NSString *)iconURL size:(CGSize) imgSize placeImage:(NSString*) placeImage storeDir:(NSString*) storeDir
{
//    CGFloat ratio_cover_image = (imgSize.height/imgSize.width);
    if ([iconURL isEqual:[NSNull null]] || iconURL == nil || iconURL.length == 0) {
        [imageOrg setImage:[UIImage imageNamed:placeImage]];
        return;
    }
    if (iconURL.length > 0) {
        UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[NSString stringWithFormat:@"%@_%@",storeDir,ID]];
        if (cachedImage) {
//            UIImage *icon = [self imageWithImage:cachedImage scaledToSize:imgSize];
//            [imageOrg setImage:icon];
            
            [imageOrg setImage:cachedImage];

            return;
        }

        NSString * strUrl = [NSString stringWithFormat:@"%@",iconURL];
        
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:strUrl]
                                                              options:SDWebImageDownloaderUseNSURLCache
                                                             progress:nil
                                                            completed:
         ^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
             if (image && finished) {
                 
//                 CGSize size = image.size;
//                 
//                 CGFloat ratio = size.height/size.width;
//                 UIImage * zoomImage;
//                 if (ratio > ratio_cover_image) {
//                     
//                     CGSize sizeZoom = CGSizeMake(imgSize.width, imgSize.width/size.width * size.height);
//                     zoomImage = [self scaleImageToSize:image to:sizeZoom];
//                     
//                 }
//                 else {
//                     CGSize sizeZoom = CGSizeMake(imgSize.width * ratio_cover_image / size.height * size.width, imgSize.width * ratio_cover_image);
//                     zoomImage = [self scaleImageToSize:image to:sizeZoom];
//                 }
//                 UIImage * icon = [self imageByCroppingImage:zoomImage toSize:imgSize];
//                 
//                 [[SDImageCache sharedImageCache] storeImage:icon forKey:[NSString stringWithFormat:@"%@_%@",storeDir,ID] toDisk:YES];
//                 
//                 [imageOrg setImage:icon];
                 
                 [[SDImageCache sharedImageCache] storeImage:image forKey:[NSString stringWithFormat:@"%@_%@",storeDir,ID] toDisk:YES];
                 [imageOrg setImage:image];

             }
             else {
                 [imageOrg setImage:[UIImage imageNamed:placeImage]];
                 [[SDImageCache sharedImageCache] storeImage:imageOrg.image forKey:[NSString stringWithFormat:@"%@_%@",storeDir,ID] toDisk:YES];
             }
         }];
    }
}

+ (void)setButtonImgForUrlAndSize:(UIButton*) imageOrg ID:(NSString *) ID url:(NSString *)iconURL size:(CGSize) imgSize placeImage:(NSString*) placeImage storeDir:(NSString*) storeDir
{
    CGFloat ratio_cover_image = (imgSize.height/imgSize.width);
    if ([iconURL isEqual:[NSNull null]] || iconURL == nil || iconURL.length == 0) {
        [imageOrg setBackgroundImage:[UIImage imageNamed:placeImage] forState:UIControlStateNormal];
        return;
    }
    if (iconURL.length > 0) {
        UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[NSString stringWithFormat:@"%@_%@",storeDir,ID]];
        
        if (cachedImage) {
            UIImage *icon = [self imageWithImage:cachedImage scaledToSize:imgSize];
            [imageOrg setBackgroundImage:icon forState:UIControlStateNormal];
            return;
        }
        NSString * strUrl = [NSString stringWithFormat:@"%@",iconURL];
        
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:strUrl]
                                                              options:SDWebImageDownloaderUseNSURLCache
                                                             progress:nil
                                                            completed:
         ^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
             if (image && finished) {
                 
                 CGSize size = image.size;
                 
                 CGFloat ratio = size.height/size.width;
                 UIImage * zoomImage;
                 if (ratio > ratio_cover_image) {
                     
                     CGSize sizeZoom = CGSizeMake(imgSize.width, imgSize.width/size.width * size.height);
                     zoomImage = [self scaleImageToSize:image to:sizeZoom];
                     
                 }
                 else {
                     CGSize sizeZoom = CGSizeMake(imgSize.width * ratio_cover_image / size.height * size.width, imgSize.width * ratio_cover_image);
                     zoomImage = [self scaleImageToSize:image to:sizeZoom];
                 }
                 UIImage * icon = [self imageByCroppingImage:zoomImage toSize:imgSize];
                 
                 [[SDImageCache sharedImageCache] storeImage:icon forKey:[NSString stringWithFormat:@"%@_%@",storeDir,ID] toDisk:YES];
                 
                 [imageOrg setBackgroundImage:icon forState:UIControlStateNormal];
                 
                 
             }
             else {
                 [imageOrg setBackgroundImage:[UIImage imageNamed:placeImage] forState:UIControlStateNormal];
                 [[SDImageCache sharedImageCache] storeImage:imageOrg.currentBackgroundImage forKey:[NSString stringWithFormat:@"%@_%@",storeDir,ID] toDisk:YES];
             }
         }];
    }
}






+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
+ (UIImage *)imageByCroppingImage:(UIImage *)image toSize:(CGSize)size
{
    // not equivalent to image.size (which depends on the imageOrientation)!
    double refWidth = CGImageGetWidth(image.CGImage);
    double refHeight = CGImageGetHeight(image.CGImage);
    //    double refWidth = image.size.width;
    //    double refHeight = image.size.height;
    
    CGFloat ratiowidth = CGImageGetWidth(image.CGImage) / image.size.width;
    CGFloat ratioheight = CGImageGetHeight(image.CGImage) / image.size.height;
    
    
    double x = (refWidth - size.width * ratiowidth) / 2.0;
    double y = (refHeight - size.height * ratioheight) / 2.0;
    
    CGRect cropRect = CGRectMake(x, y, size.width * ratiowidth, size.height * ratioheight);
    
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    
    return cropped;
}

+ (UIImage *)scaleImageToSize:(UIImage*) image to:(CGSize)newSize {
    
    CGRect scaledImageRect = CGRectZero;
    
    CGFloat aspectWidth = newSize.width / image.size.width;
    CGFloat aspectHeight = newSize.height / image.size.height;
    CGFloat aspectRatio = MIN ( aspectWidth, aspectHeight );
    
    scaledImageRect.size.width = image.size.width * aspectRatio;
    scaledImageRect.size.height = image.size.height * aspectRatio;
    scaledImageRect.origin.x = (newSize.width - scaledImageRect.size.width) / 2.0f;
    scaledImageRect.origin.y = (newSize.height - scaledImageRect.size.height) / 2.0f;
    
    UIGraphicsBeginImageContextWithOptions( newSize, NO, 0 );
    [image drawInRect:scaledImageRect];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
    
}

+ (CGFloat)widthOfString:(NSString *)string withFont:(UIFont *)font {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}
+ (CGFloat)heightOfString:(NSString *)string withFont:(UIFont *)font {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].height;
}
#pragma mark - Save User Info

+ (void)saveUserObject:(User *)object key:(NSString *)key {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:key];
    [defaults synchronize];
    
}

+ (User *)loadUserObjectWithKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:key];
    User *object = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return object;
}

+ (void) showAlertController:(UIViewController*) view title:(NSString *) title message:(NSString*) message cancel:(NSString *) cancel{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                    {
                                        
                                    }];
    [alert addAction:defaultAction];
    [view presentViewController:alert animated:YES completion:nil];
}

@end
