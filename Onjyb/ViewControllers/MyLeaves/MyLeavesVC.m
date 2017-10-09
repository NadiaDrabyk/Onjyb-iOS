//
//  MyLeavesVC.m
//  Onjyb
//
//  Created by Nadia Drabyk on 7/19/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import "MyLeavesVC.h"
#import "LeaveDetailsVC.h"

@interface MyLeavesVC ()

@end

@implementation MyLeavesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:AMLocalizedString(@"My Leaves", @"My Leaves")];
    
    dimView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, global_screen_size.width, global_screen_size.height)];
    [dimView setBackgroundColor:[UIColor blackColor]];
    [dimView setAlpha:0.6];
    [self.view addSubview:dimView];
    cellHeight = global_screen_size.height /  10;
    
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
    [self getLeaveList];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openMenu:) name:global_notification_slide_open object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(revealMenu:) name:global_notification_slide_reveal object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeMenu:) name:global_notification_slide_close object:nil];
    [dimView setHidden:YES];
}

- (void) viewWillDisappear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:global_notification_slide_close object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:global_notification_slide_open object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:global_notification_slide_reveal object:nil];
}

#pragma mark - Button Actions
- (IBAction)onMenu:(id)sender
{
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
}

- (IBAction)onMore:(id)sender {
    
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

#pragma mark - TableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (mAryTaskList.count && mAryTaskList)
        return mAryTaskList.count;
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPah
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myLeavesCell"];
    
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"myLeavesCell"];
    }
    [cell.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    
    UIView * viewSep = [[UIView alloc] initWithFrame:CGRectMake(0, cellHeight - 1, global_screen_size.width, 1)];
    [viewSep setBackgroundColor:global_gray_color];
    cell.backgroundColor = [UIColor clearColor];
    
    if (mAryTaskList && mAryTaskList.count)
    {
        NSDictionary * dicCell = [mAryTaskList objectAtIndex:indexPah.row];
        UILabel * lblType = [[UILabel alloc] initWithFrame:CGRectMake(leftPad, 10, 200, (cellHeight - 20) / 2)];
        [lblType setTextColor:global_nav_color];
        [lblType setText:[NSString stringWithFormat:@"%@", [dicCell valueForKey:global_key_leave_type]]];
        UILabel * lblDate = [[UILabel alloc] initWithFrame:CGRectMake(lblType.frame.origin.x, lblType.frame.size.height + lblType.frame.origin.y, 200, lblType.frame.size.height)];
        NSString * strDateStart = [dicCell valueForKey:global_key_start_date];
        NSString * strDateEnd = [dicCell valueForKey:global_key_end_date];
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSDate * dateStart = [formatter dateFromString:strDateStart];
        NSDate * dateEnd = [formatter dateFromString:strDateEnd];
        [formatter setDateFormat:@"dd MMM yy"];
        NSString * strStart = [formatter stringFromDate:dateStart];
        NSString * strEnd = [formatter stringFromDate:dateEnd];
        [lblDate setText:[NSString stringWithFormat:@"%@ - %@", strStart, strEnd]];
        [lblDate setTextColor:[UIColor grayColor]];
        
        if (global_screen_size.width < 330)
        {
            [lblType setFont:[UIFont boldSystemFontOfSize:16.f]];
            [lblDate setFont:[UIFont boldSystemFontOfSize:14.f]];
            
        }
        else
        {
            [lblType setFont:[UIFont boldSystemFontOfSize:18.f]];
            [lblDate setFont:[UIFont boldSystemFontOfSize:16.f]];
        }
        
        UIView * viewSepVerMid = [[UIView alloc] initWithFrame:CGRectMake(lblDate.frame.origin.x + [GlobalUtils widthOfString:lblDate.text withFont:lblDate.font] + 5, lblDate.frame.origin.y + lblType.frame.size.height / 6, 1.5f, lblType.frame.size.height * 2 / 3)];
        [viewSepVerMid setBackgroundColor:[UIColor grayColor]];
        
        UILabel * lblApproveStatus = [[UILabel alloc] initWithFrame:CGRectMake(viewSepVerMid.frame.origin.x + viewSepVerMid.frame.size.width + 5, lblDate.frame.origin.y, 150, lblDate.frame.size.height)];
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
        else if ([strApproveStatus isEqualToString:global_value_pendding])
        {
            [lblApproveStatus setText:AMLocalizedString(@"Pendding", @"Pendding")];
            [lblApproveStatus setTextColor:global_nav_color];
        }
        else
        {
            [lblApproveStatus setText:AMLocalizedString(@"Cancelled", @"Cancelled")];
            [lblApproveStatus setTextColor:global_red_color];
        }
        
        CGFloat sizeArrow = 24.f;
        if (global_screen_size.width < 330)
        {
            [lblApproveStatus setFont:[UIFont boldSystemFontOfSize:14.f]];
            sizeArrow = 20.f;
        }
        else
        {
            [lblApproveStatus setFont:[UIFont boldSystemFontOfSize:16.f]];
        }
        
        UIImageView * imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(global_screen_size.width - 10 - sizeArrow, cellHeight / 2 - sizeArrow / 2, sizeArrow, sizeArrow)];
        [imgArrow setImage:[UIImage imageNamed:@"green_arrow_right"]];
        
        [cell addSubview:lblType];
        [cell addSubview:viewSepVerMid];
        [cell addSubview:lblApproveStatus];
        [cell addSubview:lblDate];
        [cell addSubview:imgArrow];
        [cell addSubview:viewSep];
    }
    else
    {
        UILabel * lblNoData = [[UILabel alloc] initWithFrame:CGRectMake(leftPad, 0, global_screen_size.width - leftPad, cellHeight - 1)];
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
        [viewSep setFrame:CGRectMake(viewSep.frame.origin.x, cellHeight - 1, viewSep.frame.size.width, 1)];
        [cell addSubview:viewSep];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(mAryTaskList.count > indexPath.row){
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        LeaveDetailsVC * vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"LeaveDetailsVC"];
    
        NSDictionary * dicOne = [mAryTaskList objectAtIndex:indexPath.row];
        vc.dicInfo = [dicOne mutableCopy];
        [self.navigationController pushViewController:vc animated:YES];

    }
    
}

#pragma mark - Utils

- (void) getLeaveList {
    AppDelegate * app = (AppDelegate*) [UIApplication sharedApplication].delegate;
    [app showHUD];
    
    //TaskList API
    
    User * user = [GlobalUtils loadUserObjectWithKey:global_user_info_save];
    
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setObject:@"yes" forKey:global_key_is_mng_jobber];
    [param setObject:@"" forKey:global_key_employee_id];
    [param setObject:@"" forKey:global_key_leavetype_id];
    [param setObject:@"" forKey:global_key_start_date];
    [param setObject:@"" forKey:global_key_end_date];
    [param setObject:user.strCompanyID forKey:global_key_company_id];
    [param setObject:user.strRefRoleID forKey:global_key_role_id];
    [param setObject:@"" forKey:global_key_approve_status];
    [param setObject:@"1" forKey:global_key_page_number];
//    [param setObject:@"ios" forKey:global_key_os];
    [param setObject:user.strUserID forKey:global_key_user_id];
//    [param setObject:@"en" forKey:global_key_language];
    
    //////////
    [MyRequest POST:global_api_getLeaveList parameters:param completed:^(id result)
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
                         NSArray * ary = [dicResObject valueForKey:global_key_leave_details];
                         mAryTaskList = [[NSMutableArray alloc] init];
                         mAryTaskList = [ary mutableCopy];
                         [tblView reloadData];
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
