//
//  MineHoursVC.m
//  Onjyb
//
//  Created by Nadia Drabyk on 7/19/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import "MineHoursVC.h"
#import "ApprovedVC.h"
#import "PendingVC.h"
#import "NotApprovedVC.h"

@interface MineHoursVC ()

@end

@implementation MineHoursVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:AMLocalizedString(@"Mine hours", @"Mine hours")];
    
    UIView * viewPending = [[UIView alloc] initWithFrame:CGRectMake(global_screen_size.width / 3, global_screen_size.height / 2 - global_screen_size.width / 6 - 32, global_screen_size.width / 3, global_screen_size.width / 3)];
    [viewPending setBackgroundColor:[UIColor clearColor]];
    viewPending.layer.borderColor = global_nav_color.CGColor;
    viewPending.layer.borderWidth = 2.f;
    
    UIImageView * imgPending = [[UIImageView alloc] initWithFrame:CGRectMake(viewPending.frame.size.width * 3 / 8, viewPending.frame.size.width / 3 - viewPending.frame.size.width / 8, viewPending.frame.size.width / 4, viewPending.frame.size.width / 4)];
    [imgPending setImage:[UIImage imageNamed:@"pending"]];
    [viewPending addSubview:imgPending];
    
    UILabel * lblPending = [[UILabel alloc] initWithFrame:CGRectMake(0, viewPending.frame.size.width / 2, viewPending.frame.size.width, viewPending.frame.size.height / 2)];
    [lblPending setText:AMLocalizedString(@"Pending", @"Pending")];
    [lblPending setTextColor:global_nav_color];
    [lblPending setTextAlignment:NSTextAlignmentCenter];
    [lblPending setNumberOfLines:0];
    [viewPending addSubview:lblPending];
    
    UIButton * btnPending = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, viewPending.frame.size.width, viewPending.frame.size.height)];
    [btnPending setBackgroundColor:[UIColor clearColor]];
    [btnPending addTarget:self action:@selector(onPending) forControlEvents:UIControlEventTouchUpInside];
    [viewPending addSubview:btnPending];
    
    [self.view addSubview:viewPending];
    
    CGFloat pad = 30.f;
    if (global_screen_size.width < 330) {
        pad = 20.f;
    }
    lblBadgePending = [[UILabel alloc] initWithFrame:CGRectMake(viewPending.frame.origin.x + viewPending.frame.size.height - pad / 2, viewPending.frame.origin.y - pad / 2, pad, pad)];
    [lblBadgePending setBackgroundColor:global_red_color];
    [lblBadgePending setTextColor:[UIColor whiteColor]];
    lblBadgePending.layer.cornerRadius = lblBadgePending.frame.size.height / 2;
    lblBadgePending.layer.masksToBounds = YES;
    lblBadgePending.hidden = YES;
    [lblBadgePending setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:lblBadgePending];
    
    UIView * viewApproved = [[UIView alloc] initWithFrame:CGRectMake(global_screen_size.width / 3, viewPending.frame.origin.y - viewPending.frame.size.height - pad, global_screen_size.width / 3, global_screen_size.width / 3)];
    [viewApproved setBackgroundColor:[UIColor clearColor]];
    viewApproved.layer.borderColor = global_green_color.CGColor;
    viewApproved.layer.borderWidth = 2.f;
    
    UIImageView * imgApproved = [[UIImageView alloc] initWithFrame:CGRectMake(viewPending.frame.size.width * 3 / 8, viewPending.frame.size.width / 3 - viewPending.frame.size.width / 8, viewPending.frame.size.width / 4, viewPending.frame.size.width / 4)];
    [imgApproved setImage:[UIImage imageNamed:@"approved"]];
    [viewApproved addSubview:imgApproved];
    
    UILabel * lblApproved = [[UILabel alloc] initWithFrame:CGRectMake(0, viewPending.frame.size.width / 2, viewPending.frame.size.width, viewPending.frame.size.height / 2)];
    [lblApproved setText:AMLocalizedString(@"Approved", @"Approved")];
    [lblApproved setTextColor:global_green_color];
    [lblApproved setTextAlignment:NSTextAlignmentCenter];
    [viewApproved addSubview:lblApproved];
    
    UIButton * btnApproved = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, viewPending.frame.size.width, viewPending.frame.size.height)];
    [btnApproved setBackgroundColor:[UIColor clearColor]];
    [btnApproved addTarget:self action:@selector(onApproved) forControlEvents:UIControlEventTouchUpInside];
    [viewApproved addSubview:btnApproved];
    
    [self.view addSubview:viewApproved];
    lblBadgeApproved = [[UILabel alloc] initWithFrame:CGRectMake(viewApproved.frame.origin.x + viewApproved.frame.size.height - pad / 2, viewApproved.frame.origin.y - pad / 2, pad, pad)];
    [lblBadgeApproved setBackgroundColor:global_red_color];
    [lblBadgeApproved setTextColor:[UIColor whiteColor]];
    lblBadgeApproved.layer.cornerRadius = lblBadgePending.frame.size.height / 2;
    lblBadgeApproved.layer.masksToBounds = YES;
    [lblBadgeApproved setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:lblBadgeApproved];
    lblBadgeApproved.hidden = YES;

    
    UIView * viewNotApproved = [[UIView alloc] initWithFrame:CGRectMake(global_screen_size.width / 3, viewPending.frame.origin.y + viewPending.frame.size.height + pad, global_screen_size.width / 3, global_screen_size.width / 3)];
    [viewNotApproved setBackgroundColor:[UIColor clearColor]];
    viewNotApproved.layer.borderColor = global_red_color.CGColor;
    viewNotApproved.layer.borderWidth = 2.f;
    
    UIImageView * imgNotApproved = [[UIImageView alloc] initWithFrame:CGRectMake(viewPending.frame.size.width * 3 / 8, viewPending.frame.size.width / 3 - viewPending.frame.size.width / 8, viewPending.frame.size.width / 4, viewPending.frame.size.width / 4)];
    [imgNotApproved setImage:[UIImage imageNamed:@"not-approved"]];
    [viewNotApproved addSubview:imgNotApproved];
    
    UILabel * lblNotApproved = [[UILabel alloc] initWithFrame:CGRectMake(4, viewPending.frame.size.width / 2, viewPending.frame.size.width - 8, viewPending.frame.size.height / 2)];
    [lblNotApproved setText:AMLocalizedString(@"Not Approved", @"Not Approved")];
    [lblNotApproved setTextColor:global_red_color];
    [lblNotApproved setTextAlignment:NSTextAlignmentCenter];
    [lblNotApproved setNumberOfLines:0];

    [viewNotApproved addSubview:lblNotApproved];
    
    UIButton * btnNotApproved = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, viewPending.frame.size.width, viewPending.frame.size.height)];
    [btnNotApproved setBackgroundColor:[UIColor clearColor]];
    [btnNotApproved addTarget:self action:@selector(onNotApproved) forControlEvents:UIControlEventTouchUpInside];
    [viewNotApproved addSubview:btnNotApproved];
    
    [self.view addSubview:viewNotApproved];
    
    lblBadgeNotApproved = [[UILabel alloc] initWithFrame:CGRectMake(viewNotApproved.frame.origin.x + viewNotApproved.frame.size.height - pad / 2, viewNotApproved.frame.origin.y - pad / 2, pad, pad)];
    [lblBadgeNotApproved setBackgroundColor:global_red_color];
    [lblBadgeNotApproved setTextColor:[UIColor whiteColor]];
    lblBadgeNotApproved.layer.cornerRadius = lblBadgePending.frame.size.height / 2;
    lblBadgeNotApproved.layer.masksToBounds = YES;
    [self.view addSubview:lblBadgeNotApproved];
    lblBadgeNotApproved.hidden = YES;
    [lblBadgeNotApproved setTextAlignment:NSTextAlignmentCenter];

    dimView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, global_screen_size.width, global_screen_size.height)];
    [dimView setBackgroundColor:[UIColor blackColor]];
    [dimView setAlpha:0.6];
    [self.view addSubview:dimView];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    
    [self getUnreadCount];
//    m_nApproved = 0;
//    m_nPending = 0;
//    m_nNotApproved = 0;
    [self refreshBadge];
    
//    [self getTaskList];//
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openMenu:) name:global_notification_slide_open object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(revealMenu:) name:global_notification_slide_reveal object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeMenu:) name:global_notification_slide_close object:nil];
    [dimView setHidden:YES];
    [lblBadgePending setText:[NSString stringWithFormat:@"%d", g_countUnreadMineHours]];
    if (global_screen_size.width < 330)
    {
        [lblBadgeApproved setFont:[UIFont systemFontOfSize:15.f]];
        [lblBadgePending setFont:[UIFont systemFontOfSize:15.f]];
        [lblBadgeNotApproved setFont:[UIFont systemFontOfSize:15.f]];
    }
    else
    {
        [lblBadgeApproved setFont:[UIFont systemFontOfSize:17.f]];
        [lblBadgePending setFont:[UIFont systemFontOfSize:17.f]];
        [lblBadgeNotApproved setFont:[UIFont systemFontOfSize:17.f]];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:global_notification_slide_close object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:global_notification_slide_open object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:global_notification_slide_reveal object:nil];
}

- (void)refreshBadge{
    
    lblBadgeApproved.hidden = YES;
    lblBadgePending.hidden = YES;
    lblBadgeNotApproved.hidden = YES;

        if(g_countUnreadMineHours > 0){
            lblBadgePending.hidden = NO;
            [lblBadgePending setText:[NSString stringWithFormat:@"%d", g_countUnreadMineHours]];
        }

//    if(m_nApproved > 0){
//        lblBadgeApproved.hidden = NO;
//        [lblBadgeApproved setText:[NSString stringWithFormat:@"%d", m_nApproved]];
//    }
//    if(m_nPending > 0){
//        lblBadgePending.hidden = NO;
//        [lblBadgePending setText:[NSString stringWithFormat:@"%d", m_nPending]];
//    }
//    if(m_nNotApproved > 0){
//        lblBadgeNotApproved.hidden = NO;
//        [lblBadgeNotApproved setText:[NSString stringWithFormat:@"%d", m_nNotApproved]];
//    }
    
}
#pragma mark - Button Actions
- (IBAction)onMenu:(id)sender
{
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
}

- (void) onPending {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    PendingVC * vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"PendingVC"];
//    vc.mAryTaskList = mAryPending;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) onApproved {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    ApprovedVC * vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"ApprovedVC"];
//    vc.mAryTaskList = mAryApproved;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) onNotApproved {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    NotApprovedVC * vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"NotApprovedVC"];
//    vc.mAryTaskList = mAryNotApproved;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - SlideNavigationController Methods -

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

#pragma mark -Notification

- (void)openMenu:(NSNotification*) noti {
    [dimView setAlpha:0.6];
    [dimView setHidden:NO];
}
- (void)closeMenu:(NSNotification*) noti {
    
    [dimView setAlpha:0.0];
    [dimView setHidden:YES];
}
- (void)revealMenu:(NSNotification*) noti {
    NSDictionary * dicProgress = (NSDictionary*) noti.object;
    if (dicProgress == NULL || [dicProgress isEqual:[NSNull null]]) {
        return;
    }
    NSString * strProgress = [dicProgress valueForKey:global_key_slide_progress];
    if (strProgress && strProgress.length > 0) {
        [dimView setAlpha:strProgress.floatValue/2+ 0.1];
        [dimView setHidden:NO];
    }
}

#pragma mark - Utils
- (void) getUnreadCount {
    
    AppDelegate * app = (AppDelegate*) [UIApplication sharedApplication].delegate;
    [app showHUD];

    User * user = [GlobalUtils loadUserObjectWithKey:global_user_info_save];
    
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setObject:user.strUserID forKey:global_key_user_id];
    [param setObject:user.strCompanyID forKey:global_key_company_id];
    [param setObject:user.strRefRoleID forKey:global_key_role_id];
    [param setObject:@"" forKey:global_key_last_date];
    
    //////////
    [MyRequest POST:global_api_getUnreadCount parameters:param completed:^(id result)
     {
         [app hideHUD];
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
                         [lblBadgePending setText:[NSString stringWithFormat:@"%d", g_countUnreadMineHours]];
                         g_leftCountDetails = [dicResObject valueForKey:global_key_left_count_details];

                     }
                     [self refreshBadge];
                 }
                 return;
             }
         }
     }];
}

- (void) getTaskList {
    User * user = [GlobalUtils loadUserObjectWithKey:global_user_info_save];
    
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setObject:@"YES" forKey:global_key_is_mng_jobber];
    [param setObject:user.strUserID forKey:global_key_user_id];
    [param setObject:user.strCompanyID forKey:global_key_company_id];
    [param setObject:@"" forKey:global_key_is_summary];
    [param setObject:user.strRefRoleID forKey:global_key_role_id];
    [param setObject:@"" forKey:global_key_approve_status];
    [param setObject:@"1" forKey:global_key_page_number];

    //////////
    [MyRequest POST:global_api_getMyTaskList parameters:param completed:^(id result)
     {
         NSDictionary * dicResult = (NSDictionary*) result;
         if (dicResult == NULL || [dicResult isEqual:[NSNull null]])
         {
             [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Could not connect with server. Please try again later!", @"Could not connect with server. Please try again later!") cancel:AMLocalizedString(@"Ok", @"Ok")];
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
                         NSArray* ary = [dicResObject objectForKey:global_key_work_details];
                         if (ary && ary.count){
//                             m_nApproved = 0;
//                             m_nPending = 0;
//                             m_nNotApproved = 0;
//                             
//                             mAryApproved = [[NSMutableArray alloc] init];
//                             mAryPending = [[NSMutableArray alloc] init];
//                             mAryNotApproved = [[NSMutableArray alloc] init];
//
//                             for(NSDictionary* dic in ary){
//                                 NSString* approve_status = [dic objectForKey:global_key_approve_status];
//                                 if([approve_status isEqualToString:@"reject"]){
//                                     m_nNotApproved++;
//                                     [mAryNotApproved addObject:dic];
//                                 }else if([approve_status isEqualToString:@"approve"]){
//                                     m_nApproved++;
//                                     [mAryApproved addObject:dic];
//                                 }else if([approve_status isEqualToString:@"pendding"]){
//                                     m_nPending++;
//                                     [mAryPending addObject:dic];
//                                 }
//                             }
                         }
                         [self refreshBadge];
                     }
                 }
                 return;
             }
             NSString * errorString = AMLocalizedString(@"Error occured.", @"Error occured.");
             if ([dicResult valueForKey:global_key_res_message])
             {
                 errorString = [NSString stringWithFormat:@"%@", [dicResult valueForKey:global_key_res_message]];
             }
             [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:errorString cancel:AMLocalizedString(@"Ok", @"Ok")];
             return;
         }
         NSString * errorString = AMLocalizedString(@"Error occured.", @"Error occured.");
         [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:errorString cancel:AMLocalizedString(@"Ok", @"Ok")];
     }];
}

@end
