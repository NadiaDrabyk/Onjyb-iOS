//
//  HomeVC.m
//  Onjyb
//
//  Created by Nadia Drabyk on 7/16/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import "HomeVC.h"
#import "RegisterTimeDetailsVC.h"
#import "CompletedTasksDetailVC.h"
#import "AppDelegate.h"

@interface HomeVC ()

@end

@implementation HomeVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [SlideNavigationController sharedInstance].delegate = self;
    [self setTitle:AMLocalizedString(@"Home", @"Home")];
    [lblSelectProject setText:AMLocalizedString(@"Select Project", @"Select Project")];
    selectedProjectIndex = 0;
    lblLatestActivity.text = AMLocalizedString(@"Latest Activities", nil);
    
    [lblLatestActivity setBackgroundColor:global_nav_color];
    txtProject.layer.borderColor = [UIColor grayColor].CGColor;
    txtProject.layer.borderWidth = 1.f;
    txtProject.layer.cornerRadius = 3.f;
    txtProject.layer.masksToBounds = YES;
    CGFloat h = txtProject.frame.size.height;
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, h)];
    txtProject.leftView = paddingView;
    txtProject.leftViewMode = UITextFieldViewModeAlways;
    
    UIButton *rightView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, h)];
    [rightView addTarget:self action:@selector(clearTextField:) forControlEvents:UIControlEventTouchUpInside];

    btnClearTxtProject = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnClearTxtProject setFrame:CGRectMake(0, (h-16)/2, 16, 16)];
    [btnClearTxtProject setImage:[UIImage imageNamed:@"circle_close"] forState:UIControlStateNormal];
    [btnClearTxtProject addTarget:self action:@selector(clearTextField:) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:btnClearTxtProject];
    btnClearTxtProject.hidden = YES;
    
    UIButton *btnArrow = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnArrow setFrame:CGRectMake(18, (h-18)/2, 18, 18)];
    [btnArrow setImage:[UIImage imageNamed:@"gray_down_arrow"] forState:UIControlStateNormal];
    [btnArrow addTarget:self action:@selector(clearTextField:) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:btnArrow];
    txtProject.rightView = rightView;
    txtProject.rightViewMode = UITextFieldViewModeAlways;
    
    UILabel * lblNumber = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, global_screen_size.width / 10, global_screen_size.width * 8 / 75)];
    [lblNumber setTextColor:[UIColor whiteColor]];
    [lblNumber setText:@"#"];
    [lblNumber setTextAlignment:NSTextAlignmentCenter];
    [viewHeader addSubview:lblNumber];
    [txtProject setTextColor:[UIColor grayColor]];
    
    UILabel * lblProject = [[UILabel alloc] initWithFrame:CGRectMake(global_screen_size.width / 10, 0, global_screen_size.width * 7 / 30, lblNumber.frame.size.height)];
    [lblProject setText:AMLocalizedString(@"Project", @"Project")];
    [lblProject setTextColor:[UIColor whiteColor]];
    [lblProject setTextAlignment:NSTextAlignmentCenter];
    [viewHeader addSubview:lblProject];
    
    UILabel * lblDate = [[UILabel alloc] initWithFrame:CGRectMake(global_screen_size.width / 3, 0, lblProject.frame.size.width, lblProject.frame.size.height)];
    [lblDate setText:AMLocalizedString(@"Date", @"Date")];
    [lblDate setTextColor:[UIColor whiteColor]];
    [lblDate setTextAlignment:NSTextAlignmentCenter];
    [viewHeader addSubview:lblDate];
    
    UILabel * lblHours = [[UILabel alloc] initWithFrame:CGRectMake(lblDate.frame.origin.x + lblDate.frame.size.width, 0, lblProject.frame.size.width, lblProject.frame.size.height)];
    [lblHours setText:AMLocalizedString(@"Hours", @"Hours")];
    [lblHours setTextColor:[UIColor whiteColor]];
    [lblHours setTextAlignment:NSTextAlignmentCenter];
    [viewHeader addSubview:lblHours];
    
    UILabel * lblKm = [[UILabel alloc] initWithFrame:CGRectMake(lblHours.frame.origin.x + lblHours.frame.size.width, 0, lblNumber.frame.size.width * 2, lblProject.frame.size.height)];
    [lblKm setText:AMLocalizedString(@"Km.", @"Km.")];
    [lblKm setTextColor:[UIColor whiteColor]];
    [lblKm setTextAlignment:NSTextAlignmentCenter];
    [viewHeader addSubview:lblKm];
    
    if (global_screen_size.width < 330)
    {
        [lblSelectProject setFont:[UIFont boldSystemFontOfSize:15.f]];
        [lblLatestActivity setFont:[UIFont boldSystemFontOfSize:15.f]];
        [txtProject setFont:[UIFont boldSystemFontOfSize:15.f]];
        [lblProject setFont:[UIFont boldSystemFontOfSize:15.f]];
        [lblNumber setFont:[UIFont systemFontOfSize:15.f]];
        [lblHours setFont:[UIFont systemFontOfSize:15.f]];
        [lblKm setFont:[UIFont systemFontOfSize:15.f]];
        [lblDate setFont:[UIFont systemFontOfSize:15.f]];
    }
    else
    {
        [lblSelectProject setFont:[UIFont boldSystemFontOfSize:17.f]];
        [lblLatestActivity setFont:[UIFont boldSystemFontOfSize:17.f]];
        [txtProject setFont:[UIFont boldSystemFontOfSize:17.f]];
        [lblProject setFont:[UIFont boldSystemFontOfSize:17.f]];
        [lblNumber setFont:[UIFont systemFontOfSize:17.f]];
        [lblHours setFont:[UIFont systemFontOfSize:17.f]];
        [lblKm setFont:[UIFont systemFontOfSize:17.f]];
        [lblDate setFont:[UIFont systemFontOfSize:17.f]];
    }
    [txtProject setPlaceholder:AMLocalizedString(@"Select Project", @"Select Project")];
    
    CGFloat heightTopView = global_screen_size.width * 64 / 375;
    CGFloat leftLabelWidth = heightTopView * 135 / 64;
    CGFloat txtProjectWidth = global_screen_size.width - 16 - leftLabelWidth;
    CGFloat txtProjectHeight = txtProjectWidth * 9 / 70;
    CGFloat pad = (heightTopView - txtProjectHeight) / 2;
    cellHeight = txtProjectHeight + 10;
    tblProject = [[UITableView alloc] initWithFrame:CGRectMake(leftLabelWidth, pad + txtProjectHeight + 0.5, txtProjectWidth, txtProjectWidth)];
    tblProject.delegate = self;
    tblProject.dataSource = self;
    tblProject.layer.cornerRadius = 3.f;
    tblProject.layer.borderColor = global_darkgray_color.CGColor;
    tblProject.layer.borderWidth = 1.f;
    tblProject.layer.masksToBounds = YES;
    [tblProject setBackgroundColor:[UIColor whiteColor]];
    [tblProject setHidden:YES];
    [self.view addSubview:tblProject];
    
    
    dimView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, global_screen_size.width, global_screen_size.height)];
    [dimView setBackgroundColor:[UIColor blackColor]];
    [dimView setAlpha:0.6];
    [self.view addSubview:dimView];
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboards)];
    tapGesture.delegate = self;
//    [self.view addGestureRecognizer:tapGesture];
    
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [app registerForRemoteNotification];
}
-(void)clearTextField:(UIButton*)sender
{
    txtProject.text = @"";
    strFilter = @"";
    [tblProject reloadData];
    [txtProject becomeFirstResponder];
}
-(void)arrowTextField:(UIButton*)sender
{
    [tblProject setHidden:NO];
    strFilter = txtProject.text;
    [tblProject reloadData];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openMenu:) name:global_notification_slide_open object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(revealMenu:) name:global_notification_slide_reveal object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeMenu:) name:global_notification_slide_close object:nil];
    [dimView setHidden:YES];
    
    if (!g_dicProductMaster)
    {
        [self getMasterUpdated];
    }
//    else {
//        [self drawChart];
//    }
    [self getTaskList];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (void) viewWillDisappear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:global_notification_slide_close object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:global_notification_slide_open object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:global_notification_slide_reveal object:nil];
}

#pragma mark - TableView Delegate
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!g_dicProductMaster)
    {
        return 0;
    }
    NSArray * ary = [g_dicProductMaster valueForKey:global_key_project_details];
    mArayProjects = [[NSMutableArray alloc] init];
    mArayProjects = [ary mutableCopy];
    if (!strFilter) strFilter = @"";
    NSString * pref = strFilter;
    
    NSMutableArray * aryMut = [[NSMutableArray alloc] init];
    mAryOrg = [[NSMutableArray alloc] init];
    for (int i = 0; i < mArayProjects.count; i ++) {
        NSDictionary * dicOne = [mArayProjects objectAtIndex:i];
        NSString * str = [NSString stringWithFormat:@"%@ | %@", [dicOne valueForKey:global_key_project_number], [dicOne valueForKey:global_key_project_name]];
        [aryMut addObject:str];
        [mAryOrg addObject:str];
    }
    mAryFilteredIndex = [[NSMutableArray alloc] init];
    
    
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
        if([[string lowercaseString] rangeOfString:[strFilter lowercaseString]].location != NSNotFound ||
           strFilter.length == 0){
            [mAryFilteredIndex addObject:[NSString stringWithFormat:@"%d", i]];
            [filteredArray addObject:string];
        }
    }
    
    mAryFilteredContent = [[NSMutableArray alloc] init];
    if (filteredArray && filteredArray.count)
    {
        mAryFilteredContent = [filteredArray mutableCopy];
    }
    return mAryFilteredContent.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!g_dicProductMaster)
        return 0;
    return cellHeight;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"homeProjectCell"];
    
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"homeProjectCell"];
    }
    [cell.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    
//    UIView * viewSep = [[UIView alloc] initWithFrame:CGRectMake(0, cellHeight - 1, global_screen_size.width, 1)];
//    [viewSep setBackgroundColor:global_gray_color];
    cell.backgroundColor = [UIColor clearColor];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    NSString * strCell = [mAryFilteredContent objectAtIndex:indexPath.row];
    UILabel * lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200, cellHeight)];
    [lbl setTextColor:global_nav_color];
    if (global_screen_size.width < 330)
    {
        [lbl setFont:[UIFont boldSystemFontOfSize:14.f]];
    }
    else
    {
        [lbl setFont:[UIFont boldSystemFontOfSize:16.f]];
    }
    [lbl setText:strCell];
    [cell addSubview:lbl];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSString * strSelected = [mAryFilteredIndex objectAtIndex:indexPath.row];
    selectedProjectIndex = strSelected.intValue;
    [txtProject setText:[mAryFilteredContent objectAtIndex:indexPath.row]];
    strFilter = txtProject.text;
    [txtProject resignFirstResponder];
    [tblProject setHidden:YES];
    
    
    NSArray*    aryProjectDetails = [g_dicProductMaster valueForKey:global_key_project_details];
    if (aryProjectDetails && aryProjectDetails.count > selectedProjectIndex)
    {
        NSDictionary * dicOne = [aryProjectDetails objectAtIndex:selectedProjectIndex];
        [self drawChart:dicOne];
    }
}

#pragma mark - Button Actions
- (IBAction)onMenu:(id)sender
{
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
}

- (IBAction)onRegister:(id)sender
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    
    UIViewController *vc ;
    
    vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"RegisterTimeVC"];
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                             withSlideOutAnimation:YES
                                                                     andCompletion:nil];
}
- (void) onSelectItem:(UIButton *) btn{
    NSDictionary *dicOne = [mAryTaskList objectAtIndex:btn.tag];
    NSString * strApprove = [dicOne valueForKey:global_key_approve_status];
    if ([strApprove isEqualToString:global_value_approve])
    {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        CompletedTasksDetailVC * vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"CompletedTasksDetailVC"];
        vc.dicInfo = [dicOne mutableCopy];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    RegisterTimeDetailsVC * vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"RegisterTimeDetailsVC"];
    
    vc.dicInfo = [dicOne mutableCopy];
    vc.valueMode = global_value_mode_save;
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

- (void) getTaskList {
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
    [param setObject:@"" forKey:global_key_approve_status];
    [param setObject:@"1" forKey:global_key_page_number];
    
    //////////
    [MyRequest POST:global_api_getMyTaskList parameters:param completed:^(id result)
     {
         [app hideHUD];
         
         //20170818
         BOOL isOpeneRegisterTimeView = [[NSUserDefaults standardUserDefaults] boolForKey:@"isOpeneRegisterTimeView"];
         if(!isOpeneRegisterTimeView)
         {
             UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
             UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"RegisterTimeVC"];
             
             [[SlideNavigationController sharedInstance] pushViewController:vc animated:YES];
             [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isOpeneRegisterTimeView"];
         }
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
                         [self buildScrollView:dicResObject];
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
//                         [self drawChart];
                         [tblProject reloadData];
                     }
                 }
                 return;
             }
         }
     }];
}

- (void) drawChart:(NSDictionary*)dicOne {
    _barValues = [[NSMutableArray alloc] init];
    _barColors = [[NSMutableArray alloc] init];
    _barLabels = [[NSMutableArray alloc] init];
//    mAryProjectDetails = [g_dicProductMaster valueForKey:global_key_project_details];
//    if (mAryProjectDetails)
    {
//        NSDictionary * dicOne = [mAryProjectDetails objectAtIndex:selectedProjectIndex];
        [txtProject setText:[NSString stringWithFormat:@"%@ | %@", [dicOne valueForKey:global_key_project_number], [dicOne valueForKey:global_key_project_name]]];
        strFilter = txtProject.text;
        NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
        [param setObject:[dicOne valueForKey:global_key_project_id] forKey:global_key_project_id];
        AppDelegate * app = (AppDelegate*) [UIApplication sharedApplication].delegate;
        [app showHUD];
        //////////
        [MyRequest POST:global_api_getGraph parameters:param completed:^(id result)
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
                             [chartScroll.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
                             _barChartViews							= [[SimpleBarChart alloc] initWithFrame:CGRectMake(0, 40, global_screen_size.width, global_screen_size.width * 81 / 125 - 40)];
                             _barChartViews.center					= CGPointMake(_barChartViews.frame.size.width / 2.0, _barChartViews.frame.size.height / 2.0 + 20);
                             _barChartViews = [_barChartViews initWithFrame:_barChartViews.frame];
                             NSArray * aryBarGraph = [dicResObject objectForKey:global_key_bar_graph];
                             for (int i = 0; i < aryBarGraph.count; i ++) {
                                 NSDictionary * dicOne = [aryBarGraph objectAtIndex:i];
                                 NSNumber * numValue = [dicOne valueForKey:global_key_actual_value];
                                 if ([numValue isKindOfClass:[NSString class]]) {
                                     NSString * str = [dicOne valueForKey:global_key_actual_value];
                                     [_barValues addObject:[NSNumber numberWithInt:str.intValue / 60]];
                                 }
                                 else {
                                     [_barValues addObject:[NSNumber numberWithInt:numValue.intValue / 60]];
                                 }
                                 NSString * strcolor2 = [dicOne valueForKey:global_key_color_2];
                                 
                                 NSRange rng;
                                 rng.length = 2;
                                 rng.location = 0;
                                 NSString * strRed = [strcolor2 substringWithRange:rng];
                                 rng.location += 2;
                                 NSString * strGreen = [strcolor2 substringWithRange:rng];
                                 rng.location += 2;
                                 NSString * strBlue = [strcolor2 substringWithRange:rng];
                                 unsigned int resultRed = 0;
                                 unsigned int resultGreen = 0;
                                 unsigned int resultBlue = 0;
                                 
                                 NSScanner *scanner = [NSScanner scannerWithString:strRed];
                                 [scanner setScanLocation:0]; // bypass '#' character
                                 [scanner scanHexInt:&resultRed];
                                 
                                 scanner = [NSScanner scannerWithString:strGreen];
                                 [scanner scanHexInt:&resultGreen];

                                 scanner = [NSScanner scannerWithString:strBlue];
                                 [scanner scanHexInt:&resultBlue];
                                 [_barColors addObject:[UIColor colorWithRed:resultRed/255.f green:resultGreen/255.f blue:resultBlue/255.f alpha:1.f]];
                                 NSString * strLabel = [dicOne valueForKey:global_key_label];
                                 [_barLabels addObject:strLabel];
                                 
                             }
                             

                             _barChartViews.delegate                = self;
                             _barChartViews.dataSource				= self;
                             _barChartViews.barShadowOffset			= CGSizeMake(2.0, 1.0);
                             _barChartViews.animationDuration		= 0.6;
                             _barChartViews.barShadowColor			= [UIColor grayColor];
                             _barChartViews.barShadowAlpha			= 0.5;
                             _barChartViews.barShadowRadius			= 1.0;
                             _barChartViews.barWidth					= 50.0;
                             _barChartViews.xLabelType				= SimpleBarChartXLabelTypeHorizontal;
                             _barChartViews.incrementValue			= 10;
                             _barChartViews.barTextType				= SimpleBarChartBarTextTypeRoof;
                             _barChartViews.barTextColor				= [UIColor whiteColor];
                             _barChartViews.gridColor				= [UIColor blackColor];
                             [chartScroll addSubview:_barChartViews];
                             [_barChartViews reloadData];
                         }
                     }
                     return;
                 }
             }
         }];
        return;
    }
}


- (void) buildScrollView:(NSDictionary*) dicInfo {
//    [mScroll.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    NSArray * aryWorkDetails = [dicInfo valueForKey:global_key_work_details];
    mAryTaskList = [[NSMutableArray alloc] init];
    for (int k = 0; k < aryWorkDetails.count; k ++) {
        NSDictionary * dicOne = [aryWorkDetails objectAtIndex:k];
        [mAryTaskList addObject:dicOne];
        
        if(k == 0){
            NSString * str = [NSString stringWithFormat:@"%@ | %@", [dicOne valueForKey:global_key_project_number], [dicOne valueForKey:global_key_project_name]];
            [txtProject setText:str];
            g_strLastWorkedProjectName = str;
            strFilter = str;
            
            mArayProjects = [g_dicProductMaster valueForKey:global_key_project_details];
            for (int i = 0; i < mArayProjects.count; i ++) {
                NSDictionary * dicOne = [mArayProjects objectAtIndex:i];
                NSString * str = [NSString stringWithFormat:@"%@ | %@", [dicOne valueForKey:global_key_project_number], [dicOne valueForKey:global_key_project_name]];
                if([str isEqualToString:strFilter])
                    selectedProjectIndex = i;
            }

            [self drawChart:dicOne];
        }
    }
    if (mAryTaskList && mAryTaskList.count)
    {
        CGFloat coorY = global_screen_size.width * 400 / 375;
        for (int i = 0; i < mAryTaskList.count; i++)
        {
            NSDictionary * dicOne = [mAryTaskList objectAtIndex:i];
            NSString * strNumber = [NSString stringWithFormat:@"%d", i + 1];
            NSString * strProjectName = [dicOne valueForKey:global_key_project_name];
            NSString * strDateTmp = [dicOne valueForKey:global_key_work_date];
            NSString * strValueWorkTime = [dicOne valueForKey:global_key_total_work_time];
            NSString * strKm = [dicOne valueForKey:global_key_km_drive];
            
            NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            NSDate * date = [formatter dateFromString:strDateTmp];
            [formatter setDateFormat:@"dd MMM yy"];
            NSString * strDate = [formatter stringFromDate:date];
            
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
            NSString * strWorkTime = [NSString stringWithFormat:@"%@h %@m", strHour, strMinute];
            
            UILabel * lblNumber = [[UILabel alloc] initWithFrame:CGRectMake(0, coorY, global_screen_size.width / 10, global_screen_size.height / 17)];
            [lblNumber setTextColor:global_nav_color];
            [lblNumber setText:strNumber];
            [lblNumber setTextAlignment:NSTextAlignmentCenter];
            
            UILabel * lblProject = [[UILabel alloc] initWithFrame:CGRectMake(lblNumber.frame.size.width, lblNumber.frame.origin.y, global_screen_size.width / 3 - lblNumber.frame.size.width, lblNumber.frame.size.height)];
            [lblProject setTextColor:global_nav_color];
            [lblProject setText:strProjectName];
            [lblProject setTextAlignment:NSTextAlignmentCenter];
            
            UILabel * lblDate = [[UILabel alloc] initWithFrame:CGRectMake(lblProject.frame.size.width + lblProject.frame.origin.x, lblNumber.frame.origin.y, global_screen_size.width / 3 - lblNumber.frame.size.width, lblNumber.frame.size.height)];
            [lblDate setTextColor:global_nav_color];
            [lblDate setText:strDate];
            [lblDate setTextAlignment:NSTextAlignmentCenter];
            
            UILabel * lblWorkHours = [[UILabel alloc] initWithFrame:CGRectMake(lblDate.frame.size.width + lblDate.frame.origin.x, lblNumber.frame.origin.y, global_screen_size.width / 3 - lblNumber.frame.size.width, lblNumber.frame.size.height)];
            [lblWorkHours setTextColor:global_nav_color];
            [lblWorkHours setText:strWorkTime];
            [lblWorkHours setTextAlignment:NSTextAlignmentCenter];
            
            UILabel * lblKm = [[UILabel alloc] initWithFrame:CGRectMake(lblWorkHours.frame.size.width + lblWorkHours.frame.origin.x, lblNumber.frame.origin.y, lblNumber.frame.size.width * 2, lblNumber.frame.size.height)];
            [lblKm setTextColor:global_nav_color];
            [lblKm setText:strKm];
            [lblKm setTextAlignment:NSTextAlignmentCenter];
            
            [mScroll addSubview:lblNumber];
            [mScroll addSubview:lblProject];
            [mScroll addSubview:lblDate];
            [mScroll addSubview:lblWorkHours];
            [mScroll addSubview:lblKm];
            
            UIButton * btnOne = [[UIButton alloc] initWithFrame:CGRectMake(0, coorY, global_screen_size.width, lblKm.frame.size.height)];
            [btnOne setBackgroundColor:[UIColor clearColor]];
            btnOne.tag = i;
            [btnOne addTarget:self action:@selector(onSelectItem:) forControlEvents:UIControlEventTouchUpInside];
            [mScroll addSubview:btnOne];
            
            UIView * viewSep = [[UIView alloc] initWithFrame:CGRectMake(22, coorY + lblKm.frame.size.height - 1, global_screen_size.width - 22, 1)];
            [viewSep setBackgroundColor:[UIColor lightGrayColor]];
            [mScroll addSubview:viewSep];
            
            coorY += lblKm.frame.size.height;
            
            if (global_screen_size.width < 330)
            {
                [lblNumber setFont:[UIFont systemFontOfSize:13.f]];
                [lblProject setFont:[UIFont systemFontOfSize:13.f]];
                [lblDate setFont:[UIFont systemFontOfSize:13.f]];
                [lblWorkHours setFont:[UIFont systemFontOfSize:13.f]];
                [lblKm setFont:[UIFont systemFontOfSize:13.f]];
            }
            else
            {
                [lblNumber setFont:[UIFont systemFontOfSize:15.f]];
                [lblProject setFont:[UIFont systemFontOfSize:15.f]];
                [lblDate setFont:[UIFont systemFontOfSize:15.f]];
                [lblWorkHours setFont:[UIFont systemFontOfSize:15.f]];
                [lblKm setFont:[UIFont systemFontOfSize:15.f]];
            }
        }
        [mScroll setContentSize:CGSizeMake(0, coorY)];
    }
}

#pragma mark SimpleBarChartDataSource

- (NSUInteger)numberOfBarsInBarChart:(SimpleBarChart *)barChart
{
    if (_barValues)
        return _barValues.count;
    return 0;
}

- (CGFloat)barChart:(SimpleBarChart *)barChart valueForBarAtIndex:(NSUInteger)index
{
    if (_barValues)
        return [[_barValues objectAtIndex:index] floatValue];
    return 0;
}

- (NSString *)barChart:(SimpleBarChart *)barChart textForBarAtIndex:(NSUInteger)index
{
    if (_barValues)
        return [NSString stringWithFormat:@"%@hr",[[_barValues objectAtIndex:index] stringValue]];
    return @"";
    
}

- (NSString *)barChart:(SimpleBarChart *)barChart xLabelForBarAtIndex:(NSUInteger)index
{
    if (_barLabels)
        return [_barLabels objectAtIndex:index];
    return @"";
}

- (UIColor *)barChart:(SimpleBarChart *)barChart colorForBarAtIndex:(NSUInteger)index
{
    if (_barColors)
        return [_barColors objectAtIndex:index];
    return [UIColor clearColor];
}
#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [tblProject setHidden:YES];
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    [textField setReturnKeyType:UIReturnKeyDone];
    if (textField == txtProject) {
        [tblProject setHidden:NO];
        strFilter = textField.text;
        [tblProject reloadData];
        btnClearTxtProject.hidden = NO;
    }
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == txtProject) {
        btnClearTxtProject.hidden = YES;
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    strFilter = [[textField text] stringByReplacingCharactersInRange:range withString:string];
    [tblProject reloadData];
    return YES;
}
- (void)dismissKeyboards {
    [txtProject resignFirstResponder];
    [tblProject setHidden:YES];
}
@end
