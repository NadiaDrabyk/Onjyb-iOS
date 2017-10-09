//
//  LocalizationSystem.h
//  Battle of Puppets
//
//  Created by Juan Albero Sanchis on 27/02/10.
//  Copyright Aggressive Mediocrity 2010. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Global.h"

//#define AMLocalizedString(key, comment) \
//[[LocalizationSystem sharedLocalSystem] localizedStringForKey:(key) value:(comment)]
#define AMLocalizedString(key, comment) \
    NSLocalizedString(key, comment)


#define AMLocalizedStringOk \
    AMLocalizedString(@"ok", @"Ok")

#define AMLocalizedStringCancel \
    AMLocalizedString(@"cancel", @"Cancel")

#define AMLocalizedStringDone \
    AMLocalizedString(@"done", @"Done")

#define AMLocalizedStringSave \
AMLocalizedString(@"save", @"Save")


#define AMLocalizedStringAlert \
    AMLocalizedString(@"alert", @"Alert")

#define AMLocalizedStringNext \
    AMLocalizedString(@"btn_next", @"Next")

#define AMLocalizedStringBack \
    AMLocalizedString(@"btn_back", @"Back")



#define LocalizationSetLanguage(language) \
[[LocalizationSystem sharedLocalSystem] setLanguage:(language)]

#define LocalizationGetLanguage \
[[LocalizationSystem sharedLocalSystem] getLanguage]

#define LocalizationReset \
[[LocalizationSystem sharedLocalSystem] resetLocalization]

@interface LocalizationSystem : NSObject {
	NSString *language;
}

// you really shouldn't care about this functions and use the MACROS
+ (LocalizationSystem *)sharedLocalSystem;

//gets the string localized
- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)comment;

//sets the language
- (void) setLanguage:(NSString*) language;

//gets the current language
- (NSString*) getLanguage;

//resets this system.
- (void) resetLocalization;

@end
