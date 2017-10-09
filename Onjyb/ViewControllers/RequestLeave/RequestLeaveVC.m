//
//  RequestLeaveVC.m
//  Onjyb
//
//  Created by Nadia Drabyk on 7/19/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import "RequestLeaveVC.h"

@interface RequestLeaveVC ()

@end

@implementation RequestLeaveVC

#define cell_ProjectName                0
#define cell_LeaveType                  1
#define cell_FromDate                   2
#define cell_ToDate                     3
#define cell_Duration                   4
#define cell_PTOBank                    5
#define cell_Description                6
#define cell_Note                       7
#define cell_Num                        8

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:AMLocalizedString(@"My Leaves", @"My Leaves")];
    
    dimView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, global_screen_size.width, global_screen_size.height)];
    [dimView setBackgroundColor:[UIColor blackColor]];
    [dimView setAlpha:0.6];
    mAryLeaveType = [[NSMutableArray alloc] init];
    
    //0926
    NSArray* ary = [g_dicProductMaster objectForKey:@"leavetype_details"];
    for(NSDictionary* dic in ary){
        NSString* leave_type = [dic objectForKey:@"leave_type"];
        [mAryLeaveType addObject:leave_type];
    }
    
    cellHeight = global_screen_size.height / 13;
    padding = 10;
    btnProjectHeight = cellHeight * 2 / 3;
    [lblTop setText:AMLocalizedString(@"Leave Request", @"Leave Request")];
    [lblTop setTextColor:global_green_color];
    viewProject = [[UIScrollView alloc] initWithFrame:CGRectMake(global_screen_size.width / 2, global_screen_size.width / 7.5 + cellHeight, global_screen_size.width / 2 - padding, 0)];
    [viewProject setBackgroundColor:[UIColor colorWithRed:240 / 255.f green:240 / 255.f blue:240 / 255.f alpha:1.f]];
    viewProject.layer.cornerRadius = 3.f;
    viewProject.layer.borderWidth = 1.f;
    viewProject.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.view addSubview:viewProject];
    
    viewLeaveType = [[UIView alloc] initWithFrame:CGRectMake(global_screen_size.width / 2, global_screen_size.width / 7.5 + cellHeight * 2, global_screen_size.width / 2 - padding, 0)];
    [viewLeaveType setBackgroundColor:[UIColor colorWithRed:240 / 255.f green:240 / 255.f blue:240 / 255.f alpha:1.f]];
    viewLeaveType.layer.cornerRadius = 3.f;
    viewLeaveType.layer.borderWidth = 1.f;
    viewLeaveType.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.view addSubview:viewLeaveType];
    
    [viewProject setHidden:YES];
    [viewLeaveType setHidden:YES];
    [self.view bringSubviewToFront:viewTop];
    [self.view addSubview:dimView];

    nPTOValue = 0;
    [self initViews];
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboards)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) viewWillAppear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openMenu:) name:global_notification_slide_open object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(revealMenu:) name:global_notification_slide_reveal object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeMenu:) name:global_notification_slide_close object:nil];
    [dimView setHidden:YES];
}

- (void) viewWillDisappear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:global_notification_slide_close object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:global_notification_slide_open object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:global_notification_slide_reveal object:nil];
}

#pragma mark - Button Actions
- (IBAction)onMenu:(id)sender
{
    [self dismissKeyboards];
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
}

- (void)onDatePickerDone {
    if ([txtFromDate isFirstResponder])
    {
        NSDate * date = mPickerFrom.date;
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd MMM yy"];
        strFromDateSave = [formatter stringFromDate:date];
        [tblView reloadData];
    }
    if ([txtToDate isFirstResponder])
    {
        NSDate * date = mPickerTo.date;
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd MMM yy"];
        strToDateSave = [formatter stringFromDate:date];
        [tblView reloadData];
    }
    if ([txtPTOHours isFirstResponder])
    {
        NSUInteger hour = [mPickerHours selectedRowInComponent:0];
        int minute = nPTOValue % 60;
        nPTOValue = (int)(hour * 60 + minute);
        NSString * strHour;
        if (hour < 10)
        {
            strHour = [NSString stringWithFormat:@"0%lu", (unsigned long)hour];
        }
        else
        {
            strHour = [NSString stringWithFormat:@"%lu", (unsigned long)hour];
        }
        NSString * strMinute;
        if (minute < 10)
        {
            strMinute = [NSString stringWithFormat:@"0%d", minute];
        }
        else
        {
            strMinute = [NSString stringWithFormat:@"%d", minute];
        }
        [txtPTOHours setText:[NSString stringWithFormat:@"%@ %@", strHour, AMLocalizedString(@"Hrs", nil)]];
    }
    if ([txtPTOMinutes isFirstResponder])
    {
        NSUInteger minute = [mPickerMinutes selectedRowInComponent:0];
        int hour = nPTOValue / 60;
        nPTOValue = (int)(hour * 60 + minute);
        NSString * strMinute;
        if (minute < 10)
        {
            strMinute = [NSString stringWithFormat:@"0%lu", (unsigned long)minute];
        }
        else
        {
            strMinute = [NSString stringWithFormat:@"%lu", (unsigned long)minute];
        }
        NSString * strHour;
        if (hour < 10)
        {
            strHour = [NSString stringWithFormat:@"0%d", hour];
        }
        else
        {
            strHour = [NSString stringWithFormat:@"%d", hour];
        }
        [txtPTOMinutes setText:[NSString stringWithFormat:@"%@ %@", strMinute, AMLocalizedString(@"Min", nil)]];
    }
    [self dismissKeyboards];
}
- (void) onSend {
    [self dismissKeyboards];
    
    if (txtProject.text.length == 0)
    {
        [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Please select project.", @"Please select project.") cancel:AMLocalizedString(@"Ok", @"Ok")];
        return;
    }
    if (!mAryFilteredContent || mAryFilteredContent.count == 0)
    {
        [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Please select project.", @"Please select project.") cancel:AMLocalizedString(@"Ok", @"Ok")];
        return;
    }
//    NSString * strSelected = [mAryFilteredContent objectAtIndex:selectedProjectIndex];
//    if (![strSelected isEqualToString:txtProject.text])
//    {
//        [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Please select project.", @"Please select project.") cancel:AMLocalizedString(@"Ok", @"Ok")];
//        return;
//    }

    
    User * user = [GlobalUtils loadUserObjectWithKey:global_user_info_save];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMM yy"];
    NSDate * dateFrom = [formatter dateFromString:strFromDateSave];
    NSDate * dateTo = [formatter dateFromString:strToDateSave];
    
    if([dateFrom compare: dateTo] == NSOrderedDescending) // if start is later in time than end
    {
        // do something
        [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"From date can't be greater then To date.", nil) cancel:AMLocalizedString(@"Ok", @"Ok")];
        return;

    }
    
    [formatter setDateFormat:@"dd/MM/yyyy"];
//    NSString * strIndexProject = [mAryFilteredIndex objectAtIndex:selectedProjectIndex];
//    NSDictionary * dicProject = [mArayProjects objectAtIndex:strIndexProject.integerValue];
    NSString * strUpFrom = [formatter stringFromDate:dateFrom];
    NSString * strUpTo = [formatter stringFromDate:dateTo];
    
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
//    [param setObject:txtLeaveType.text forKey:global_key_leave_type];
    [param setObject:user.strUserID forKey:global_key_user_id];
    [param setObject:user.strCompanyID forKey:global_key_company_id];
    [param setObject:@"" forKey:global_key_leave_id];
    NSString* leavetype_id = [self leaveType_idFrom:strFilterLeave];
    [param setObject:leavetype_id forKey:global_key_leavetype_id];
    [param setObject:strUpFrom forKey:global_key_start_date];
    [param setObject:strUpTo forKey:global_key_end_date];
//    [param setObject:[dicProject valueForKey:global_key_project_id] forKey:global_key_project_id];
    [param setObject:@"" forKey:global_key_project_id];
    
    if([strLeaveMasterType isEqualToString:@"ptobank"]){
        NSString* str = [NSString stringWithFormat:@"%02d:%02d", nPTOValue / 60, nPTOValue % 60];
        [param setObject:str forKey:@"total_hours"];
    }
    
    
    
    [param setObject:txtNote.text forKey:global_key_leave_description];
    
    AppDelegate * app = (AppDelegate*) [UIApplication sharedApplication].delegate;
    [app showHUD];

    //////////
    [MyRequest POST:global_api_addEmpLeave parameters:param completed:^(id result)
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
                     UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                              bundle: nil];
                     
                     UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"MyLeavesVC"];
                     [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                                              withSlideOutAnimation:YES
                                                                                      andCompletion:nil];
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

- (void) onProject:(UIButton *) btn{
    [self dismissKeyboards];

    NSString * strIndex = [mAryFilteredIndex objectAtIndex:btn.tag];
    selectedProjectIndex = strIndex.intValue;
    strFilterProject = [mAryFilteredContent objectAtIndex:btn.tag];
    [txtProject setText:strFilterProject];
    btnClearTxtProject.hidden = YES;
}
- (void) onLeave:(UIButton *) btn{
    [self dismissKeyboards];

    NSString * strIndex = [mAryFilteredIndexLeave objectAtIndex:btn.tag];
    selectedLeaveIndex = strIndex.intValue;
    strFilterLeave = [mAryFilteredContentLeave objectAtIndex:btn.tag];
    [txtLeaveType setText:strFilterLeave];
    btnClearTxtLeaveType.hidden = YES;
    [self selectLeaveType:strFilterLeave];
    [tblView reloadData];
}
- (NSString*)leaveMasterTypeFrom:(NSString*)leaveType{
    NSString* master_type = @"sick";
    NSArray* ary = [g_dicProductMaster objectForKey:@"leavetype_details"];
    for(NSDictionary* dic in ary){
        NSString* leave_type = [dic objectForKey:@"leave_type"];
        if([leaveType isEqualToString:leave_type]){
            master_type = [dic objectForKey:@"leave_master_type"];
            break;
        }
    }
    return master_type;
}
- (NSString*)leaveType_idFrom:(NSString*)leaveType{
    NSString* leavetype_id = @"1";
    NSArray* ary = [g_dicProductMaster objectForKey:@"leavetype_details"];
    for(NSDictionary* dic in ary){
        NSString* leave_type = [dic objectForKey:@"leave_type"];
        if([leaveType isEqualToString:leave_type]){
            leavetype_id = [dic objectForKey:@"leavetype_id"];
            break;
        }
    }
    return leavetype_id;
}
- (void)selectLeaveType:(NSString*)type{
    strLeaveMasterType = [self leaveMasterTypeFrom:type];

    NSDictionary * item;
    for(NSDictionary* dic in g_leftCountDetails){
        NSString* str_leave_master_type = [dic objectForKey:global_key_leave_master_type];
        if([str_leave_master_type isEqualToString:strLeaveMasterType]){
            item = dic;
            break;
        }
    }
    
    NSString* strUsedDays = [item objectForKey:@"total_approve_leave"];
    NSString* strPlanedDays = [item objectForKey:@"total_pending_leave"];
    NSString* strLeftDays = [item objectForKey:@"total_remaining_leave"];
    
    if([strLeaveMasterType isEqualToString:@"ptobank"]){
        NSString* sHour = AMLocalizedString(@"h", nil);
        NSString* sMin = AMLocalizedString(@"m", nil);

        int nUsedMins = [strUsedDays intValue];
        NSString* sUsedMins = [NSString stringWithFormat:@"%d %@", nUsedMins, sMin];
//        if(nUsedMins >= 60)
            sUsedMins = [NSString stringWithFormat:@"%d %@ %d %@", nUsedMins / 60, sHour, nUsedMins % 60, sMin];
        
        [lblUsedVacation setText:[NSString stringWithFormat:@"%@: %@", AMLocalizedString(@"Used", nil), sUsedMins]];
        
        int nPlanedMins = [strPlanedDays intValue];
        NSString* sPlanedMins = [NSString stringWithFormat:@"%d %@", nPlanedMins, sMin];
//        if(nPlanedMins >= 60)
            sPlanedMins = [NSString stringWithFormat:@"%d %@ %d %@", nPlanedMins / 60, sHour, nPlanedMins % 60, sMin];
        
        [lblPlanedVacation setText:[NSString stringWithFormat:@"%@: %@", AMLocalizedString(@"Planed", nil), sPlanedMins]];
        
        
        int nLeftMins = [strLeftDays intValue];
        NSString* sLeftMins = [NSString stringWithFormat:@"%d %@", nLeftMins, sMin];
//        if(nLeftMins >= 60)
            sLeftMins = [NSString stringWithFormat:@"%d %@ %d %@", nLeftMins / 60, sHour, nLeftMins % 60, sMin];

        [lblLeftVacation setText:[NSString stringWithFormat:@"%@: %@", AMLocalizedString(@"Left", nil), sLeftMins]];

    }else{
        [lblUsedVacation setText:[NSString stringWithFormat:@"%@: %@ %@", AMLocalizedString(@"Used vacation", nil), strUsedDays, AMLocalizedString(@"days", @"days")]];
        [lblPlanedVacation setText:[NSString stringWithFormat:@"%@: %@ %@", AMLocalizedString(@"Planed vacation", nil), strPlanedDays, AMLocalizedString(@"days", @"days")]];
        [lblLeftVacation setText:[NSString stringWithFormat:@"%@: %@ %@", AMLocalizedString(@"Left vacation", nil), strLeftDays, AMLocalizedString(@"days", @"days")]];
    }

}
- (void) onToDate {
    [self dismissKeyboards];
    [txtToDate becomeFirstResponder];
}

- (void) onFromDate {
    [self dismissKeyboards];
    [txtFromDate becomeFirstResponder];
    
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

#pragma mark - Table View Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return cell_Num;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    NSString* master_type = [self leaveMasterTypeFrom:strFilterLeave];
//    if([master_type isEqualToString:@"ptobank"] &&
//       (row == cell_FromDate || row == cell_ToDate || row == cell_Duration))
//        return 0;
    
    if(![master_type isEqualToString:@"ptobank"] && row == cell_PTOBank)
        return 0;

    if (row == cell_Description)
        return cellHeight * 1.5 + 20;
    
    if (row == cell_Note)
        return cellHeight * 4;
    
    return cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"leaveRequestCell"];
    
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"leaveRequestCell"];
    }
    [cell.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    cell.layer.masksToBounds = YES;
    
    UIView * viewSep = [[UIView alloc] initWithFrame:CGRectMake(0, cellHeight - 1, global_screen_size.width, 1)];
    [viewSep setBackgroundColor:global_gray_color];
    cell.backgroundColor = [UIColor clearColor];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(padding, 0, 300, cellHeight)];
    [lblTitle setTextColor:global_nav_color];
    
    UILabel * lblValue = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, global_screen_size.width - padding, cellHeight)];
    [lblValue setTextColor:[UIColor grayColor]];
    [lblValue setTextAlignment:NSTextAlignmentRight];
    
    if (global_screen_size.width < 330)
    {
        [lblTitle setFont:[UIFont boldSystemFontOfSize:14.f]];
        [lblValue setFont:[UIFont boldSystemFontOfSize:14.f]];
    }
    else
    {
        [lblTitle setFont:[UIFont boldSystemFontOfSize:16.f]];
        [lblValue setFont:[UIFont boldSystemFontOfSize:16.f]];
    }
    
    if (indexPath.row == cell_ProjectName)
    {
        [lblTitle setText:AMLocalizedString(@"Project Name", @"Project Name")];
        [cell addSubview:lblTitle];
        [cell addSubview:txtProject];
        [cell addSubview:viewSep];
    }
    if (indexPath.row == cell_LeaveType)
    {
        [lblTitle setText:AMLocalizedString(@"Leave Type", @"Leave Type")];
        [cell addSubview:lblTitle];
        [cell addSubview:txtLeaveType];
        [cell addSubview:viewSep];
    }
    if (indexPath.row == cell_FromDate)
    {
        [lblTitle setText:AMLocalizedString(@"From Date", @"From Date")];
        [lblValue setText:strFromDateSave];
        [cell addSubview:lblTitle];
        [cell addSubview:lblValue];
        [lblValue setFrame:CGRectMake(lblValue.frame.origin.x, lblValue.frame.origin.y, global_screen_size.width - cellHeight * 2 / 3, lblValue.frame.size.height)];
        UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(global_screen_size.width - cellHeight * 1 / 2, cellHeight / 3, cellHeight / 3, cellHeight / 3)];
        UIButton * btnTmp = [[UIButton alloc] initWithFrame:lblValue.frame];
        [btnTmp addTarget:self action:@selector(onFromDate) forControlEvents:UIControlEventTouchUpInside];
        [btnTmp setBackgroundColor:[UIColor clearColor]];
        
        [btn setBackgroundImage:[UIImage imageNamed:@"calendar"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(onFromDate) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:btn];
        [cell addSubview:txtFromDate];
        [cell addSubview:btnTmp];
        [cell addSubview:viewSep];
    }
    if (indexPath.row == cell_ToDate)
    {
        [lblTitle setText:AMLocalizedString(@"To Date", @"To Date")];
        [lblValue setText:strToDateSave];
        [cell addSubview:lblTitle];
        [cell addSubview:lblValue];
        [lblValue setFrame:CGRectMake(lblValue.frame.origin.x, lblValue.frame.origin.y, global_screen_size.width - cellHeight * 2 / 3, lblValue.frame.size.height)];
        UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(global_screen_size.width - cellHeight * 1 / 2, cellHeight / 3, cellHeight / 3, cellHeight / 3)];
        UIButton * btnTmp = [[UIButton alloc] initWithFrame:lblValue.frame];
        [btnTmp addTarget:self action:@selector(onToDate) forControlEvents:UIControlEventTouchUpInside];
        [btnTmp setBackgroundColor:[UIColor clearColor]];
        [btn setBackgroundImage:[UIImage imageNamed:@"calendar"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(onToDate) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:btn];
        [cell addSubview:txtToDate];
        [cell addSubview:btnTmp];
        [cell addSubview:viewSep];
    }
    if (indexPath.row == cell_Duration)
    {
        NSString * strDateStart = strFromDateSave;
        NSString * strDateEnd = strToDateSave;
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd MMM yy"];
        NSDate * dateStart = [formatter dateFromString:strDateStart];
        NSDate * dateEnd = [formatter dateFromString:strDateEnd];
        [lblTitle setText:AMLocalizedString(@"Duration", @"Duration")];
        int numberOfDays = [self getWorkDaysFromDate:dateStart toDate:dateEnd];

        [lblValue setText:[NSString stringWithFormat:@"%d %@", numberOfDays, AMLocalizedString(@"Days", @"Days")]];
        [cell addSubview:lblTitle];
        [cell addSubview:lblValue];
        [cell addSubview:viewSep];
    }
    if (indexPath.row == cell_PTOBank){
        [cell addSubview:PTOView];
        [cell addSubview:viewSep];

    }
    if (indexPath.row == cell_Description)
    {
        [viewSep setFrame:CGRectMake(viewSep.frame.origin.x, cellHeight * 1.5 + 19, viewSep.frame.size.width, viewSep.frame.size.height)];
        [cell addSubview:lblUsedVacation];
        [cell addSubview:lblPlanedVacation];
        [cell addSubview:lblLeftVacation];
        [cell addSubview:viewSep];
        
    }
    if (indexPath.row == cell_Note)
    {
        [lblTitle setText:AMLocalizedString(@"Note", @"Note")];
        [lblTitle setFrame:CGRectMake(padding, 0, 200, cellHeight / 2)];
        [cell addSubview:lblTitle];
        [cell addSubview:txtNote];
        UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(padding, cellHeight * 3 + cellHeight / 5, global_screen_size.width - 2 * padding, cellHeight * 2 / 3)];
        [btn setBackgroundColor:global_nav_color];
        btn.layer.cornerRadius = 4.f;
        btn.layer.masksToBounds = YES;
        [btn  setTitle:AMLocalizedString(@"Send Request", @"Send Request") forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(onSend) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:btn];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
- (int)getWorkDaysFromDate:(NSDate*)from toDate:(NSDate*)to{
    NSTimeInterval secondsBetween = [from timeIntervalSinceDate:to];
    
    int numberOfDays = secondsBetween / 86400;
    
    if (numberOfDays < 0)
        numberOfDays *= -1;
    numberOfDays++;
    
    int retVal = 0;
    for (int i = 0; i < numberOfDays; i++) {
        if(![self checkForWeekend:from])
            retVal++;
        
        from = [from dateByAddingTimeInterval:60 * 60 * 24];
        
    }
    
    return retVal;
}
- (BOOL)checkForWeekend:(NSDate *)aDate {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar isDateInWeekend:aDate];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [viewProject setFrame:CGRectMake(global_screen_size.width / 2, global_screen_size.width / 7.5 + cellHeight - scrollView.contentOffset.y, global_screen_size.width / 2 - padding, btnProjectHeight * mAryFilteredIndex.count)];
    [viewLeaveType setFrame:CGRectMake(global_screen_size.width / 2, global_screen_size.width / 7.5 + cellHeight * 2 - scrollView.contentOffset.y, global_screen_size.width / 2 - padding, btnProjectHeight * mAryFilteredContentLeave.count)];
    
}
#pragma mark - Utils
- (void) initViews {
    txtNote = [[UITextView alloc] initWithFrame:CGRectMake(padding, cellHeight / 2, global_screen_size.width - 2 * padding, cellHeight * 2.5)];
    txtNote.delegate = self;
    [txtNote setTextColor:[UIColor grayColor]];
    txtNote.layer.cornerRadius = 4.f;
    txtNote.layer.borderColor = [UIColor grayColor].CGColor;
    txtNote.layer.borderWidth = 1.f;
    
    CGFloat hTextField = cellHeight;

    txtProject = [[UITextField alloc] initWithFrame:CGRectMake(global_screen_size.width / 2 - padding, 0, global_screen_size.width / 2, cellHeight)];
    [txtProject setBackgroundColor:[UIColor clearColor]];
    [txtProject setTextColor:[UIColor grayColor]];
    txtProject.delegate = self;
    [txtProject setTextAlignment:NSTextAlignmentRight];
    txtProject.placeholder = AMLocalizedString(@"Select project", @"Select project");
    
    if (g_dicProductMaster)
    {
//        NSArray * ary = [g_dicProductMaster valueForKey:global_key_project_details];
//        NSDictionary * dicOne = [ary objectAtIndex:0];
//        NSString * str = [NSString stringWithFormat:@"%@ | %@", [dicOne valueForKey:global_key_project_number], [dicOne valueForKey:global_key_project_name]];
        NSString * str = g_strLastWorkedProjectName;
        [txtProject setText:str];
        mAryFilteredContent = [[NSMutableArray alloc] init];
        [mAryFilteredContent addObject:str];
        mAryFilteredIndex = [[NSMutableArray alloc] init];
        [mAryFilteredIndex addObject:@"0"];
        strFilterProject = str;
        mArayProjects = [[NSMutableArray alloc] init];
        NSArray * arys = [g_dicProductMaster valueForKey:global_key_project_details];
        mArayProjects = [arys mutableCopy];
        
        for (int i = 0; i < mArayProjects.count; i ++) {
            NSDictionary * dicOne = [mArayProjects objectAtIndex:i];
            NSString * str = [NSString stringWithFormat:@"%@ | %@", [dicOne valueForKey:global_key_project_number], [dicOne valueForKey:global_key_project_name]];
            if([str isEqualToString:strFilterProject])
                selectedProjectIndex = i;
        }

    }
    {
        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 22, hTextField)];
        btnClearTxtProject = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnClearTxtProject setFrame:CGRectMake(4, (hTextField - 18)/2, 18, 18)];
        [btnClearTxtProject setImage:[UIImage imageNamed:@"circle_close"] forState:UIControlStateNormal];
        [btnClearTxtProject addTarget:self action:@selector(clearTextField:) forControlEvents:UIControlEventTouchUpInside];
        [rightView addSubview:btnClearTxtProject];
        btnClearTxtProject.hidden = YES;
        
        txtProject.rightView = rightView;
        txtProject.rightViewMode = UITextFieldViewModeAlways;
    }

    txtLeaveType = [[UITextField alloc] initWithFrame:CGRectMake(global_screen_size.width / 2, 0, global_screen_size.width / 2 - padding, cellHeight)];
    [txtLeaveType setBackgroundColor:[UIColor clearColor]];
    [txtLeaveType setTextColor:[UIColor grayColor]];
    txtLeaveType.delegate = self;
    [txtLeaveType setTextAlignment:NSTextAlignmentRight];
    txtLeaveType.placeholder = AMLocalizedString(@"Select leave type", @"Select leave type");
    {
        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 22, hTextField)];
        btnClearTxtLeaveType = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnClearTxtLeaveType setFrame:CGRectMake(4, (hTextField - 18)/2, 18, 18)];
        [btnClearTxtLeaveType setImage:[UIImage imageNamed:@"circle_close"] forState:UIControlStateNormal];
        [btnClearTxtLeaveType addTarget:self action:@selector(clearTextField:) forControlEvents:UIControlEventTouchUpInside];
        [rightView addSubview:btnClearTxtLeaveType];
        btnClearTxtLeaveType.hidden = YES;
        
        txtLeaveType.rightView = rightView;
        txtLeaveType.rightViewMode = UITextFieldViewModeAlways;
    }

    mPickerFrom = [[UIDatePicker alloc] init];
    [mPickerFrom setTintColor:[UIColor clearColor]];
    mPickerFrom.datePickerMode = UIDatePickerModeDate;
    
    txtFromDate = [[UITextField alloc] initWithFrame:CGRectMake(txtProject.frame.origin.x, txtProject.frame.origin.y, 0, txtProject.frame.size.height)];
    
    [txtFromDate setBackgroundColor:[UIColor clearColor]];
    txtFromDate.delegate = self;
    [txtFromDate setInputView:mPickerFrom];
    
    UIToolbar *toolBar=[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, global_screen_size.width, 44)];
    [toolBar setTintColor:[UIColor clearColor]];
    [toolBar setBarTintColor:global_nav_color];
    toolBar.barStyle = UIBarStyleDefault;
    toolBar.translucent = YES;
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:AMLocalizedString(@"Done", @"Done") style:UIBarButtonItemStyleDone target:self action:@selector(onDatePickerDone)];
    [doneBtn setTintColor:[UIColor lightGrayColor]];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [space setTintColor:[UIColor clearColor]];
    [toolBar setItems:[NSArray arrayWithObjects:space, doneBtn, nil]];
    [txtFromDate setInputAccessoryView:toolBar];

    mPickerTo = [[UIDatePicker alloc] init];
    [mPickerTo setTintColor:[UIColor clearColor]];
    mPickerTo.datePickerMode = UIDatePickerModeDate;
    
    txtToDate = [[UITextField alloc] initWithFrame:CGRectMake(txtProject.frame.origin.x, txtProject.frame.origin.y, 0, txtProject.frame.size.height)];
    [txtToDate setBackgroundColor:[UIColor clearColor]];
    txtToDate.delegate = self;
    [txtToDate setInputView:mPickerTo];
    [txtToDate setInputAccessoryView:toolBar];
    
    NSDate * date = [NSDate date];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMM yy"];
    strFromDateSave = [formatter stringFromDate:date];
    strToDateSave = [formatter stringFromDate:date];

    if (global_screen_size.width < 330)
    {
        [txtNote setFont:[UIFont boldSystemFontOfSize:14.f]];
        [txtProject setFont:[UIFont boldSystemFontOfSize:14.f]];
        [txtLeaveType setFont:[UIFont boldSystemFontOfSize:14.f]];
    }
    else
    {
        [txtNote setFont:[UIFont boldSystemFontOfSize:16.f]];
        [txtProject setFont:[UIFont boldSystemFontOfSize:16.f]];
        [txtLeaveType setFont:[UIFont boldSystemFontOfSize:16.f]];
    }
    
    lblUsedVacation = [[UILabel alloc] initWithFrame:CGRectMake(padding, 10, 300, cellHeight / 2)];
    [lblUsedVacation setTextColor:[UIColor grayColor]];
    
    lblPlanedVacation = [[UILabel alloc] initWithFrame:CGRectMake(padding, lblUsedVacation.frame.origin.y + lblUsedVacation.frame.size.height, 300, cellHeight / 2)];
    [lblPlanedVacation setTextColor:[UIColor grayColor]];
    
    lblLeftVacation = [[UILabel alloc] initWithFrame:CGRectMake(padding, lblPlanedVacation.frame.size.height + lblPlanedVacation.frame.origin.y, 300, cellHeight / 2)];
    [lblLeftVacation setTextColor:[UIColor grayColor]];
    if (global_screen_size.width < 330)
    {
        [lblUsedVacation setFont:[UIFont boldSystemFontOfSize:13.f]];
        [lblPlanedVacation setFont:[UIFont boldSystemFontOfSize:13.f]];
        [lblLeftVacation setFont:[UIFont boldSystemFontOfSize:13.f]];
    }
    else
    {
        [lblUsedVacation setFont:[UIFont boldSystemFontOfSize:15.f]];
        [lblPlanedVacation setFont:[UIFont boldSystemFontOfSize:15.f]];
        [lblLeftVacation setFont:[UIFont boldSystemFontOfSize:15.f]];
    }

    [self initPTOView:toolBar];

    if (mAryLeaveType && mAryLeaveType.count)
    {
        NSString * str = [mAryLeaveType objectAtIndex:0];
        [txtLeaveType setText:str];
        strFilterLeave = str;
        [self selectLeaveType:str];
    }

}
- (void)initPTOView:(UIToolbar*)toolBar{
    CGFloat clockHeight = 22.f;
    if (global_screen_size.width < 330)
        clockHeight = 18.f;
    
    PTOView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, cellHeight)];
    
    mPickerHours = [[UIPickerView alloc] init];
    [mPickerHours setTintColor:[UIColor clearColor]];
    mPickerHours.delegate = self;
    
    CGFloat x = global_screen_size.width / 2;
    UIView* line = [[UIView alloc] initWithFrame:CGRectMake(x, 4, 1, cellHeight - 8)];
    line.backgroundColor = global_gray_color;
    [PTOView addSubview:line];
    
    CGFloat w = (global_screen_size.width - padding * 4) / 2;
    txtPTOHours = [[UITextField alloc] initWithFrame:CGRectMake(padding * 2, 0, w, cellHeight)];
    [txtPTOHours setInputView:mPickerHours];
    txtPTOHours.delegate = self;
    [PTOView addSubview:txtPTOHours];
    [txtPTOHours setInputAccessoryView:toolBar];
    txtPTOHours.text = [NSString stringWithFormat:@"00 %@", AMLocalizedString(@"Hrs", nil)];
    [txtPTOHours setTextColor:global_nav_color];

    mPickerMinutes = [[UIPickerView alloc] init];
    [mPickerMinutes setTintColor:[UIColor clearColor]];
    mPickerMinutes.delegate = self;
    txtPTOMinutes = [[UITextField alloc] initWithFrame:CGRectMake(global_screen_size.width / 2 +padding * 2, 0, w, cellHeight)];
    [txtPTOMinutes setInputView:mPickerMinutes];
    txtPTOMinutes.delegate = self;
    [PTOView addSubview:txtPTOMinutes];
    [txtPTOMinutes setInputAccessoryView:toolBar];
    txtPTOMinutes.text = [NSString stringWithFormat:@"00 %@", AMLocalizedString(@"Min", nil)];
    [txtPTOMinutes setTextColor:global_nav_color];

    UIImageView * imghour50 = [[UIImageView alloc] initWithFrame:CGRectMake(x - 10 - clockHeight, (cellHeight - clockHeight) / 2, clockHeight, clockHeight)];
    [imghour50 setImage:[UIImage imageNamed:@"clock"]];
    [PTOView addSubview:imghour50];
    
    UIImageView * imgminute50 = [[UIImageView alloc] initWithFrame:CGRectMake(global_screen_size.width - 10 - clockHeight, (cellHeight - clockHeight) / 2, clockHeight, clockHeight)];
    [imgminute50 setImage:[UIImage imageNamed:@"clock"]];
    [PTOView addSubview:imgminute50];
    
    if (global_screen_size.width < 330)
    {
        [txtPTOHours setFont:[UIFont boldSystemFontOfSize:14.f]];
        [txtPTOMinutes setFont:[UIFont boldSystemFontOfSize:14.f]];
    }
    else
    {
        [txtPTOHours setFont:[UIFont boldSystemFontOfSize:16.f]];
        [txtPTOMinutes setFont:[UIFont boldSystemFontOfSize:16.f]];
    }

}
-(void)clearTextField:(UIButton*)sender
{
    if(sender == btnClearTxtProject){
        txtProject.text = @"";
        strFilterProject = @"";
        [self updateProjectsArray];
        btnClearTxtProject.hidden = YES;
        [txtProject becomeFirstResponder];
    }else if(sender == btnClearTxtLeaveType){
        txtLeaveType.text = @"";
        strFilterLeave = @"";
        [self updateLeaveArray];
        btnClearTxtLeaveType.hidden = YES;
        [txtLeaveType becomeFirstResponder];
    }
}

- (void) updateProjectsArray {
    mAryFilteredIndex = [[NSMutableArray alloc] init];
    mArayProjects = [[NSMutableArray alloc] init];
    mAryOrg = [[NSMutableArray alloc] init];
    mAryFilteredIndex = [[NSMutableArray alloc] init];
    mAryFilteredContent = [[NSMutableArray alloc] init];
    if (!g_dicProductMaster)
    {
        [self getMasterUpdated];
        return;
    }
    NSArray * ary = [g_dicProductMaster valueForKey:global_key_project_details];
    
    mArayProjects = [ary mutableCopy];
    if (!strFilterProject) strFilterProject = @"";
    NSString * pref = strFilterProject;
    NSMutableArray * aryMut = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < mArayProjects.count; i ++) {
        NSDictionary * dicOne = [mArayProjects objectAtIndex:i];
        NSString * str = [NSString stringWithFormat:@"%@ | %@", [dicOne valueForKey:global_key_project_number], [dicOne valueForKey:global_key_project_name]];
        [aryMut addObject:str];
        [mAryOrg addObject:str];
    }
    
//    NSArray *filteredArray = [aryMut filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF like  %@", [pref stringByAppendingString:@"*"]]];
//    for (int i = 0; i < filteredArray.count; i ++) {
//        for (int j = 0; j < aryMut.count; j ++) {
//            NSString * strCom = [aryMut objectAtIndex:j];
//            NSString * str = [filteredArray objectAtIndex:i];
//            if ([strCom isEqualToString:str]) {
//                [mAryFilteredIndex addObject:[NSString stringWithFormat:@"%d", j]];
//                break;
//            }
//        }
//        
//    }
    
    NSMutableArray* filteredArray = [[NSMutableArray alloc] init];
    for(int i = 0; i < aryMut.count; i++){
        NSString * string = [aryMut objectAtIndex:i];
        if([[string lowercaseString] rangeOfString:[strFilterProject lowercaseString]].location != NSNotFound ||
           strFilterProject.length == 0){
            [mAryFilteredIndex addObject:[NSString stringWithFormat:@"%d", i]];
            [filteredArray addObject:string];
        }
    }

    if (filteredArray && filteredArray.count)
    {
        mAryFilteredContent = [filteredArray mutableCopy];
    }
    [self updateProjectView];
}
- (void) updateProjectView
{
    
    NSUInteger max = mAryFilteredIndex.count;
    if(max > 6)
        max = 6;
    viewProject.contentSize = CGSizeMake(viewProject.frame.size.width, btnProjectHeight * mAryFilteredIndex.count);
    [viewProject setFrame:CGRectMake(viewProject.frame.origin.x, viewProject.frame.origin.y, viewProject.frame.size.width, btnProjectHeight * max)];

    [viewProject.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    for (int i = 0; i < mAryFilteredIndex.count; i ++)
    {
        UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(0, i * btnProjectHeight - 1, viewProject.frame.size.width - padding, btnProjectHeight)];
        [btn setBackgroundColor:[UIColor clearColor]];
        [btn setTitleColor:global_nav_color forState:UIControlStateNormal];
        [btn setTitle:[mAryFilteredContent objectAtIndex:i] forState:UIControlStateNormal];
        if (global_screen_size.width < 330)
        {
            [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:14.f]];
        }
        else
        {
            [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:16.f]];
        }
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        btn.tag = i;
        [btn addTarget:self action:@selector(onProject:) forControlEvents:UIControlEventTouchUpInside];
        [viewProject addSubview:btn];
        UIView * viewSep = [[UIView alloc] initWithFrame:CGRectMake(0, btn.frame.origin.y + btn.frame.size.height, btn.frame.size.width, 1)];
        [viewSep setBackgroundColor:global_darkgray_color];
        if (i != mAryFilteredIndex.count - 1)
            [viewProject addSubview:viewSep];
    }
}

- (void) updateLeaveArray {
    mAryFilteredIndexLeave = [[NSMutableArray alloc] init];
    mAryFilteredContentLeave = [[NSMutableArray alloc] init];
    if (!strFilterLeave) strFilterLeave = @"";
    NSString * pref = strFilterLeave;
    NSMutableArray * aryMut = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < mAryLeaveType.count; i ++) {
        NSString * str = [mAryLeaveType objectAtIndex:i];
        [aryMut addObject:str];
    }
    
    NSArray *filteredArray = [aryMut filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF like  %@", [pref stringByAppendingString:@"*"]]];
    for (int i = 0; i < filteredArray.count; i ++) {
        for (int j = 0; j < aryMut.count; j ++) {
            NSString * strCom = [aryMut objectAtIndex:j];
            NSString * str = [filteredArray objectAtIndex:i];
            if ([strCom isEqualToString:str]) {
                [mAryFilteredIndexLeave addObject:[NSString stringWithFormat:@"%d", j]];
                break;
            }
        }
        
    }
    if (filteredArray && filteredArray.count)
    {
        mAryFilteredContentLeave = [filteredArray mutableCopy];
    }
    [self updateLeaveView];
}
- (void) updateLeaveView
{
    [viewLeaveType setFrame:CGRectMake(viewLeaveType.frame.origin.x, viewLeaveType.frame.origin.y, viewLeaveType.frame.size.width, btnProjectHeight * mAryFilteredIndexLeave.count)];
    [viewLeaveType.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    for (int i = 0; i < mAryFilteredIndexLeave.count; i ++)
    {
        UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(0, i * btnProjectHeight - 1, viewLeaveType.frame.size.width - padding, viewLeaveType.frame.size.height / mAryFilteredIndexLeave.count - 1)];
        [btn setBackgroundColor:[UIColor clearColor]];
        [btn setTitleColor:global_nav_color forState:UIControlStateNormal];
        [btn setTitle:[mAryFilteredContentLeave objectAtIndex:i] forState:UIControlStateNormal];
        if (global_screen_size.width < 330)
        {
            [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:14.f]];
        }
        else
        {
            [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:16.f]];
        }
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        btn.tag = i;
        [btn addTarget:self action:@selector(onLeave:) forControlEvents:UIControlEventTouchUpInside];
        [viewLeaveType addSubview:btn];
        UIView * viewSep = [[UIView alloc] initWithFrame:CGRectMake(0, btn.frame.origin.y + btn.frame.size.height, btn.frame.size.width, 1)];
        [viewSep setBackgroundColor:global_darkgray_color];
        if (i != mAryFilteredIndexLeave.count - 1)
            [viewLeaveType addSubview:viewSep];
    }
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
                         [self updateProjectsArray];
                     }
                 }
                 return;
             }
         }
     }];
}

#pragma mark - UITextField Delegate
- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == txtProject) {
        btnClearTxtProject.hidden = YES;
    }else if (textField == txtLeaveType) {
        btnClearTxtLeaveType.hidden = YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (textField == txtProject)
    {
        [viewProject setHidden:YES];
    }
    if (textField == txtLeaveType)
    {
        [viewLeaveType setHidden:YES];
    }
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == txtProject)
    {
        strFilterProject = [[textField text] stringByReplacingCharactersInRange:range withString:string];
        [self updateProjectsArray];
    }
    if (textField == txtLeaveType)
    {
        strFilterLeave = [[textField text] stringByReplacingCharactersInRange:range withString:string];
        [self updateLeaveArray];
    }
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    [textField setReturnKeyType:UIReturnKeyDone];
    [viewProject setHidden:YES];
    [viewLeaveType setHidden:YES];
    CGPoint point;
    if (textField == txtProject)
    {
        btnClearTxtProject.hidden = NO;
        [viewProject setHidden:NO];
        [self updateProjectsArray];
    }
    if (textField == txtLeaveType)
    {
        btnClearTxtLeaveType.hidden = NO;
        [viewLeaveType setHidden:NO];
        [self updateLeaveArray];
    }
    point =  [textField convertPoint:CGPointMake(0,0) toView:nil];
    if (point.y + textField.frame.size.height  + global_keyboardHeight + 20 > global_screen_size.height)
    {
        flagKeyboardAnimate = YES;
        offsetAnimation = point.y + textField.frame.size.height  + global_keyboardHeight + 20 - global_screen_size.height;
    }
    else
    {
        flagKeyboardAnimate = NO;
    }
    return YES;
}
- (void) onKeyboardShow:(id)sender {
    
    if (flagKeyboardAnimate) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        [tblView setContentOffset:CGPointMake(tblView.contentOffset.x, tblView.contentOffset.y + offsetAnimation)];
        [UIView commitAnimations];
    }
    
}
- (void) onKeyboardHide:(id)sender {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [tblView setContentOffset:CGPointMake(0, 0)];
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
}

#pragma mark - TextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    CGPoint point =  [textView convertPoint:CGPointMake(0,0) toView:nil];
    if (point.y + textView.frame.size.height  + global_keyboardHeight + 20 > global_screen_size.height)
    {
        flagKeyboardAnimate = YES;
        offsetAnimation = point.y + textView.frame.size.height  + global_keyboardHeight + 20 - global_screen_size.height;
    }
    else
    {
        flagKeyboardAnimate = NO;
    }
    return YES;
}

#pragma mark - TapGesture

- (void) dismissKeyboards {
    
    if(!btnClearTxtProject.hidden){
        txtProject.text = @"";
        strFilterProject = @"";
        btnClearTxtProject.hidden = YES;
        [self updateProjectsArray];
        
        [txtProject becomeFirstResponder];
        return;
    }
    if(!btnClearTxtLeaveType.hidden){
        txtLeaveType.text = @"";
        strFilterLeave = @"";
        btnClearTxtLeaveType.hidden = YES;
        [self updateLeaveArray];
        
        [txtLeaveType becomeFirstResponder];
        return;
    }
    [viewLeaveType setHidden:YES];
    [viewProject setHidden:YES];
    [txtProject resignFirstResponder];
    [txtLeaveType resignFirstResponder];
    [txtToDate resignFirstResponder];
    [txtFromDate resignFirstResponder];
    [txtNote resignFirstResponder];
    [txtPTOHours resignFirstResponder];
    [txtPTOMinutes resignFirstResponder];

}

#pragma mark - UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == mPickerHours)
        return 100;
    if (pickerView == mPickerMinutes)
        return 60;
    return 100;
}
- (CGSize)rowSizeForComponent:(NSInteger)component{
    return CGSizeMake(global_screen_size.width, 44);
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    
    UILabel *label= [[UILabel alloc] initWithFrame:CGRectMake(0, 00, global_screen_size.width, 44.0)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor blackColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    if (global_screen_size.width < 330)
        [label setFont:[UIFont systemFontOfSize:20.0]];
    else
        [label setFont:[UIFont systemFontOfSize:23.0]];
    
    NSString * strValue;
    if (row < 10)
        strValue = [NSString stringWithFormat:@"0%lu", (long)row];
    else
        strValue = [NSString stringWithFormat:@"%lu", (long)row];
    
    if (pickerView == mPickerHours)
        [label setText:[NSString stringWithFormat:@"%@ %@", strValue, AMLocalizedString(@"Hrs", nil)]];
    if (pickerView == mPickerMinutes)
        [label setText:[NSString stringWithFormat:@"%@ %@", strValue, AMLocalizedString(@"Min", nil)]];
    return label;
}

@end
