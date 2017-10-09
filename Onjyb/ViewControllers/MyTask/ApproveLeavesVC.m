//
//  ApproveLeavesVC.m
//  Onjyb
//
//  Created by Nadia Drabyk on 7/19/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import "ApproveLeavesVC.h"
#import "LeaveDetailsVC.h"
#import "RejectLeavesVC.h"

@interface ApproveLeavesVC ()

@end

@implementation ApproveLeavesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:AMLocalizedString(@"Leaves", @"Leaves")];
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

- (void) viewWillAppear:(BOOL)animated {
    [self getLeaveList];
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

#pragma mark - TableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (mAryTaskList.count && mAryTaskList)
        return mAryTaskList.count;
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (mAryTaskList && mAryTaskList.count > 0)
        return cellHeight * 1.5;
    return cellHeight / 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPah
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pastLeaveCell"];
    
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"pastLeaveCell"];
    }
    [cell.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    
    UIView * viewSep = [[UIView alloc] initWithFrame:CGRectMake(0, cellHeight * 1.5 - 1, global_screen_size.width, 1)];
    [viewSep setBackgroundColor:global_gray_color];
    cell.backgroundColor = [UIColor clearColor];
    
    if (mAryTaskList && mAryTaskList.count)
    {
        NSDictionary * dicCell = [mAryTaskList objectAtIndex:indexPah.row];
        UIImageView * imgProfile = [[UIImageView alloc] initWithFrame:CGRectMake(leftPad * 2 / 3, cellHeight / 4, cellHeight / 2, cellHeight / 2)];
        NSString * strProfile = [dicCell valueForKey:global_key_profile_image];
        [GlobalUtils setImageForUrlAndSize:imgProfile ID:strProfile url:[NSString stringWithFormat:@"%@%@", global_url_photo, strProfile] size:imgProfile.frame.size placeImage:@"avatar" storeDir:global_dir_past_leave];
        imgProfile.layer.cornerRadius = imgProfile.frame.size.width / 2;
        imgProfile.layer.borderColor = global_nav_color.CGColor;
        imgProfile.layer.borderWidth = 1.5f;
        imgProfile.layer.masksToBounds = YES;
        
        CGFloat sizeArrow = 24.f;
        if (global_screen_size.width < 330)
            sizeArrow = 20.f;
        
        CGFloat x = imgProfile.frame.origin.x * 2 + imgProfile.frame.size.width;
        CGFloat w = global_screen_size.width - 10 - sizeArrow - x;
        CGFloat h = (cellHeight - 20) / 3;

        UILabel * lblName = [[UILabel alloc] initWithFrame:CGRectMake(x, 10, w, h)];
        [lblName setTextColor:global_nav_color];
        [lblName setText:[NSString stringWithFormat:@"%@ %@", [dicCell valueForKey:global_key_first_name], [dicCell valueForKey:global_key_last_name]]];
        
        UILabel * lblType = [[UILabel alloc] initWithFrame:CGRectMake(lblName.frame.origin.x, lblName.frame.origin.y + lblName.frame.size.height, 250, lblName.frame.size.height)];
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
            [lblName setFont:[UIFont boldSystemFontOfSize:16.f]];
            [lblType setFont:[UIFont boldSystemFontOfSize:14.f]];
            [lblDate setFont:[UIFont boldSystemFontOfSize:14.f]];
            
        }
        else
        {
            [lblName setFont:[UIFont boldSystemFontOfSize:18.f]];
            [lblType setFont:[UIFont boldSystemFontOfSize:16.f]];
            [lblDate setFont:[UIFont boldSystemFontOfSize:16.f]];
        }
        
//        UIView * viewSepVerMid = [[UIView alloc] initWithFrame:CGRectMake(lblType.frame.origin.x + [GlobalUtils widthOfString:lblType.text withFont:lblType.font] + 5, lblType.frame.origin.y + lblType.frame.size.height / 6, 1.5f, lblType.frame.size.height * 2 / 3)];
//        [viewSepVerMid setBackgroundColor:[UIColor grayColor]];
        
//        UILabel * lblApproveStatus = [[UILabel alloc] initWithFrame:CGRectMake(viewSepVerMid.frame.origin.x + viewSepVerMid.frame.size.width + 5, lblType.frame.origin.y, 150, lblType.frame.size.height)];
//        NSString *strApproveStatus = [dicCell valueForKey:global_key_approve_status];
        
//        if ([strApproveStatus isEqualToString:global_value_approve])
//        {
//            [lblApproveStatus setText:AMLocalizedString(@"Approved", @"Approved")];
//            [lblApproveStatus setTextColor:global_green_color];
//        }
//        else if ([strApproveStatus isEqualToString:global_value_reject])
//        {
//            [lblApproveStatus setText:AMLocalizedString(@"Rejected", @"Rejected")];
//            [lblApproveStatus setTextColor:global_red_color];
//            
//        }
//        else if ([strApproveStatus isEqualToString:global_value_pendding])
//        {
//            [lblApproveStatus setText:AMLocalizedString(@"Pendding", @"Pendding")];
//            [lblApproveStatus setTextColor:global_nav_color];
//        }
//        else
//        {
//            [lblApproveStatus setText:AMLocalizedString(@"Cancelled", @"Cancelled")];
//            [lblApproveStatus setTextColor:global_red_color];
//        }
        
//        if (global_screen_size.width < 330)
//        {
//            [lblApproveStatus setFont:[UIFont boldSystemFontOfSize:14.f]];
//        }
//        else
//        {
//            [lblApproveStatus setFont:[UIFont boldSystemFontOfSize:16.f]];
//        }
        
        UIImageView * imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(global_screen_size.width - 10 - sizeArrow, cellHeight / 2 - sizeArrow / 2, sizeArrow, sizeArrow)];
        [imgArrow setImage:[UIImage imageNamed:@"green_arrow_right"]];
        
        [cell addSubview:imgProfile];
        [cell addSubview:lblName];
        [cell addSubview:lblType];
//        [cell addSubview:viewSepVerMid];
//        [cell addSubview:lblApproveStatus];
        [cell addSubview:lblDate];
        [cell addSubview:imgArrow];
        [cell addSubview:viewSep];
        
        UIButton * btnApprove = [[UIButton alloc] initWithFrame:CGRectMake(lblDate.frame.origin.x, CGRectGetMaxY(lblDate.frame) + cellHeight / 8, cellHeight * 3.2 / 4, cellHeight / 4)];
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
        [cell addSubview:btnApprove];
        [cell addSubview:btnReject];

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
    LeaveDetailsVC * vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"LeaveDetailsVC"];
    NSDictionary * dicOne = [mAryTaskList objectAtIndex:indexPath.row];
    vc.dicInfo = [dicOne mutableCopy];
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - Utils
- (void) onApprove:(UIButton*) btn {
    NSInteger index = btn.tag;
    NSDictionary * dicCell = [mAryTaskList objectAtIndex:index];
    NSString* leaveid = [dicCell objectForKey:@"leave_id"];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Are you sure, you want to approve this leave?", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:AMLocalizedString(@"NO", @"NO") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                   {
                                       
                                   }];
    [alert addAction:cancelAction];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:AMLocalizedString(@"YES", @"YES") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                    {
                                        [mAryTaskList removeObject:dicCell];
                                        [tblView reloadData];
                                        [self onApproveAction:leaveid];
                                    }];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];

}
- (void)onApproveAction:(NSString*)leaveid{
    User * user = [GlobalUtils loadUserObjectWithKey:global_user_info_save];
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setObject:user.strUserID forKey:global_key_user_id];
    [param setObject:@"approve" forKey:global_key_approve_status];
    [param setObject:leaveid forKey:global_key_leave_id];
    [param setObject:@"" forKey:global_key_note];
    
    AppDelegate * app = (AppDelegate*) [UIApplication sharedApplication].delegate;
    [app showHUD];
    
    //////////
    [MyRequest POST:global_api_approve_leave parameters:param completed:^(id result)
     {
         [app hideHUD];
         NSDictionary * dicResult = (NSDictionary*) result;
         if (dicResult == NULL || [dicResult isEqual:[NSNull null]])
         {
             [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Connection Error", @"Connection Error") cancel:AMLocalizedString(@"Ok", @"Ok")];
             return;
         }
         else
         {
             NSNumber * numRes = [dicResult valueForKey:global_key_res_code];
             if (numRes)
             {
                 if (numRes.intValue == global_result_success)
                 {
                     [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Leave is approved!", @"Leave is approved!") cancel:AMLocalizedString(@"Ok", @"Ok")];
                     return;
                 }
                 else {
                     NSString * errorString = AMLocalizedString(@"Error occured.", @"Error occured.");
                     if ([dicResult valueForKey:global_key_res_message])
                     {
                         errorString = [NSString stringWithFormat:@"%@", [dicResult valueForKey:global_key_res_message]];
                     }
                     [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:errorString cancel:AMLocalizedString(@"Ok", @"Ok")];
                 }
                 return;
             }
         }
         NSString * errorString = AMLocalizedString(@"Error occured.", @"Error occured.");
         [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:errorString cancel:AMLocalizedString(@"Ok", @"Ok")];
     }];

}
- (void) onReject:(UIButton*) btn {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    RejectLeavesVC * vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"RejectLeavesVC"];
    NSDictionary * dicOne = [mAryTaskList objectAtIndex:btn.tag];
    vc.dicInfo = [dicOne mutableCopy];
    [self.navigationController pushViewController:vc animated:YES];

}

- (void) getLeaveList {
    AppDelegate * app = (AppDelegate*) [UIApplication sharedApplication].delegate;
    [app showHUD];
    
    //TaskList API
    
    User * user = [GlobalUtils loadUserObjectWithKey:global_user_info_save];
    
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setObject:@"" forKey:global_key_is_mng_jobber];
    [param setObject:@"" forKey:global_key_employee_id];
    [param setObject:@"" forKey:global_key_leavetype_id];
    [param setObject:@"" forKey:global_key_start_date];
    [param setObject:@"" forKey:global_key_end_date];
    [param setObject:user.strCompanyID forKey:global_key_company_id];
    [param setObject:user.strRefRoleID forKey:global_key_role_id];
    [param setObject:@"pendding" forKey:global_key_approve_status];
    [param setObject:@"0" forKey:global_key_page_number];
    [param setObject:@"ios" forKey:global_key_os];
    [param setObject:user.strUserID forKey:global_key_user_id];
    [param setObject:@"en" forKey:global_key_language];
    
    if (!strEmployeeIDApply) strEmployeeIDApply = @"";
    if (!strStartDateApply) strStartDateApply = @"";
    if (!strEndDateApply) strEndDateApply = @"";
    if (!strProjectIDApply) strProjectIDApply = @"";
    [param setObject:strEmployeeIDApply forKey:global_key_employee_id];
    [param setObject:strStartDateApply forKey:global_key_start_date];
    [param setObject:strEndDateApply forKey:global_key_end_date];
    [param setObject:strProjectIDApply forKey:global_key_project_id];
    
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
                     else
                     {
                         mAryTaskList = [[NSMutableArray alloc] init];
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
    [self getLeaveList];
}
@end
