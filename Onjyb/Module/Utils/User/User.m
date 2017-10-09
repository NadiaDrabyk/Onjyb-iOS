//
//  User.m
//  Kualita
//
//  Created by Nadia Drabyk on 4/12/17.
//
//

#import "User.h"

@implementation User 


@synthesize strFirstName, strLastName, strCompanyID, strURLCompanyLogo, strEmail, strCompanyName, strUserID, strMobile, strURLProfile, strRefRoleID, strAddress;


static User *instance = nil;

- (void) dealloc
{
    
}

-(id)init
{
    self = [super init];
    if(self)
    {
        

    }
    
    return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc

    [encoder encodeObject:strCompanyID forKey:global_key_company_id];
    [encoder encodeObject:strURLCompanyLogo forKey:global_key_company_logo];
    [encoder encodeObject:strCompanyName forKey:global_key_company_name];
    [encoder encodeObject:strEmail forKey:global_key_email];
    [encoder encodeObject:strFirstName forKey:global_key_first_name];
    [encoder encodeObject:strUserID forKey:global_key_id];
    [encoder encodeObject:strLastName forKey:global_key_last_name];
    [encoder encodeObject:strMobile forKey:global_key_mobile];
    [encoder encodeObject:strURLProfile forKey:global_key_profile_image];
    [encoder encodeObject:strRefRoleID forKey:global_key_ref_role_id];
    [encoder encodeObject:strAddress forKey:global_key_address];
    
    
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        
        strCompanyID = [decoder decodeObjectForKey:global_key_company_id];
        strURLCompanyLogo = [decoder decodeObjectForKey:global_key_company_logo];
        strCompanyName = [decoder decodeObjectForKey:global_key_company_name];
        strEmail = [decoder decodeObjectForKey:global_key_email];
        strFirstName = [decoder decodeObjectForKey:global_key_first_name];
        strUserID = [decoder decodeObjectForKey:global_key_id];
        strLastName = [decoder decodeObjectForKey:global_key_last_name];
        strMobile = [decoder decodeObjectForKey:global_key_mobile];
        strURLProfile = [decoder decodeObjectForKey:global_key_profile_image];
        strRefRoleID = [decoder decodeObjectForKey:global_key_ref_role_id];
        strAddress = [decoder decodeObjectForKey:global_key_address];
        
    }
    return self;
}

#pragma mark Singleton Object Methods

+ (User*)sharedInstance {
    @synchronized(self) {
        if (instance == nil) {
            instance = [[self alloc] init];
        }
    }
    return instance;
}

#pragma mark- SetUser

- (User *) getUser:(NSDictionary *) dicInfo{
    strCompanyID = [dicInfo valueForKey:global_key_company_id];
    if ([self isNIL:strCompanyID]) strCompanyID = @"";
    
    if ([strCompanyID isKindOfClass:[NSNumber class]]) {
        NSNumber * numID = [dicInfo valueForKey:global_key_company_id];
        strCompanyID = numID.stringValue;
    }
    
    strURLCompanyLogo = [dicInfo valueForKey:global_key_company_logo];
    if ([self isNIL:strURLCompanyLogo]) strURLCompanyLogo = @"";
    
    strFirstName = [dicInfo valueForKey:global_key_first_name];
    if ([self isNIL:strFirstName]) strFirstName = @"";
    
    strLastName = [dicInfo valueForKey:global_key_last_name];
    if ([self isNIL:strLastName]) strLastName = @"";
    
    strCompanyName = [dicInfo valueForKey:global_key_company_name];
    if ([self isNIL:strCompanyName]) strCompanyName = @"";
    
    NSNumber * userIDNum = [dicInfo valueForKey:global_key_id];
    if (![self isNIL:userIDNum]) {
        if ([userIDNum isKindOfClass:[NSString class]]) {
            NSString * tmp = [dicInfo valueForKey:global_key_id];
            strUserID = tmp;
        }
        else
            strUserID = userIDNum.stringValue;
    }
    else {
        strUserID = @"";
    }
    
    NSNumber * refIDNum = [dicInfo valueForKey:global_key_ref_role_id];
    if (![self isNIL:refIDNum]) {
        if ([refIDNum isKindOfClass:[NSString class]]) {
            NSString * tmp = [dicInfo valueForKey:global_key_ref_role_id];
            strRefRoleID = tmp;
        }
        else
            strRefRoleID = refIDNum.stringValue;
    }
    else {
        strRefRoleID = @"";
    }
    
    strEmail = [dicInfo valueForKey:global_key_email];
    if ([self isNIL:strEmail]) strEmail = @"";
    
    strMobile = [dicInfo valueForKey:global_key_mobile];
    if ([self isNIL:strMobile]) strMobile = @"";
    
    strAddress = [dicInfo valueForKey:global_key_address];
    if ([self isNIL:strMobile]) strAddress = @"";
    
    NSLog(@"OK");
    return self;
    
}

- (BOOL) isNIL:(id) value {
    if (value == nil || [value isEqual:[NSNull null]])
        return YES;
    return NO;
}



@end
