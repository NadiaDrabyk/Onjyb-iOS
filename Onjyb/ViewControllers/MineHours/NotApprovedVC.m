//
//  NotApprovedVC.m
//  Onjyb
//
//  Created by Nadia Drabyk on 7/19/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import "NotApprovedVC.h"
#import "RegisterTimeDetailsVC.h"

@interface NotApprovedVC ()

@end

@implementation NotApprovedVC
@synthesize mAryTaskList;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:AMLocalizedString(@"Mine hours", @"Mine hours")];
    [lblTop setTextColor:global_green_color];
    [lblTop setText:AMLocalizedString(@"Not Approved", @"Not Approved")];
    if (global_screen_size.width < 330)
    {
        [lblTop setFont:[UIFont boldSystemFontOfSize:14.f]];
    }
    else
    {
        [lblTop setFont:[UIFont boldSystemFontOfSize:16.f]];
    }
    cellHeight = global_screen_size.height * 2 / 13;
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

- (void) viewWillAppear:(BOOL)animated
{
    [self getTaskList];
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

#pragma mark - Utils
- (void) getTaskList {
    mAryTaskList = [[NSMutableArray alloc] init];
    AppDelegate * app = (AppDelegate*) [UIApplication sharedApplication].delegate;
    [app showHUD];
    
    //TaskList API
    
    User * user = [GlobalUtils loadUserObjectWithKey:global_user_info_save];
    
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setObject:@"yes" forKey:global_key_is_mng_jobber];
    [param setObject:user.strUserID forKey:global_key_user_id];
    [param setObject:user.strCompanyID forKey:global_key_company_id];
    [param setObject:@"" forKey:global_key_is_summary];
    [param setObject:user.strRefRoleID forKey:global_key_role_id];
    [param setObject:@"reject" forKey:global_key_approve_status];
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

#pragma mark -TableView Delegate
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (mAryTaskList.count && mAryTaskList)
        return mAryTaskList.count;
    return 1;
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (mAryTaskList.count && mAryTaskList)
        return cellHeight;
    return cellHeight / 2;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"approvedCell"];
    
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"approvedCell"];
    }
    [cell.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    
    UIView * viewSep = [[UIView alloc] initWithFrame:CGRectMake(0, cellHeight - 1, global_screen_size.width, 1)];
    [viewSep setBackgroundColor:global_gray_color];
    cell.backgroundColor = [UIColor clearColor];
    
    if (mAryTaskList && mAryTaskList.count)
    {
        CGFloat sizeArrow = 24.f;
        if (global_screen_size.width < 330)
            sizeArrow = 20.f;

        CGFloat w = global_screen_size.width - leftPad - sizeArrow - 10;

        NSDictionary * dicCell = [mAryTaskList objectAtIndex:indexPath.row];
        UILabel * lblMonthProject = [[UILabel alloc] initWithFrame:CGRectMake(leftPad, 10, w, (cellHeight - 20) / 3)];
        [lblMonthProject setTextColor:global_nav_color];
        NSString * strDateTmp = [dicCell valueForKey:global_key_work_date];
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSDate * date = [formatter dateFromString:strDateTmp];
        [formatter setDateFormat:@"MMM dd yy"];
        NSString * strDate = [formatter stringFromDate:date];
        NSRange rng;
        rng.length = 3; rng.location = 0;
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
        NSInteger day = [components day];
        [lblMonthProject setText:[NSString stringWithFormat:@"%@     %@ | %@", [strDate substringWithRange:rng], [dicCell valueForKey:global_key_project_number], [dicCell valueForKey:global_key_project_name]]];
        
        UILabel * lblDay = [[UILabel alloc] initWithFrame:CGRectMake(leftPad, lblMonthProject.frame.size.height + lblMonthProject.frame.origin.y, 100, lblMonthProject.frame.size.height)];
        [lblDay setText:[NSString stringWithFormat:@"%lu", (long)day]];
        [lblDay setTextColor:global_nav_color];
        
        UILabel * lblTotalHours = [[UILabel alloc] initWithFrame:CGRectMake(leftPad, lblDay.frame.origin.y + lblDay.frame.size.height, 250, lblDay.frame.size.height)];
        [lblTotalHours setTextColor:global_nav_color];
        [lblTotalHours setText:AMLocalizedString(@"Total Hours", @"Total Hours")];
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
        
        if (global_screen_size.width < 330)
        {
            [lblMonthProject setFont:[UIFont boldSystemFontOfSize:15.f]];
            [lblDay setFont:[UIFont boldSystemFontOfSize:20.f]];
            [lblTotalHours setFont:[UIFont boldSystemFontOfSize:13.f]];
        }
        else
        {
            [lblMonthProject setFont:[UIFont boldSystemFontOfSize:17.f]];
            [lblDay setFont:[UIFont boldSystemFontOfSize:23.f]];
            [lblTotalHours setFont:[UIFont boldSystemFontOfSize:15.f]];
        }
        
        UILabel * lblTotalHoursValue = [[UILabel alloc] initWithFrame:CGRectMake(lblTotalHours.frame.origin.x + [GlobalUtils widthOfString:lblTotalHours.text withFont:lblTotalHours.font] + 10, lblTotalHours.frame.origin.y, 200, lblTotalHours.frame.size.height)];
        [lblTotalHoursValue setTextColor:global_green_color];
        [lblTotalHoursValue setText:[NSString stringWithFormat:@"%@:%@",strHour, strMinute]];
        [lblTotalHoursValue setFont:lblTotalHours.font];
        
        UIView * viewSepVer = [[UIView alloc] initWithFrame:CGRectMake(lblTotalHoursValue.frame.origin.x + [GlobalUtils widthOfString:lblTotalHoursValue.text withFont:lblTotalHours.font] + 10, lblTotalHours.frame.origin.y + lblTotalHours.frame.size.height / 6, 1.5f, lblTotalHours.frame.size.height * 2 / 3)];
        [viewSepVer setBackgroundColor:[UIColor grayColor]];
        
        UILabel * lblOvertime = [[UILabel alloc] initWithFrame:CGRectMake(viewSepVer.frame.origin.x + viewSepVer.frame.size.width + 10, lblTotalHours.frame.origin.y, 200, lblTotalHours.frame.size.height)];
        [lblOvertime setTextColor:global_nav_color];
        [lblOvertime setText:AMLocalizedString(@"Overtime", @"Overtime")];
        [lblOvertime setFont:lblTotalHours.font];
        
        UILabel * lblOvertimeValue = [[UILabel alloc] initWithFrame:CGRectMake(lblOvertime.frame.origin.x + [GlobalUtils widthOfString:lblOvertime.text withFont:lblOvertime.font] + 10, lblOvertime.frame.origin.y, 200, lblOvertime.frame.size.height)];
        [lblOvertimeValue setTextColor:global_green_color];
        [lblOvertimeValue setFont:lblOvertime.font];
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
        
        [lblOvertimeValue setText:[NSString stringWithFormat:@"%@h | %@m", strHour, strMinute]];
        
        
        
        UIImageView * imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(global_screen_size.width - 10 - sizeArrow, cellHeight / 2 - sizeArrow / 2, sizeArrow, sizeArrow)];
        [imgArrow setImage:[UIImage imageNamed:@"green_arrow_right"]];
        
        [cell addSubview:lblMonthProject];
        [cell addSubview:lblDay];
        [cell addSubview:lblTotalHours];
        [cell addSubview:lblTotalHoursValue];
        [cell addSubview:viewSepVer];
        [cell addSubview:lblOvertime];
        [cell addSubview:lblOvertimeValue];
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
        [cell addSubview:lblNoData];
        [viewSep setFrame:CGRectMake(viewSep.frame.origin.x, cellHeight / 2 - 1, viewSep.frame.size.width, 1)];
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
    vc.valueMode = global_value_mode_save;
    [self.navigationController pushViewController:vc animated:YES];
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
