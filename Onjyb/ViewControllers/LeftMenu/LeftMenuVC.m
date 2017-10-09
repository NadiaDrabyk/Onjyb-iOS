//
//  LeftMenuVC.m
//  Onjyb
//
//  Created by Nadia Drabyk on 7/16/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import "LeftMenuVC.h"

@interface LeftMenuVC ()

@end

@implementation LeftMenuVC

@synthesize imgProfile, imgCompany;

#define cell_home                       0
#define cell_mytask                     1
#define cell_minehours                  2
#define cell_registertime               3
#define cell_myleaves                   4
#define cell_requestleave               5
#define cell_statistics                 6
#define cell_groupchat                  7
#define cell_aboutapp                   8

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self.slideOutAnimationEnabled = YES;
    
    return [super initWithCoder:aDecoder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_tblView setBackgroundColor:global_nav_color];
    [viewBottom setBackgroundColor:global_nav_color];
    User * user = [GlobalUtils loadUserObjectWithKey:global_user_info_save];
    
    CGFloat topViewHeight = global_screen_size.width * 31 / 75;
    imgProfile = [[UIImageView alloc] initWithFrame:CGRectMake(22, topViewHeight * 4 / 16, topViewHeight * 4 / 8, topViewHeight * 4 / 8)];
    imgProfile.layer.cornerRadius = imgProfile.frame.size.height / 2;
    imgProfile.layer.borderColor = global_nav_color.CGColor;
    imgProfile.layer.borderWidth = 1.f;
    imgProfile.layer.masksToBounds = YES;
    
    [GlobalUtils setImageForUrlAndSize:imgProfile ID:user.strURLProfile url:[NSString stringWithFormat:@"%@%@", global_url_photo, user.strURLProfile] size:imgProfile.frame.size placeImage:@"avatar" storeDir:global_dir_profile];
    
//    imgCompany = [[UIImageView alloc] initWithFrame:CGRectMake(imgProfile.frame.origin.x + imgProfile.frame.size.width + 22,
//                                                               imgProfile.frame.size.width / 2 + imgProfile.frame.origin.y - imgProfile.frame.size.width / 3,
//                                                               imgProfile.frame.size.width * 1.5,
//                                                               imgProfile.frame.size.width / 3)];
    
    imgCompany = [[UIImageView alloc] initWithFrame:CGRectMake(imgProfile.frame.origin.x + imgProfile.frame.size.width + 22,
                                                               imgProfile.frame.origin.y,
                                                               imgProfile.frame.size.width * 1.5,
                                                               imgProfile.frame.size.height - 25)];

    imgCompany.contentMode = UIViewContentModeScaleAspectFit;//20170818
    
//    lblName = [[UILabel alloc] initWithFrame:CGRectMake(imgCompany.frame.origin.x, imgCompany.frame.size.height + imgCompany.frame.origin.y, 250, imgCompany.frame.size.height)];
    lblName = [[UILabel alloc] initWithFrame:CGRectMake(imgCompany.frame.origin.x, imgCompany.frame.size.height + imgCompany.frame.origin.y, 250, 25)];

    [lblName setText:[NSString stringWithFormat:@"%@ %@", user.strFirstName, user.strLastName]];
    [lblName setTextColor:global_nav_color];
    
    [GlobalUtils setImageForUrlAndSize:imgCompany ID:user.strURLCompanyLogo url:[NSString stringWithFormat:@"%@%@", global_url_photo, user.strURLCompanyLogo] size:imgCompany.frame.size placeImage:@"" storeDir:global_dir_company];
    
    lblPhone = [[UILabel alloc] initWithFrame:CGRectMake(lblName.frame.origin.x, lblName.frame.origin.y + lblName.frame.size.height, lblName.frame.size.width, lblName.frame.size.height)];
    [lblPhone setTextColor:global_nav_color];
    [lblPhone setText:user.strMobile];
    
    [viewTop addSubview:imgProfile];
    [viewTop addSubview:imgCompany];
    [viewTop addSubview:lblName];
    [viewTop addSubview:lblPhone];
    
    if (global_screen_size.width < 330)
    {
        [lblName setFont:[UIFont boldSystemFontOfSize:15.f]];
        [lblPhone setFont:[UIFont boldSystemFontOfSize:15.f]];
        
    }
    else {
        [lblName setFont:[UIFont boldSystemFontOfSize:17.f]];
        [lblPhone setFont:[UIFont boldSystemFontOfSize:17.f]];
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) refreshTables{
    [self getUnreadCount];

}
- (void) viewWillAppear:(BOOL)animated {
    [self refreshTables];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshProfiles) name:global_notification_slide_open object:nil];
    
    if (global_screen_size.width < 330)
    {
        [btnLogout.titleLabel setFont:[UIFont systemFontOfSize:global_font_button_normal_iphone5]];
    }
    
    [btnLogout setTitle:AMLocalizedString(@"Logout", @"Logout") forState:UIControlStateNormal];
    btnLogout.layer.cornerRadius = 4.f;
    btnLogout.layer.masksToBounds = YES;
    
    cellHeight = global_screen_size.height / 15;
    
}

- (void) viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:global_notification_slide_open object:nil];
}

#pragma mark - Table View Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 9;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPah
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"leftMenuCell"];
    
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"leftMenuCell"];
    }
    [cell.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    UIImageView * img = [[UIImageView alloc] initWithFrame:CGRectMake(22, cellHeight / 4, cellHeight / 2, cellHeight / 2)];
    UILabel * lbl = [[UILabel alloc] initWithFrame:CGRectMake(img.frame.origin.x + img.frame.size.width + 22, 0, 250, cellHeight)];
    
    [lbl setTextColor:[UIColor whiteColor]];

    [lbl setBackgroundColor:[UIColor clearColor]];
    
    [cell addSubview:img];
    [cell addSubview:lbl];
    
    UILabel * lblUnreadMyTask = [[UILabel alloc] initWithFrame:CGRectMake(global_screen_size.width - 60 - 10 - global_screen_size.width / 8.5, cellHeight / 4, global_screen_size.width / 8.5, cellHeight / 2)];
    [lblUnreadMyTask setBackgroundColor:global_red_color];
    [lblUnreadMyTask setTextColor:[UIColor whiteColor]];
    lblUnreadMyTask.layer.cornerRadius = 5.f;
    if (g_countUnreadApproveJobs == 0 && g_countUnreadCompleteTasks == 0)
    {
        [lblUnreadMyTask setHidden:YES];
    }
    else
    {
        [lblUnreadMyTask setHidden:NO];
        [lblUnreadMyTask setText:[NSString stringWithFormat:@"%d | %d", g_countUnreadApproveJobs, g_countUnreadCompleteTasks]];
    }
    [lblUnreadMyTask setTextAlignment:NSTextAlignmentCenter];
    lblUnreadMyTask.layer.masksToBounds = YES;
    
    UILabel * lblUnreadMinehours = [[UILabel alloc] initWithFrame:CGRectMake(global_screen_size.width - 60 - 10 - cellHeight / 2, cellHeight / 4, cellHeight / 2, cellHeight / 2)];
    [lblUnreadMinehours setTextColor:[UIColor whiteColor]];
//    if (g_countUnreadMineHours == 0)
    {
        [lblUnreadMinehours setHidden:YES];
    }
//    else
//    {
//        [lblUnreadMinehours setHidden:NO];
//        [lblUnreadMinehours setText:[NSString stringWithFormat:@"%d", g_countUnreadMineHours]];
//    }
    [lblUnreadMinehours setBackgroundColor:global_red_color];
    [lblUnreadMinehours setTextAlignment:NSTextAlignmentCenter];
    lblUnreadMinehours.layer.cornerRadius = cellHeight / 4;
    lblUnreadMinehours.layer.masksToBounds = YES;
    
    if (global_screen_size.width < 330) {
        [lbl setFont:[UIFont systemFontOfSize:global_font_label_normal_iphone5]];
        [lblUnreadMyTask setFont:[UIFont systemFontOfSize:global_font_label_normal_iphone5 - 2.f]];
        [lblUnreadMinehours setFont:[UIFont systemFontOfSize:global_font_label_normal_iphone5 - 2.f]];
        
    }
    else {
        [lbl setFont:[UIFont systemFontOfSize:global_font_label_normal_iphone6]];
        [lblUnreadMyTask setFont:[UIFont systemFontOfSize:global_font_label_normal_iphone6 - 2.f]];
        [lblUnreadMinehours setFont:[UIFont systemFontOfSize:global_font_label_normal_iphone6 - 2.f]];
    }
    
    UIView * viewSep = [[UIView alloc] initWithFrame:CGRectMake(22, global_screen_size.height / 15 - 1, global_screen_size.width - 22 - 58, 1)];
    [viewSep setBackgroundColor:[UIColor colorWithRed:236/255.f green:236/255.f blue:236/255.f alpha:1.f]];
    [cell addSubview:viewSep];
    
    switch (indexPah.row)
    {
        case cell_home:
        {
            [img setImage:[UIImage imageNamed:@"MyTask"]];
            [lbl setText:AMLocalizedString(@"Home", @"Home")];
        }
            break;
        case cell_mytask:
        {
            [img setImage:[UIImage imageNamed:@"MyTask"]];
            [lbl setText:AMLocalizedString(@"My Task", @"My Task")];
            [cell addSubview:lblUnreadMyTask];
        }
            break;
        case cell_minehours:
        {
            [img setImage:[UIImage imageNamed:@"MyTask"]];
            [lbl setText:AMLocalizedString(@"Mine hours", @"Mine hours")];
            [cell addSubview:lblUnreadMinehours];
        }
            break;
        case cell_registertime:
        {
            [img setImage:[UIImage imageNamed:@"RegisterTime"]];
            [lbl setText:AMLocalizedString(@"Register Time", @"Register Time")];
        }
            break;
        case cell_myleaves:
        {
            [img setImage:[UIImage imageNamed:@"MyLeaves"]];
            [lbl setText:AMLocalizedString(@"My Leaves", @"My Leaves")];
        }
            break;
        case cell_requestleave:
        {
            [img setImage:[UIImage imageNamed:@"RequestLeave"]];
            [lbl setText:AMLocalizedString(@"Request Leave", @"Request Leave")];
        }
            break;
        case cell_statistics:
        {
            [img setImage:[UIImage imageNamed:@"Statistics"]];
            [lbl setText:AMLocalizedString(@"Statistics", @"Statistics")];
        }
            break;
        case cell_groupchat:
        {
            [img setImage:[UIImage imageNamed:@"GroupChat"]];
            [lbl setText:AMLocalizedString(@"Group Chat", @"Group Chat")];
        }
            break;
        case cell_aboutapp:
        {
            [img setImage:[UIImage imageNamed:@"AboutApp"]];
            [lbl setText:AMLocalizedString(@"About App", @"About App")];
        }
            break;
        default:
            break;
    }
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    
    UIViewController *vc ;
    switch (indexPath.row) {
        case cell_home:
            vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"HomeVC"];
            break;
        case cell_mytask:
            vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"MyTasksVC"];
            break;
        case cell_minehours:
            vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"MineHoursVC"];
            break;
        case cell_registertime:
            vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"RegisterTimeVC"];
            break;
        case cell_myleaves:
            vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"MyLeavesVC"];
            break;
        case cell_requestleave:
            vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"RequestLeaveVC"];
            break;
        case cell_statistics:
            vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"StatisticsVC"];
            break;
        case cell_groupchat:
            vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"GroupChatVC"];
            break;
        case cell_aboutapp:
            vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"AboutAppVC"];
            break;
            
        default:
            break;
    }
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                             withSlideOutAnimation:YES
                                                                     andCompletion:nil];
    

}

#pragma mark - Button Actions
- (IBAction)onLogout:(id)sender{
    [GlobalUtils saveUserObject:nil key:global_user_info_save];

    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:global_key_is_logged_in];
    
    AppDelegate * app = (AppDelegate *) [UIApplication sharedApplication].delegate;
    [app initLoginView];
    [app initSlideMenu];
}
- (IBAction)onEdit:(id)sender{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    UIViewController *vc ;
    vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"ProfileVC"];
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                             withSlideOutAnimation:YES
                                                                     andCompletion:nil];
}

#pragma mark - Utils
- (void) refreshProfiles {
    
    User * user = [GlobalUtils loadUserObjectWithKey:global_user_info_save];
    [GlobalUtils setImageForUrlAndSize:imgProfile ID:user.strURLProfile url:[NSString stringWithFormat:@"%@%@", global_url_photo, user.strURLProfile] size:imgProfile.frame.size placeImage:@"avatar" storeDir:global_dir_profile];
    [lblName setText:[NSString stringWithFormat:@"%@ %@", user.strFirstName, user.strLastName]];
    [lblPhone setText:user.strMobile];
    [GlobalUtils setImageForUrlAndSize:imgCompany ID:user.strURLCompanyLogo url:[NSString stringWithFormat:@"%@%@", global_url_photo, user.strURLCompanyLogo] size:imgCompany.frame.size placeImage:@"" storeDir:global_dir_company];
    [_tblView reloadData];
}

- (void) getUnreadCount {
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
                         
                         [_tblView reloadData];
                     }
                 }
                 return;
             }
         }
     }];
}


@end
