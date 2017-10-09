//
//  MyRequest.m
//  PatchPlay
//
//  Created by jin on 10/31/14.
//  Copyright (c) 2014 jin. All rights reserved.
//

#import "MyRequest.h"
#import "AppDelegate.h"


@implementation MyRequest

+(void) POST:(NSString*)strURL parameters:(NSDictionary *)parameters completed:(void(^)(id result))block{
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",strURL]]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    
    NSMutableString* strMut = [[NSMutableString alloc] init];
    for (NSString * key in parameters) {
        if (key) {
            if ([parameters valueForKey:key]) {
                [strMut appendString:[NSString stringWithFormat:@"%@=%@&", key, [parameters valueForKey:key]]];
            }
        }
    }
    NSRange rng;
    rng.location = 0;
    rng.length = strMut.length - 1;
    NSString * post = [NSString stringWithFormat:@"%@", [strMut substringWithRange:rng]];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request
     
                                       queue:[NSOperationQueue mainQueue]
     
                           completionHandler:^(NSURLResponse *response,
                                               
                                               NSData *data, NSError *connectionError)
     {
         if (data.length > 0 && connectionError == nil)
             
         {
             
             NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             NSData *datas = [newStr dataUsingEncoding:NSUTF8StringEncoding];
             id json = [NSJSONSerialization JSONObjectWithData:datas options:0 error:nil];
             
             if (block)
                 block(json);

             
         }
         else {
             if (block)
                 block(nil);
         }
     }];


    
}

+(void) POST:(NSString*)strURL parameters:(NSDictionary *)parameters imagePicked:(UIImage*) imagePicked strParamPhoto:(NSString*)strParamPhoto strNamePhoto:(NSString*) strNamePhoto completed:(void(^)(id result))block{
 
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:strURL]];
    [request setHTTPMethod:@"POST"];
    // [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSMutableData *body = [NSMutableData data];
    
    //[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    //[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // add params (all params are strings)
    for (NSString *param in parameters) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [parameters objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    if(imagePicked){
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", strParamPhoto, strNamePhoto] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type:application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        [body appendData:UIImageJPEGRepresentation(imagePicked, 1.0f)];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        
        //Close off the request with the boundary
        [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    }
    
    // setting the body of the post to the request
    [request setHTTPBody:body];
    
    [NSURLConnection sendAsynchronousRequest:request
     
                                       queue:[NSOperationQueue mainQueue]
     
                           completionHandler:^(NSURLResponse *response,
                                               
                                               NSData *data, NSError *connectionError)
     
     {
         if (data.length > 0 && connectionError == nil)
             
         {
             
             NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             NSData *datas = [newStr dataUsingEncoding:NSUTF8StringEncoding];
             id json = [NSJSONSerialization JSONObjectWithData:datas options:0 error:nil];
             
             if (block)
                 block(json);
             
             
         }
         else {
             if (block)
                 block(nil);
         }
     }];

    
    
}
+(void) POST_JSON:(NSString*)strURL parameters:(NSDictionary *)parameters imagePicked:(UIImage*) imagePicked strParamPhoto:(NSString*)strParamPhoto strNamePhoto:(NSString*) strNamePhoto completed:(void(^)(id result))block{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:strURL]];
    [request setHTTPMethod:@"POST"];
    // [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSMutableData *body = [NSMutableData data];
    
    //[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    //[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // add params (all params are strings)
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    NSData * jsonData1 = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    [body appendData:jsonData1];
//    for (NSString *param in parameters) {
//        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
//        
//        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [parameters objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
//    }
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", strParamPhoto, strNamePhoto] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type:application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:UIImageJPEGRepresentation(imagePicked, 1.0f)];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //Close off the request with the boundary
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the request
    [request setHTTPBody:body];
    
    [NSURLConnection sendAsynchronousRequest:request
     
                                       queue:[NSOperationQueue mainQueue]
     
                           completionHandler:^(NSURLResponse *response,
                                               
                                               NSData *data, NSError *connectionError)
     
     {
         if (data.length > 0 && connectionError == nil)
             
         {
             
             NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             NSData *datas = [newStr dataUsingEncoding:NSUTF8StringEncoding];
             id json = [NSJSONSerialization JSONObjectWithData:datas options:0 error:nil];
             
             if (block)
                 block(json);
             
             
         }
         else {
             if (block)
                 block(nil);
         }
     }];
    
    
    
}
+(void) IMAGE_POST_JSON:(NSString*)strURL parameters:(NSDictionary *)parameters imagePicked:(UIImage*) imagePicked strParamPhoto:(NSString*)strParamPhoto strNamePhoto:(NSString*) strNamePhoto completed:(void(^)(id result))block{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:strURL]];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSMutableData *body = [NSMutableData data];
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    NSData * jsonData1 = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    [body appendData:jsonData1];
      for (NSString *param in parameters) {
          [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
          [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
    
          [body appendData:[[NSString stringWithFormat:@"%@\r\n", [parameters objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
      }
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", strParamPhoto, strNamePhoto] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type:application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:UIImageJPEGRepresentation(imagePicked, 1.0f)];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //Close off the request with the boundary
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the request
    [request setHTTPBody:body];
    
    [NSURLConnection sendAsynchronousRequest:request
     
                                       queue:[NSOperationQueue mainQueue]
     
                           completionHandler:^(NSURLResponse *response,
                                               
                                               NSData *data, NSError *connectionError)
     
     {
         if (data.length > 0 && connectionError == nil)
         {
             
             NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             NSData *datas = [newStr dataUsingEncoding:NSUTF8StringEncoding];
             id json = [NSJSONSerialization JSONObjectWithData:datas options:0 error:nil];
             
             if (block)
                 block(json);
         }
         else {
             if (block)
                 block(nil);
         }
     }];
}


+(void) POST:(NSString*)strURL JSONParam:(NSDictionary *)parameters completed:(void(^)(id result))block{
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",strURL]]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    
    
    
    
    NSData * jsonData1 = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData1 length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData1];
    
    
    [NSURLConnection sendAsynchronousRequest:request
     
                                       queue:[NSOperationQueue mainQueue]
     
                           completionHandler:^(NSURLResponse *response,
                                               
                                               NSData *data, NSError *connectionError)
     
     {
         
         if (data.length > 0 && connectionError == nil)
             
         {
             
             NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             NSData *datas = [newStr dataUsingEncoding:NSUTF8StringEncoding];
             id json = [NSJSONSerialization JSONObjectWithData:datas options:0 error:nil];
             
             if (block)
                 block(json);
             
             
         }
         else {
             if (block)
                 block(nil);
         }
     }];
    
    
    
}


+(int)POST_Multipart:(NSData*)imgData param:(NSDictionary*)parameters url:(NSString*) strURL
{
    
    ASIFormDataRequest *uploadRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:strURL]];
    
    for (NSString * key in parameters) {
        if (key) {
            if ([parameters valueForKey:key]) {
                [uploadRequest setPostValue:[parameters valueForKey:key] forKey:key];
            }
        }
    }
    
    [uploadRequest setTimeOutSeconds:60*2]; //5min
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
    [uploadRequest setShouldContinueWhenAppEntersBackground:YES];
#endif
    
    [uploadRequest setData:imgData forKey:@"user_photo"];

    
    [uploadRequest startSynchronous];
    NSError *error = [uploadRequest error];
    if (!error) {
        NSString *response = [uploadRequest responseString];
        if ( response ) {
//            NSError *parseError = nil;
//            NSData *datas = [response dataUsingEncoding:NSUTF8StringEncoding];
//            id json = [NSJSONSerialization JSONObjectWithData:datas options:0 error:nil];
//            NSDictionary *xmlDictionary = [XMLReader dictionaryForXMLString:response error:&parseError];
//            NSDictionary *resultDict = [xmlDictionary valueForKey:@"result"];
//            NSString * res = [GlobalUtils stringTrimedNewLine:[[resultDict valueForKey:@"code"] valueForKey:@"text"]];
//            if ( res != nil && [res isEqualToString:@"Y"]) {
//                return 0;
//            }
            NSLog(@"yes");
        }
    }
    return -1;
}

@end
