//
//  ApprovedJobsVC.m
//  Onjyb
//
//  Created by Nadia Drabyk on 7/19/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import "ApprovedJobsVC.h"
#import "RegisterTimeDetailsVC.h"
#import "RejectVC.h"

@interface ApprovedJobsVC ()

@end

@implementation ApprovedJobsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:AMLocalizedString(@"My Tasks", @"My Tasks")];
    cellHeight = global_screen_size.height * 2 / 13;
    [lblTop setTextColor:global_green_color];
    [lblTop setText:AMLocalizedString(@"Pending Tasks", @"Pending Tasks")];
    leftPad = 22.f;
    if (global_screen_size.width < 330)
    {
        leftPad = 14.f;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [self getTaskList];
    [self getUnreadCount];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applyRightMenu:) name:global_notification_apply_right_menu object:nil];
}
- (void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:global_notification_apply_right_menu];
}
#pragma mark - SlideNavigationController Methods -

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return YES;
}

#pragma mark - Button Actions
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onMore:(id)sender {
    [[SlideNavigationController sharedInstance] toggleRightMenu];
}

- (void) onApprove:(UIButton*) btn {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    RegisterTimeDetailsVC * vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"RegisterTimeDetailsVC"];
    NSDictionary *dicOne = [mAryTaskList objectAtIndex:btn.tag];
    vc.dicInfo = [dicOne mutableCopy];
    vc.valueMode = global_value_mode_approve;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) onReject:(UIButton*) btn {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    RejectVC * vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"RejectVC"];
    NSDictionary *dicOne = [mAryTaskList objectAtIndex:btn.tag];
    vc.dicInfo = [dicOne mutableCopy];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Table View Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (mAryTaskList.count && mAryTaskList)
        return mAryTaskList.count;
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (mAryTaskList.count && mAryTaskList)
        return cellHeight * 1.5;
    return cellHeight / 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPah
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"approveTaskCell"];
    
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"approveTaskCell"];
    }
    [cell.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    
    UIView * viewSep = [[UIView alloc] initWithFrame:CGRectMake(0, cellHeight * 1.5 - 1, global_screen_size.width, 1)];
    [viewSep setBackgroundColor:global_gray_color];
    cell.backgroundColor = [UIColor clearColor];
    
    if (mAryTaskList && mAryTaskList.count)
    {
        NSDictionary * dicCell = [mAryTaskList objectAtIndex:indexPah.row];
        UIImageView * imgProfile = [[UIImageView alloc] initWithFrame:CGRectMake(leftPad * 2 / 3, cellHeight * 3 / 4 - cellHeight / 4, cellHeight / 2, cellHeight / 2)];
        NSString * strProfile = [dicCell valueForKey:global_key_profile_image];
        [GlobalUtils setImageForUrlAndSize:imgProfile ID:strProfile url:[NSString stringWithFormat:@"%@%@", global_url_photo, strProfile] size:imgProfile.frame.size placeImage:@"avatar" storeDir:global_dir_complete_task];
        imgProfile.layer.cornerRadius = imgProfile.frame.size.width / 2;
        imgProfile.layer.borderColor = global_nav_color.CGColor;
        imgProfile.layer.borderWidth = 1.5f;
        imgProfile.layer.masksToBounds = YES;
        UILabel * lblName = [[UILabel alloc] initWithFrame:CGRectMake(imgProfile.frame.origin.x * 2 + imgProfile.frame.size.width, 10, 200, (cellHeight - 20) / 3)];
        [lblName setTextColor:global_nav_color];
        [lblName setText:[NSString stringWithFormat:@"%@ %@", [dicCell valueForKey:global_key_first_name], [dicCell valueForKey:global_key_last_name]]];
        
        UILabel * lblProject = [[UILabel alloc] initWithFrame:CGRectMake(lblName.frame.origin.x, lblName.frame.origin.y + lblName.frame.size.height, 250, lblName.frame.size.height / 2)];
        [lblProject setTextColor:global_nav_color];
        [lblProject setText:[NSString stringWithFormat:@"%@|%@", [dicCell valueForKey:global_key_project_number], [dicCell valueForKey:global_key_project_name]]];
        UILabel * lblDate = [[UILabel alloc] initWithFrame:CGRectMake(lblProject.frame.origin.x, lblProject.frame.size.height + lblProject.frame.origin.y, 200, lblProject.frame.size.height)];
        NSString * strDateTmp = [dicCell valueForKey:global_key_work_date];
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSDate * date = [formatter dateFromString:strDateTmp];
        [formatter setDateFormat:@"dd MMM yy"];
        NSString * strDate = [formatter stringFromDate:date];
        [lblDate setText:strDate];
        [lblDate setTextColor:global_nav_color];
        
        UILabel * lblTotalHours = [[UILabel alloc] initWithFrame:CGRectMake(lblDate.frame.origin.x, lblDate.frame.origin.y + lblDate.frame.size.height, 250, lblDate.frame.size.height * 2)];
        [lblTotalHours setTextColor:[UIColor grayColor]];
        NSString * strValueWorkTime = [dicCell valueForKey:global_key_total_work_time];
        int hour = strValueWorkTime.intValue / 60;
        NSString * strHour;
        if (hour < 10)
        {
            strHour = [NSString stringWithFormat:@"0%d", hour];
        }
        else
        {
            strHour = [NSString stringWithFormat:@"%d", hour];
        }
        NSString * strMinute;
        int minute = strValueWorkTime.intValue - hour * 60;
        if (minute < 10)
        {
            strMinute = [NSString stringWithFormat:@"0%d", minute];
        }
        else
        {
            strMinute = [NSString stringWithFormat:@"%d", minute];
        }
        
        [lblTotalHours setText:[NSString stringWithFormat:@"%@ %@:%@",AMLocalizedString(@"Total Hours", @"Total Hours"),strHour, strMinute]];
        
        if (global_screen_size.width < 330)
        {
            [lblName setFont:[UIFont boldSystemFontOfSize:16.f]];
            [lblProject setFont:[UIFont boldSystemFontOfSize:11.f]];
            [lblDate setFont:[UIFont boldSystemFontOfSize:11.f]];
            [lblTotalHours setFont:[UIFont boldSystemFontOfSize:10.f]];
        }
        else
        {
            [lblName setFont:[UIFont boldSystemFontOfSize:18.f]];
            [lblProject setFont:[UIFont boldSystemFontOfSize:13.f]];
            [lblDate setFont:[UIFont boldSystemFontOfSize:13.f]];
            [lblTotalHours setFont:[UIFont boldSystemFontOfSize:13.f]];
        }
        
        UIView * viewSepVerMid = [[UIView alloc] initWithFrame:CGRectMake(lblProject.frame.origin.x + [GlobalUtils widthOfString:lblProject.text withFont:lblProject.font] + 5, lblProject.frame.origin.y, 1.5f, lblProject.frame.size.height)];
        [viewSepVerMid setBackgroundColor:[UIColor grayColor]];
        
        UILabel * lblApproveStatus = [[UILabel alloc] initWithFrame:CGRectMake(viewSepVerMid.frame.origin.x + viewSepVerMid.frame.size.width + 5, lblProject.frame.origin.y, 150, lblProject.frame.size.height)];
        NSString *strApproveStatus = [dicCell valueForKey:global_key_approve_status];
        
        if ([strApproveStatus isEqualToString:global_value_approve])
        {
            [lblApproveStatus setText:AMLocalizedString(@"Approved", @"Approved")];
            [lblApproveStatus setTextColor:global_green_color];
        }
        else if ([strApproveStatus isEqualToString:global_value_reject])
        {
            [lblApproveStatus setText:AMLocalizedString(@"Rejected", @"Rejected")];
            [lblApproveStatus setTextColor:global_red_color];
            
        }
        else
        {
            [lblApproveStatus setText:AMLocalizedString(@"Pendding", @"Pendding")];
            [lblApproveStatus setTextColor:global_nav_color];
        }

        UIView * viewSepVerBottom = [[UIView alloc] initWithFrame:CGRectMake(lblTotalHours.frame.origin.x + [GlobalUtils widthOfString:lblTotalHours.text withFont:lblTotalHours.font] + 5, lblTotalHours.frame.origin.y + lblTotalHours.frame.size.height / 4, 1.5f, lblTotalHours.frame.size.height / 2)];
        [viewSepVerBottom setBackgroundColor:[UIColor grayColor]];
        
        UILabel * lblOverTime = [[UILabel alloc] initWithFrame:CGRectMake(viewSepVerBottom.frame.origin.x + viewSepVerBottom.frame.size.width + 5, lblTotalHours.frame.origin.y, 300, lblTotalHours.frame.size.height)];
        [lblOverTime setTextColor:[UIColor grayColor]];
        NSString * strOverTime1 = [dicCell valueForKey:global_key_work_overtime1];
        
        hour = strOverTime1.intValue / 60;
        if (hour < 10)
        {
            strHour = [NSString stringWithFormat:@"0%d", hour];
        }
        else
        {
            strHour = [NSString stringWithFormat:@"%d", hour];
        }
        minute = strOverTime1.intValue - hour * 60;
        if (minute < 10)
        {
            strMinute = [NSString stringWithFormat:@"0%d", minute];
        }
        else
        {
            strMinute = [NSString stringWithFormat:@"%d", minute];
        }
        [lblOverTime setText:[NSString stringWithFormat:@"%@ %@h | %@m", AMLocalizedString(@"Overtime", @"Overtime"), strHour, strMinute]];
        
        UIButton * btnApprove = [[UIButton alloc] initWithFrame:CGRectMake(lblTotalHours.frame.origin.x, lblTotalHours.frame.origin.y + lblTotalHours.frame.size.height + cellHeight / 8, cellHeight * 3.2 / 4, cellHeight / 4)];
        [btnApprove setTitle:AMLocalizedString(@"Approve", @"Approve") forState:UIControlStateNormal];
        [btnApprove setTitleColor:global_green_color forState:UIControlStateNormal];
        btnApprove.layer.borderColor = global_green_color.CGColor;
        btnApprove.layer.borderWidth = 1.f;
        CGFloat corner = 5.f;
        if (global_screen_size.width < 330)
        {
            corner = 3.f;
        }
        btnApprove.layer.cornerRadius = corner;
        btnApprove.layer.masksToBounds = YES;
        btnApprove.tag = indexPah.row;
        [btnApprove addTarget:self action:@selector(onApprove:) forControlEvents:UIControlEventTouchUpInside];

        UIButton * btnReject = [[UIButton alloc] initWithFrame:CGRectMake(btnApprove.frame.origin.x + btnApprove.frame.size.width + leftPad, btnApprove.frame.origin.y, btnApprove.frame.size.width, btnApprove.frame.size.height)];
        [btnReject setTitle:AMLocalizedString(@"Reject", @"Reject") forState:UIControlStateNormal];
        [btnReject setTitleColor:global_red_color forState:UIControlStateNormal];
        btnReject.layer.borderColor = global_red_color.CGColor;
        btnReject.layer.borderWidth = 1.f;
        btnReject.layer.cornerRadius = corner;
        btnReject.layer.masksToBounds = YES;
        btnReject.tag = indexPah.row;
        [btnReject addTarget:self action:@selector(onReject:) forControlEvents:UIControlEventTouchUpInside];
        CGFloat sizeArrow = 24.f;
        
        if (global_screen_size.width < 330)
        {
            [lblApproveStatus setFont:[UIFont boldSystemFontOfSize:12.f]];
            [lblOverTime setFont:[UIFont boldSystemFontOfSize:10.f]];
            [btnApprove.titleLabel setFont:[UIFont boldSystemFontOfSize:12.f]];
            [btnReject.titleLabel setFont:[UIFont boldSystemFontOfSize:12.f]];
            sizeArrow = 20.f;
        }
        else
        {
            [lblApproveStatus setFont:[UIFont boldSystemFontOfSize:14.f]];
            [lblOverTime setFont:[UIFont boldSystemFontOfSize:14.f]];
            [btnApprove.titleLabel setFont:[UIFont boldSystemFontOfSize:16.f]];
            [btnReject.titleLabel setFont:[UIFont boldSystemFontOfSize:16.f]];
        }
        
        UIImageView * imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(global_screen_size.width - 10 - sizeArrow, cellHeight * 3 / 4 - sizeArrow / 2, sizeArrow, sizeArrow)];
        [imgArrow setImage:[UIImage imageNamed:@"green_arrow_right"]];
        
        [cell addSubview:imgProfile];
        [cell addSubview:lblName];
        [cell addSubview:lblProject];
        [cell addSubview:lblDate];
        [cell addSubview:lblTotalHours];
        [cell addSubview:viewSepVerBottom];
        [cell addSubview:lblOverTime];
        [cell addSubview:btnApprove];
        [cell addSubview:btnReject];
        [cell addSubview:imgArrow];
        [cell addSubview:viewSep];
    }
    else
    {
        UILabel * lblNoData = [[UILabel alloc] initWithFrame:CGRectMake(leftPad, 0, global_screen_size.width - leftPad, cellHeight / 2 - 1)];
        [lblNoData setTextColor:global_nav_color];
        [lblNoData setBackgroundColor:[UIColor clearColor]];
        if (global_screen_size.width < 330)
        {
            [lblNoData setFont:[UIFont boldSystemFontOfSize:16.f]];
        }
        else
        {
            [lblNoData setFont:[UIFont boldSystemFontOfSize:18.f]];
        }
        [lblNoData setText:AMLocalizedString(@"No Data", @"No Data")];
        [viewSep setFrame:CGRectMake(viewSep.frame.origin.x, cellHeight / 2 - 1, viewSep.frame.size.width, 1)];
        [cell addSubview:lblNoData];
        [cell addSubview:viewSep];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    RegisterTimeDetailsVC * vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"RegisterTimeDetailsVC"];
    NSDictionary *dicOne = [mAryTaskList objectAtIndex:indexPath.row];
    vc.dicInfo = [dicOne mutableCopy];
    vc.valueMode = global_value_mode_approve;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Utils
- (void) getTaskList {
    mAryTaskList = [[NSMutableArray alloc] init];
    AppDelegate * app = (AppDelegate*) [UIApplication sharedApplication].delegate;
    [app showHUD];
    
    //TaskList API
    
    User * user = [GlobalUtils loadUserObjectWithKey:global_user_info_save];
    
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setObject:@"" forKey:global_key_is_mng_jobber];
    [param setObject:user.strUserID forKey:global_key_user_id];
    [param setObject:user.strCompanyID forKey:global_key_company_id];
    [param setObject:@"" forKey:global_key_is_summary];
    [param setObject:user.strRefRoleID forKey:global_key_role_id];
    [param setObject:@"pendding" forKey:global_key_approve_status];
    [param setObject:@"1" forKey:global_key_page_number];
    if (!strEmployeeIDApply) strEmployeeIDApply = @"";
    if (!strStartDateApply) strStartDateApply = @"";
    if (!strEndDateApply) strEndDateApply = @"";
    if (!strProjectIDApply) strProjectIDApply = @"";
    [param setObject:strEmployeeIDApply forKey:global_key_employee_id];
    [param setObject:strStartDateApply forKey:global_key_start_date];
    [param setObject:strEndDateApply forKey:global_key_end_date];
    [param setObject:strProjectIDApply forKey:global_key_project_id];
    //////////
    [MyRequest POST:global_api_getMyTaskList parameters:param completed:^(id result)
     {
         [app hideHUD];
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
                         NSArray * ary = [dicResObject objectForKey:global_key_work_details];
                         if (ary && ary.count) {
                             mAryTaskList = [ary mutableCopy];
                             [tblView reloadData];
                         }
                         else
                         {
                             mAryTaskList = [[NSMutableArray alloc] init];
                             [tblView reloadData];
                         }
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

                     }
                 }
                 return;
             }
         }
     }];
}

#pragma mark - Right Menu
- (void) applyRightMenu:(NSNotification *) noti
{
    NSDictionary * dicProgress = (NSDictionary*) noti.object;
    if (dicProgress == NULL || [dicProgress isEqual:[NSNull null]]) {
        return;
    }
    strProjectIDApply = [dicProgress valueForKey:global_key_project_id];
    strStartDateApply = [dicProgress valueForKey:global_key_start_date];
    strEndDateApply = [dicProgress valueForKey:global_key_end_date];
    strEmployeeIDApply = [dicProgress valueForKey:global_key_employee_id];
    [self getTaskList];
}
@end
