//
//  AppDelegate.h
//  Onjyb
//
//  Created by Nadia Drabyk on 7/15/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Define.h"
#import "LocalizationSystem.h"
#import "GlobalUtils.h"
#import "Global.h"
#import "SlideNavigationController.h"
#import "SlideNavigationContorllerAnimatorScaleAndFade.h"
#import "MyRequest.h"
#import "MBProgressHUD.h"
#import "User.h"
#import "SimpleBarChart.h"
#import "UIImage+Resize.h"
#import "UIImage+RoundedCorner.h"
#import "UIImage+Alpha.h"
#import "SDImageCache.h"
#import "LeftMenuVC.h"

#import <UserNotifications/UserNotifications.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate> {
    MBProgressHUD * HUD;
}

@property (strong, nonatomic) UIWindow *window;

- (void) initLoginView;
- (void) initHomeView;
- (void) initSlideMenu;
- (void) showHUD;
- (void) hideHUD;

- (void) registerForRemoteNotification;
@end

