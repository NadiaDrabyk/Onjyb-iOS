//
//  User.h
//  Kualita
//
//  Created by Nadia Drabyk on 4/12/17.
//
//

#import <Foundation/Foundation.h>
#import "Define.h"

@interface User : NSObject


+ (User*)sharedInstance;

@property (nonatomic, strong) NSString * strFirstName;
@property (nonatomic, strong) NSString * strLastName;
@property (nonatomic, strong) NSString * strCompanyID;
@property (nonatomic, strong) NSString * strURLCompanyLogo;
@property (nonatomic, strong) NSString * strCompanyName;
@property (nonatomic, strong) NSString * strEmail;

@property (nonatomic, strong) NSString * strUserID;
@property (nonatomic, strong) NSString * strMobile;
@property (nonatomic, strong) NSString * strURLProfile;
@property (nonatomic, strong) NSString * strRefRoleID;
@property (nonatomic, strong) NSString * strAddress;

- (User *) getUser:(NSDictionary *) dicInfo;

@end
