//
//  AppDelegate.m
//  Onjyb
//
//  Created by Nadia Drabyk on 7/15/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import "AppDelegate.h"
#import "LeftMenuVC.h"
#import "RightMenuVC.h"
#import "HomeVC.h"
#import "LoginVC.h"

#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface AppDelegate ()

@end

@implementation AppDelegate


NSDictionary * g_dicProductMaster = nil;
NSString * g_strLastWorkedProjectName = @"";

int g_countUnreadMineHours;
int g_countUnreadApproveJobs;
int g_countUnreadCompleteTasks;
int g_countUnreadMessage;
NSMutableDictionary * g_dicExtraInfo = nil;
NSArray * g_leftCountDetails;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    

    if ([GlobalUtils isLoggedIn])
    {
        [self initHomeView];
        [self getUnreadCount];
        [self getMasterUpdated];

    }
    [self initSlideMenu];
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if ([GlobalUtils isLoggedIn])
    {
        [self getUnreadCount];
        [self getMasterUpdated];
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isOpeneRegisterTimeView"];

}
#pragma mark - Remote Notification Delegate // <= iOS 9.x

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSString *strDevicetoken = [[NSString alloc]initWithFormat:@"%@",[[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""]];
    NSLog(@"Device Token = %@",strDevicetoken);
//    self.strDeviceToken = strDevicetoken;
    
    NSString* Identifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString]; // IOS 6+

    User * user = [GlobalUtils loadUserObjectWithKey:global_user_info_save];
    if(!user)
        return;
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setObject:@"Onjyb" forKey:@"appname"];
    [param setObject:strDevicetoken forKey:@"devicetoken"];
    [param setObject:Identifier forKey:@"deviceuid"];
    [param setObject:@"iPhone" forKey:@"devicename"];
    
    NSString* model = [[UIDevice currentDevice] model];

    [param setObject:model forKey:@"devicemodel"];
    [param setObject:@"enabled" forKey:@"pushbadge"];
    [param setObject:@"enabled" forKey:@"pushalert"];
    [param setObject:@"enabled" forKey:@"pushsound"];
    [param setObject:@"onjyb" forKey:@"clientid"];
    [param setObject:user.strUserID forKey:@"memberid"];
//    [param setObject:@"sandbox" forKey:@"environment"];
    [param setObject:@"production" forKey:@"environment"];
    [param setObject:@"task" forKey:@"register"];
    [param setObject:@"iOS" forKey:@"os"];
    [param setObject:@"2.1" forKey:@"appversion"];
    
    NSString* ver = [[UIDevice currentDevice] systemVersion];
    [param setObject:ver forKey:@"deviceversion"];


    //////////
    [MyRequest POST:global_api_registerDevice parameters:param completed:^(id result)
     {
         NSDictionary * dicResult = (NSDictionary*) result;
         if (dicResult == NULL || [dicResult isEqual:[NSNull null]])
         {
             return;
         }
         else
         {
             NSNumber * numRes = [dicResult valueForKey:global_key_res_code];
             if (numRes)
             {
                 if (numRes.intValue == global_result_success)
                 {
                 }
                 return;
             }
         }
     }];

}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"Push Notification Information : %@",userInfo);
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"%@ = %@", NSStringFromSelector(_cmd), error);
    NSLog(@"Error = %@",error);
}

#pragma mark - UNUserNotificationCenter Delegate // >= iOS 10

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    
    NSLog(@"User Info = %@",notification.request.content.userInfo);
    
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
    
    NSLog(@"User Info = %@",response.notification.request.content.userInfo);
    completionHandler();
}

#pragma mark - Class Methods

/**
 Notification Registration
 */
- (void)registerForRemoteNotification {
    if(SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0")) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            if( !error ){
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            }
        }];
    }
    else {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}
#pragma mark - Init Slide Menu

- (void) initSlideMenu {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    
    LeftMenuVC *leftMenu = (LeftMenuVC*)[mainStoryboard
                                                                 instantiateViewControllerWithIdentifier: @"LeftMenuVC"];
    RightMenuVC *rightMenu = (RightMenuVC*)[mainStoryboard
                                         instantiateViewControllerWithIdentifier: @"RightMenuVC"];
    
    [SlideNavigationController sharedInstance].leftMenu = leftMenu;
    [SlideNavigationController sharedInstance].rightMenu = rightMenu;
    [SlideNavigationController sharedInstance].menuRevealAnimationDuration = .18;
    [SlideNavigationController sharedInstance].enableSwipeGesture = NO;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidClose object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSString *menu = note.userInfo[@"menu"];
        NSLog(@"Closed %@", menu);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidOpen object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSString *menu = note.userInfo[@"menu"];
        NSLog(@"Opened %@", menu);
        [leftMenu refreshTables];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidReveal object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSString *menu = note.userInfo[@"menu"];
        NSLog(@"Revealed %@", menu);
    }];
    
    
    id <SlideNavigationContorllerAnimator> revealAnimator;
    CGFloat animationDuration = 0;
    revealAnimator = [[SlideNavigationContorllerAnimatorScaleAndFade alloc] initWithMaximumFadeAlpha:.6 fadeColor:[UIColor blackColor] andMinimumScale:.8];
    animationDuration = .22;
    [SlideNavigationController sharedInstance].menuRevealAnimationDuration = animationDuration;
    [SlideNavigationController sharedInstance].menuRevealAnimator = revealAnimator;
    
}

#pragma mark - Utils

- (void) initLoginView {
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    SlideNavigationController * nav = [mainStoryboard instantiateViewControllerWithIdentifier:@"SlideNavigationController"];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
}

- (void) initHomeView {
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    HomeVC *vc;
    vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"HomeVC"];
//    SlideNavigationController * nav = [[SlideNavigationController alloc] initWithRootViewController:vc];
    SlideNavigationController * nav = [mainStoryboard instantiateViewControllerWithIdentifier:@"SlideNavigationController"];

    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    [nav pushViewController:vc animated:NO];
}

- (void) getUnreadCount {
    //MasterUpdatedList API
    
    User * user = [GlobalUtils loadUserObjectWithKey:global_user_info_save];
    
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setObject:user.strUserID forKey:global_key_user_id];
    [param setObject:user.strCompanyID forKey:global_key_company_id];
    [param setObject:user.strRefRoleID forKey:global_key_role_id];
    [param setObject:@"" forKey:global_key_last_date];
    

    //////////
    [MyRequest POST:global_api_getUnreadCount parameters:param completed:^(id result)
     {
         NSDictionary * dicResult = (NSDictionary*) result;
         if (dicResult == NULL || [dicResult isEqual:[NSNull null]])
         {
             return;
         }
         else
         {
             NSNumber * numRes = [dicResult valueForKey:global_key_res_code];
             if (numRes)
             {
                 if (numRes.intValue == global_result_success)
                 {
                     NSDictionary * dicResObject = [dicResult valueForKey:global_key_res_object];
                     if (dicResObject)
                     {
                         NSString * strMineHours = [dicResObject valueForKey:global_key_work_unread];
                         g_countUnreadMineHours = strMineHours.intValue;
                         NSString * strApproveJobs = [dicResObject valueForKey:global_key_work_manager_unread];
                         g_countUnreadApproveJobs = strApproveJobs.intValue;
                         NSString * strMessageJobs = [dicResObject valueForKey:global_key_message_unread];
                         g_countUnreadMessage = strMessageJobs.intValue;
                         NSString * strComplete = [dicResObject valueForKey:global_key_left_leave];
                         g_countUnreadCompleteTasks = strComplete.intValue;
                         g_leftCountDetails = [dicResObject valueForKey:global_key_left_count_details];

                     }
                 }
                 return;
             }
         }
     }];
}

- (void) getMasterUpdated {
    //MasterUpdatedList API
    
    User * user = [GlobalUtils loadUserObjectWithKey:global_user_info_save];
    
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setObject:user.strUserID forKey:global_key_user_id];
    //////////
    [MyRequest POST:global_api_getMasterList parameters:param completed:^(id result)
     {
         NSDictionary * dicResult = (NSDictionary*) result;
         if (dicResult == NULL || [dicResult isEqual:[NSNull null]])
         {
             return;
         }
         else
         {
             NSNumber * numRes = [dicResult valueForKey:global_key_res_code];
             if (numRes)
             {
                 if (numRes.intValue == global_result_success)
                 {
                     NSDictionary * dicResObject = [dicResult valueForKey:global_key_res_object];
                     if (dicResObject)
                     {
                         g_dicProductMaster = [NSDictionary dictionaryWithDictionary:dicResObject];
                     }
                 }
                 return;
             }
         }
     }];
}

- (void) getMasterTableDetails {
    User * user = [GlobalUtils loadUserObjectWithKey:global_user_info_save];
    
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setObject:user.strUserID forKey:global_key_user_id];
    [MyRequest POST:global_api_getUnreadCount parameters:param completed:^(id result)
     {
         NSDictionary * dicResult = (NSDictionary*) result;
         if (dicResult == NULL || [dicResult isEqual:[NSNull null]])
         {
             return;
         }
         else
         {
             NSNumber * numRes = [dicResult valueForKey:global_key_res_code];
             if (numRes)
             {
                 if (numRes.intValue == global_result_success)
                 {
                     NSDictionary * dicResObject = [dicResult valueForKey:global_key_res_object];
                     if (dicResObject)
                     {
                         
                     }
                 }
                 return;
             }
         }
     }];
}

#pragma mark ProgressHUD
- (void)showHUD{
    [self hideHUD];
    HUD=[MBProgressHUD showHUDAddedTo:self.window animated:YES];
    [HUD show:YES];
}
- (void)hideHUD{
    if (HUD){
        [HUD setHidden:YES];
        HUD = NULL;
    }
}

@end
