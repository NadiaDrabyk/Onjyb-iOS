//
//  MyRequest.h
//  PatchPlay
//
//  Created by jin on 10/31/14.
//  Copyright (c) 2014 jin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"
#import "ASIFormDataRequest.h"
//#import "XMLReader.h"

@interface MyRequest : NSObject

+(void) POST:(NSString*)strURL parameters:(NSDictionary *)parameters completed:(void(^)(id result))block;

+(void) POST:(NSString*)strURL parameters:(NSDictionary *)parameters imagePicked:(UIImage*) imagePicked strParamPhoto:(NSString*)strParamPhoto strNamePhoto:(NSString*) strNamePhoto completed:(void(^)(id result))block;

+(void) POST:(NSString*)strURL JSONParam:(NSDictionary *)parameters completed:(void(^)(id result))block;
+(int)POST_Multipart:(NSData*)imgData param:(NSDictionary*)parameters url:(NSString*) strURL;
+(void) POST_JSON:(NSString*)strURL parameters:(NSDictionary *)parameters imagePicked:(UIImage*) imagePicked strParamPhoto:(NSString*)strParamPhoto strNamePhoto:(NSString*) strNamePhoto completed:(void(^)(id result))block;

+(void) IMAGE_POST_JSON:(NSString*)strURL parameters:(NSDictionary *)parameters imagePicked:(UIImage*) imagePicked strParamPhoto:(NSString*)strParamPhoto strNamePhoto:(NSString*) strNamePhoto completed:(void(^)(id result))block;

@end
