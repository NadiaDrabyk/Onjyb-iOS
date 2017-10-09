//
//  StatisticsVC.m
//  Onjyb
//
//  Created by Nadia Drabyk on 7/19/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import "StatisticsVC.h"
#import "CompletedTasksDetailVC.h"
#import "RegisterTimeDetailsVC.h"
@interface StatisticsVC ()

@end

@implementation StatisticsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:AMLocalizedString(@"Statistics", @"Statistics")];
    cellHeight = global_screen_size.height / 15;
    leftPadding = 20.f;
    if (global_screen_size.width < 330)
    {
        leftPadding = 14.f;
    }
    [self initViews];
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboards)];
    tapGesture.delegate = self;
    [viewMid addGestureRecognizer:tapGesture];
    [viewTop addGestureRecognizer:tapGesture];
    [viewTitle addGestureRecognizer:tapGesture];
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
    [self dismissKeyboards];
}

- (void)onDateFrom {
    [self dismissKeyboards];
    [txtDateFrom becomeFirstResponder];
}
- (void) onProject:(UIButton *) btn
{
    NSString * strIndex = [mAryFilteredIndex objectAtIndex:btn.tag];
    selectedProjectIndex = strIndex.intValue;
    strFilter = [mAryFilteredContent objectAtIndex:btn.tag];
    [txtProject setText:strFilter];
    [self dismissKeyboards];
    [self updateTableView];
}
- (void)onDateTo {
    [self dismissKeyboards];
    [txtDateTo becomeFirstResponder];
}
- (void) onDatePickerDone {
    if ([txtDateFrom isFirstResponder])
    {
        NSDate * date = mPickerFrom.date;
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd MMM yy"];
        strDateSaveStart = [formatter stringFromDate:date];
        [lblDateFrom setText:[NSString stringWithFormat:@"%@", strDateSaveStart]];
    }
    if ([txtDateTo isFirstResponder])
    {
        NSDate * date = mPickerTo.date;
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd MMM yy"];
        strDateSaveEnd = [formatter stringFromDate:date];
        [lblDateTo setText:[NSString stringWithFormat:@"%@", strDateSaveEnd]];
    }
    [self dismissKeyboards];
    [self updateTableView];
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
    if (!mAryTaskList) mAryTaskList = [[NSMutableArray alloc] init];
    
    return mAryTaskList.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"statisticsCell"];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"statisticsCell"];
    }
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [cell.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    cell.backgroundColor = [UIColor clearColor];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    UIView * viewSep = [[UIView alloc] initWithFrame:CGRectMake(leftPadding, cellHeight - 1, global_screen_size.width - leftPadding, 1)];
    [viewSep setBackgroundColor:global_darkgray_color];
    [cell addSubview:viewSep];
    NSDictionary * dicCell = [mAryTaskList objectAtIndex:indexPath.row];
    UILabel * lblNumber = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, global_screen_size.width / 10, cellHeight)];
    [lblNumber setTextColor:global_nav_color];
    [lblNumber setText:[NSString stringWithFormat:@"%ld", indexPath.row + 1]];
    [lblNumber setTextAlignment:NSTextAlignmentCenter];
    [cell addSubview:lblNumber];
    
    UILabel * lblProject = [[UILabel alloc] initWithFrame:CGRectMake(global_screen_size.width / 10, 0, global_screen_size.width * 7 / 30, lblNumber.frame.size.height)];
    [lblProject setText:[dicCell valueForKey:global_key_project_name]];
    [lblProject setTextColor:global_nav_color];
    [lblProject setTextAlignment:NSTextAlignmentCenter];
    [cell addSubview:lblProject];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate * date = [formatter dateFromString:[dicCell valueForKey:global_key_work_date]];
    [formatter setDateFormat:@"dd MMM yy"];
    NSString * strDate = [formatter stringFromDate:date];
    UILabel * lblDateTitle = [[UILabel alloc] initWithFrame:CGRectMake(global_screen_size.width / 3, 0, lblProject.frame.size.width, lblProject.frame.size.height)];
    [lblDateTitle setText:strDate];
    [lblDateTitle setTextColor:global_nav_color];
    [lblDateTitle setTextAlignment:NSTextAlignmentCenter];
    [cell addSubview:lblDateTitle];
    
    NSString * strValueWorkTime = [dicCell valueForKey:global_key_total_work_time];
    NSString * strKm = [dicCell valueForKey:global_key_km_drive];
    
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
    
    
    UILabel * lblHours = [[UILabel alloc] initWithFrame:CGRectMake(lblDateTitle.frame.origin.x + lblDateTitle.frame.size.width, 0, lblProject.frame.size.width, lblProject.frame.size.height)];
    [lblHours setText:strWorkTime];
    [lblHours setTextColor:global_nav_color];
    [lblHours setTextAlignment:NSTextAlignmentCenter];
    [cell addSubview:lblHours];
    
    UILabel * lblKm = [[UILabel alloc] initWithFrame:CGRectMake(lblHours.frame.origin.x + lblHours.frame.size.width, 0, lblNumber.frame.size.width * 2, lblProject.frame.size.height)];
    [lblKm setText:strKm];
    [lblKm setTextColor:global_nav_color];
    [lblKm setTextAlignment:NSTextAlignmentCenter];
    [cell addSubview:lblKm];

    if (global_screen_size.width < 330)
    {
        [lblNumber setFont:[UIFont systemFontOfSize:12.f]];
        [lblProject setFont:[UIFont systemFontOfSize:12.f]];
        [lblHours setFont:[UIFont systemFontOfSize:12.f]];
        [lblDateTitle setFont:[UIFont systemFontOfSize:12.f]];
        [lblKm setFont:[UIFont systemFontOfSize:12.f]];
    }
    else
    {
        [lblNumber setFont:[UIFont systemFontOfSize:14.f]];
        [lblProject setFont:[UIFont systemFontOfSize:14.f]];
        [lblHours setFont:[UIFont systemFontOfSize:14.f]];
        [lblDateTitle setFont:[UIFont systemFontOfSize:14.f]];
        [lblKm setFont:[UIFont systemFontOfSize:14.f]];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSDictionary *dicOne = [mAryTaskList objectAtIndex:indexPath.row];
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
#pragma mark - Utils

- (void) initViews {
    viewTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, global_screen_size.width, global_screen_size.width / 4)];
    [viewTop setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:viewTop];
    
    
    UILabel * lblProjectTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, global_screen_size.width / 4, viewTop.frame.size.height / 2)];
    [lblProjectTitle setTextColor:global_nav_color];
    [lblProjectTitle setText:AMLocalizedString(@"Project", @"Project")];
    [viewTop addSubview:lblProjectTitle];
    
    txtProject = [[UITextField alloc] initWithFrame:CGRectMake(global_screen_size.width / 4, viewTop.frame.size.height / 12, global_screen_size.width * 3 / 4 - leftPadding, viewTop.frame.size.height / 3)];
    btnProjectHeight = txtProject.frame.size.height;
    txtProject.delegate = self;
    txtProject.layer.cornerRadius = 4.f;
    txtProject.layer.borderColor = [UIColor grayColor].CGColor;
    txtProject.layer.borderWidth = 1.f;
    [txtProject setTextColor:[UIColor grayColor]];
    txtProject.placeholder = AMLocalizedString(@"Select project", @"Select project");
    [viewTop addSubview:txtProject];
    
    UILabel * lblDate = [[UILabel alloc] initWithFrame:CGRectMake(10, viewTop.frame.size.height / 2, viewTop.frame.size.width / 4, viewTop.frame.size.height / 2)];
    [lblDate setTextColor:global_nav_color];
    [lblDate setText:AMLocalizedString(@"Date", @"Date")];
    [viewTop addSubview:lblDate];
    
    UIView * viewFrom = [[UIView alloc] initWithFrame:CGRectMake(lblDate.frame.size.width, viewTop.frame.size.height / 2 + viewTop.frame.size.height / 12, (global_screen_size.width * 3 / 4 - leftPadding * 2) / 2, viewTop.frame.size.height / 3)];
    viewFrom.layer.cornerRadius = 4.f;
    viewFrom.layer.borderWidth = 1.f;
    viewFrom.layer.borderColor = [UIColor grayColor].CGColor;
    [viewTop addSubview:viewFrom];
    
    UIButton * btnFrom = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, viewFrom.frame.size.width, viewFrom.frame.size.height)];
    [btnFrom setBackgroundColor:[UIColor clearColor]];
    [btnFrom addTarget:self action:@selector(onDateFrom) forControlEvents:UIControlEventTouchUpInside];
    [viewFrom addSubview:btnFrom];
    
    lblDateFrom = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, viewFrom.frame.size.width - 10, viewFrom.frame.size.height)];
    [lblDateFrom setTextColor:[UIColor grayColor]];
    [viewFrom addSubview:lblDateFrom];
    
    UIView * viewTo = [[UIView alloc] initWithFrame:CGRectMake(viewFrom.frame.origin.x + viewFrom.frame.size.width + leftPadding, viewFrom.frame.origin.y, viewFrom.frame.size.width, viewFrom.frame.size.height)];
    viewTo.layer.cornerRadius = 4.f;
    viewTo.layer.borderColor = [UIColor grayColor].CGColor;
    viewTo.layer.borderWidth = 1.f;
    [viewTop addSubview:viewTo];
    
    UIButton * btnTo = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, viewTo.frame.size.width, viewTo.frame.size.height)];
    [btnTo setBackgroundColor:[UIColor clearColor]];
    [btnTo addTarget:self action:@selector(onDateTo) forControlEvents:UIControlEventTouchUpInside];
    [viewTo addSubview:btnTo];
    
    lblDateTo = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, viewTo.frame.size.width - 10, viewTo.frame.size.height)];
    [lblDateTo setTextColor:[UIColor grayColor]];
    [viewTo addSubview:lblDateTo];
    
    NSDate * date = [NSDate date];
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];

    [formatter setDateFormat:@"dd MMM yy"];
    strDateSaveEnd = [formatter stringFromDate:date];
    [lblDateTo setText:strDateSaveEnd];
    
    NSDate * dateFrom = [date dateByAddingTimeInterval:-30 * 24 * 3600];
    
    strDateSaveStart = [formatter stringFromDate:dateFrom];
    [lblDateFrom setText:strDateSaveStart];
    
    mPickerFrom = [[UIDatePicker alloc] init];
    [mPickerFrom setTintColor:[UIColor clearColor]];
    mPickerFrom.datePickerMode = UIDatePickerModeDate;
    txtDateFrom = [[UITextField alloc] initWithFrame:CGRectMake(lblDateFrom.frame.origin.x, lblDateFrom.frame.origin.y, 0, 0)];
    [txtDateFrom setInputView:mPickerFrom];
    txtDateFrom.delegate = self;
    [viewFrom addSubview:txtDateFrom];
    
    UIToolbar *toolBar=[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, global_screen_size.width, 44)];
    [toolBar setTintColor:[UIColor whiteColor]];
    [toolBar setBarTintColor:global_nav_color];
    toolBar.barStyle = UIBarStyleDefault;
    toolBar.translucent = YES;
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:AMLocalizedString(@"Done", @"Done") style:UIBarButtonItemStyleDone target:self action:@selector(onDatePickerDone)];
    [doneBtn setTintColor:[UIColor lightGrayColor]];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [space setTintColor:[UIColor clearColor]];
    [toolBar setItems:[NSArray arrayWithObjects:space, doneBtn, nil]];
    [txtDateFrom setInputAccessoryView:toolBar];
    
    mPickerTo = [[UIDatePicker alloc] init];
    [mPickerTo setTintColor:[UIColor clearColor]];
    mPickerTo.datePickerMode = UIDatePickerModeDate;
    txtDateTo = [[UITextField alloc] initWithFrame:CGRectMake(lblDateTo.frame.origin.x, lblDateTo.frame.origin.y, 0, 0)];
    [txtDateTo setInputView:mPickerTo];
    txtDateTo.delegate = self;
    [viewTo addSubview:txtDateTo];
    [txtDateTo setInputAccessoryView:toolBar];
    
    viewMid = [[UIView alloc] initWithFrame:CGRectMake(0, viewTop.frame.size.height, global_screen_size.width, viewTop.frame.size.height * 1.2)];
    [viewMid setBackgroundColor:global_nav_color];
    [self.view addSubview:viewMid];
    
    UIImageView * imgTotalHours = [[UIImageView alloc] initWithFrame:CGRectMake(global_screen_size.width / 6 - viewMid.frame.size.height / 2 / 3, viewMid.frame.size.height / 2 / 6, viewMid.frame.size.height / 2 * 2 / 3, viewMid.frame.size.height / 2 * 2 / 3)];
    [imgTotalHours setImage:[UIImage imageNamed:@"AboutApp"]];
    [viewMid addSubview:imgTotalHours];
    
    UILabel * lblTotal = [[UILabel alloc] initWithFrame:CGRectMake(0, viewMid.frame.size.height / 2, viewMid.frame.size.width / 3, viewMid.frame.size.height / 4)];
    [lblTotal setTextColor:[UIColor whiteColor]];
    [lblTotal setText:AMLocalizedString(@"Total hours", @"Total hours")];
    [viewMid addSubview:lblTotal];
    
    lblTotalHours = [[UILabel alloc] initWithFrame:CGRectMake(lblTotal.frame.origin.x, lblTotal.frame.origin.y + lblTotal.frame.size.height, lblTotal.frame.size.width, lblTotal.frame.size.height)];
    [lblTotalHours setTextColor:[UIColor whiteColor]];
    [viewMid addSubview:lblTotalHours];

    UIImageView * imgOvertime = [[UIImageView alloc] initWithFrame:CGRectMake(imgTotalHours.frame.origin.x + viewMid.frame.size.width / 3, imgTotalHours.frame.origin.y, imgTotalHours.frame.size.width, imgTotalHours.frame.size.height)];
    [imgOvertime setImage:[UIImage imageNamed:@"AboutApp"]];
    [viewMid addSubview:imgOvertime];
    
    UILabel * lblOver = [[UILabel alloc] initWithFrame:CGRectMake(lblTotal.frame.origin.x + viewMid.frame.size.width / 3, lblTotal.frame.origin.y, lblTotal.frame.size.width, lblTotal.frame.size.height)];
    [lblOver setTextColor:[UIColor whiteColor]];
    [lblOver setText:AMLocalizedString(@"Overtime", @"Overtime")];
    [viewMid addSubview:lblOver];
    
    lblOvertime = [[UILabel alloc] initWithFrame:CGRectMake(lblOver.frame.origin.x, lblOver.frame.origin.y + lblOver.frame.size.height, lblOver.frame.size.width, lblOver.frame.size.height)];
    [lblOvertime setTextColor:[UIColor whiteColor]];
    [viewMid addSubview:lblOvertime];
    
    UIButton* btnOvertime = [[UIButton alloc] initWithFrame:CGRectMake(lblOver.frame.origin.x, 0, lblOver.frame.size.width, viewMid.frame.size.height)];
    [btnOvertime addTarget:self action:@selector(onOvertime:) forControlEvents:UIControlEventTouchUpInside];
    [viewMid addSubview:btnOvertime];
    
    UIImageView * imgKilometers = [[UIImageView alloc] initWithFrame:CGRectMake(imgOvertime.frame.origin.x + viewMid.frame.size.width / 3, imgOvertime.frame.origin.y, imgOvertime.frame.size.width, imgTotalHours.frame.size.height)];
    [imgKilometers setImage:[UIImage imageNamed:@"AboutApp"]];
    [viewMid addSubview:imgKilometers];
    
    UILabel * lblkilo = [[UILabel alloc] initWithFrame:CGRectMake(lblOver.frame.origin.x + viewMid.frame.size.width / 3, lblOver.frame.origin.y, lblOver.frame.size.width, lblOver.frame.size.height)];
    [lblkilo setTextColor:[UIColor whiteColor]];
    [lblkilo setText:AMLocalizedString(@"Kilometer", @"Kilometer")];
    [viewMid addSubview:lblkilo];
    
    lblKilometers = [[UILabel alloc] initWithFrame:CGRectMake(lblkilo.frame.origin.x, lblkilo.frame.origin.y + lblkilo.frame.size.height, lblkilo.frame.size.width, lblkilo.frame.size.height)];
    [lblKilometers setTextColor:[UIColor whiteColor]];
    [viewMid addSubview:lblKilometers];
    
    [lblTotal setTextAlignment:NSTextAlignmentCenter];
    [lblTotalHours setTextAlignment:NSTextAlignmentCenter];
    [lblOver setTextAlignment:NSTextAlignmentCenter];
    [lblOvertime setTextAlignment:NSTextAlignmentCenter];
    [lblkilo setTextAlignment:NSTextAlignmentCenter];
    [lblKilometers setTextAlignment:NSTextAlignmentCenter];
    
    viewTitle = [[UIView alloc] initWithFrame:CGRectMake(0, viewMid.frame.origin.y + viewMid.frame.size.height, global_screen_size.width, txtProject.frame.size.height)];
//    cellHeight = txtProject.frame.size.height;
    [viewTitle setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:viewTitle];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, txtProject.frame.size.height)];
    txtProject.leftView = paddingView;
    txtProject.leftViewMode = UITextFieldViewModeAlways;
    
    UILabel * lblNumber = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, global_screen_size.width / 10, viewTitle.frame.size.height)];
    [lblNumber setTextColor:[UIColor whiteColor]];
    [lblNumber setText:@"#"];
    [lblNumber setTextAlignment:NSTextAlignmentCenter];
    [viewTitle addSubview:lblNumber];
    [txtProject setTextColor:[UIColor grayColor]];
    
    
    UILabel * lblProject = [[UILabel alloc] initWithFrame:CGRectMake(global_screen_size.width / 10, 0, global_screen_size.width * 7 / 30, lblNumber.frame.size.height)];
    [lblProject setText:AMLocalizedString(@"Project", @"Project")];
    [lblProject setTextColor:[UIColor whiteColor]];
    [lblProject setTextAlignment:NSTextAlignmentCenter];
    [viewTitle addSubview:lblProject];
    
    UILabel * lblDateTitle = [[UILabel alloc] initWithFrame:CGRectMake(global_screen_size.width / 3, 0, lblProject.frame.size.width, lblProject.frame.size.height)];
    [lblDateTitle setText:AMLocalizedString(@"Date", @"Date")];
    [lblDateTitle setTextColor:[UIColor whiteColor]];
    [lblDateTitle setTextAlignment:NSTextAlignmentCenter];
    [viewTitle addSubview:lblDateTitle];
    
    UILabel * lblHours = [[UILabel alloc] initWithFrame:CGRectMake(lblDateTitle.frame.origin.x + lblDateTitle.frame.size.width, 0, lblProject.frame.size.width, lblProject.frame.size.height)];
    [lblHours setText:AMLocalizedString(@"Hours", @"Hours")];
    [lblHours setTextColor:[UIColor whiteColor]];
    [lblHours setTextAlignment:NSTextAlignmentCenter];
    [viewTitle addSubview:lblHours];
    
    UILabel * lblKm = [[UILabel alloc] initWithFrame:CGRectMake(lblHours.frame.origin.x + lblHours.frame.size.width, 0, lblNumber.frame.size.width * 2, lblProject.frame.size.height)];
    [lblKm setText:AMLocalizedString(@"Km.", @"Km.")];
    [lblKm setTextColor:[UIColor whiteColor]];
    [lblKm setTextAlignment:NSTextAlignmentCenter];
    [viewTitle addSubview:lblKm];
    
    tblView = [[UITableView alloc] initWithFrame:CGRectMake(0, viewTitle.frame.origin.y + viewTitle.frame.size.height, global_screen_size.width, global_screen_size.height - viewTitle.frame.origin.y - viewTitle.frame.size.height)];
    tblView.delegate = self;
    tblView.dataSource = self;
    [self.view addSubview:tblView];
    
    if (global_screen_size.width < 330)
    {
        [lblProjectTitle setFont:[UIFont boldSystemFontOfSize:14.f]];
        [txtProject  setFont:[UIFont boldSystemFontOfSize:14.f]];
        [lblDate setFont:[UIFont boldSystemFontOfSize:14.f]];
        [lblDateTo setFont:[UIFont boldSystemFontOfSize:14.f]];
        [lblDateFrom setFont:[UIFont boldSystemFontOfSize:14.f]];
        [lblTotalHours setFont:[UIFont boldSystemFontOfSize:12.f]];
        [lblOvertime setFont:[UIFont boldSystemFontOfSize:12.f]];
        [lblKilometers setFont:[UIFont boldSystemFontOfSize:12.f]];
        [lblTotal setFont:[UIFont boldSystemFontOfSize:12.f]];
        [lblOver setFont:[UIFont boldSystemFontOfSize:12.f]];
        [lblkilo setFont:[UIFont boldSystemFontOfSize:12.f]];
    }
    else
    {
        [lblProjectTitle setFont:[UIFont boldSystemFontOfSize:16.f]];
        [txtProject  setFont:[UIFont boldSystemFontOfSize:16.f]];
        [lblDate setFont:[UIFont boldSystemFontOfSize:16.f]];
        [lblDateTo setFont:[UIFont boldSystemFontOfSize:16.f]];
        [lblDateFrom setFont:[UIFont boldSystemFontOfSize:16.f]];
        [lblTotalHours setFont:[UIFont boldSystemFontOfSize:14.f]];
        [lblOvertime setFont:[UIFont boldSystemFontOfSize:14.f]];
        [lblKilometers setFont:[UIFont boldSystemFontOfSize:14.f]];
        [lblTotal setFont:[UIFont boldSystemFontOfSize:14.f]];
        [lblOver setFont:[UIFont boldSystemFontOfSize:14.f]];
        [lblOver setFont:[UIFont boldSystemFontOfSize:14.f]];
        [lblkilo setFont:[UIFont boldSystemFontOfSize:16.f]];
    }
    
    dimView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, global_screen_size.width, global_screen_size.height)];
    [dimView setBackgroundColor:[UIColor blackColor]];
    [dimView setAlpha:0.6];
    viewProject = [[UIView alloc] initWithFrame:CGRectMake(txtProject.frame.origin.x, txtProject.frame.size.height + txtProject.frame.origin.y + 0.5, txtProject.frame.size.width, 0)];
    [viewProject setBackgroundColor:[UIColor colorWithRed:240/255.f green:240/255.f blue:240/255.f alpha:1.f]];
    viewProject.layer.cornerRadius = 3.f;
    viewProject.layer.borderColor = [UIColor lightGrayColor].CGColor;
    viewProject.layer.borderWidth = 1.f;
    viewProject.layer.masksToBounds = YES;
    [viewProject setHidden:YES];
    [self.view addSubview:viewProject];
    if (g_dicProductMaster)
    {
        NSArray * ary = [g_dicProductMaster valueForKey:global_key_project_details];
        NSDictionary * dicOne = [ary objectAtIndex:0];
        NSString * str = [NSString stringWithFormat:@"%@ | %@", [dicOne valueForKey:global_key_project_number], [dicOne valueForKey:global_key_project_name]];
        str = @"All";
        [txtProject setText:str];
        strFilter = str;
        mAryFilteredContent = [[NSMutableArray alloc] init];
        [mAryFilteredContent addObject:str];
        mAryFilteredIndex = [[NSMutableArray alloc] init];
        [mAryFilteredIndex addObject:@"0"];
        mArayProjects = [[NSMutableArray alloc] init];
        NSArray * arys = [g_dicProductMaster valueForKey:global_key_project_details];
        mArayProjects = [arys mutableCopy];
        [self updateProjectsArray];
    }
    else
    {
        [self getMasterUpdated];
    }
    [self.view addSubview:dimView];
    [lblTotalHours setText:[NSString stringWithFormat:@"00%@ 00m", AMLocalizedString(@"h", @"h")]];
    [lblOvertime setText:[NSString stringWithFormat:@"00%@ 00m", AMLocalizedString(@"h", @"h")]];
    [lblKilometers setText:@"00 Km"];
    [self updateTableView];
}
- (IBAction)onOvertime:(id)sender{
    if(!aryOvertimeData || aryOvertimeData.count == 0)
        return;
    
    CGSize szScreen = self.view.frame.size;
    cellHeight = szScreen.height / 15;
    CGFloat w = szScreen.width * 0.6;
    CGFloat h = cellHeight * (2 + aryOvertimeData.count);
    popupDimView = [[UIView alloc] initWithFrame:self.view.bounds];
    popupDimView.backgroundColor = [UIColor blackColor];
    popupDimView.alpha = 0.6;
    [self.view addSubview:popupDimView];
    
    popup = [[UIView alloc] initWithFrame:CGRectMake(szScreen.width * 0.2, CGRectGetMaxY(viewMid.frame) * 0.8, w, h)];
    popup.layer.cornerRadius = 10;
    popup.layer.masksToBounds = YES;
    popup.layer.borderColor = [UIColor grayColor].CGColor;
    popup.layer.borderWidth = 1;
    popup.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:popup];
    
    UILabel* lbPopupTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, w, cellHeight)];
    lbPopupTitle.text = AMLocalizedString(@"Overtime", nil);
    lbPopupTitle.textColor = [UIColor whiteColor];
    lbPopupTitle.textAlignment = NSTextAlignmentCenter;
    [lbPopupTitle setBackgroundColor:global_nav_color];
    [popup addSubview:lbPopupTitle];
    
    UIButton *btnClose = [[UIButton alloc] initWithFrame:CGRectMake(w - 28, 4, 24, 24)];
    UIImage * imgClose = [[UIImage imageNamed:@"not-approved"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    btnClose.tintColor = [UIColor whiteColor];
    [btnClose setImage:imgClose forState:UIControlStateNormal];
    [btnClose addTarget:self action:@selector(onClosePopup) forControlEvents:UIControlEventTouchUpInside];
    [popup addSubview:btnClose];
    
    
    CGFloat y = cellHeight;
    for(int i = 0; i < aryOvertimeData.count; i++){
        NSDictionary * dic = [aryOvertimeData objectAtIndex:i];
        UILabel* lbPercent = [[UILabel alloc] initWithFrame:CGRectMake(leftPadding, y, w - 2 * leftPadding, cellHeight)];
        lbPercent.textColor = global_nav_color;
        [popup addSubview:lbPercent];
        NSString* strPercent = [dic objectForKey:@"rule_per"];
        NSString* percent = @"%";
        lbPercent.text = [NSString stringWithFormat:@"%@%@", strPercent, percent];
        
        UILabel* lbValue = [[UILabel alloc] initWithFrame:CGRectMake(leftPadding, y, w - 2 * leftPadding, cellHeight)];
        lbValue.textColor = global_green_color;
        lbValue.textAlignment = NSTextAlignmentRight;
        [popup addSubview:lbValue];
        NSString* strValue = [dic objectForKey:@"total_overtime_per_rule"];
        int nMin = [strValue intValue];
        lbValue.text = [NSString stringWithFormat:@"%02d%@ | %02dm", nMin/60, AMLocalizedString(@"h", nil), nMin%60];

        y += cellHeight;
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(leftPadding, y, w - 2 * leftPadding, 1)];
        line.backgroundColor = [UIColor lightGrayColor];
        [popup addSubview:line];
    }
}
- (void)onClosePopup{
    [popup removeFromSuperview];
    [popupDimView removeFromSuperview];
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
    if (!strFilter) strFilter = @"";
    NSString * pref = strFilter;
    NSMutableArray * aryMut = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < mArayProjects.count; i ++) {
        NSDictionary * dicOne = [mArayProjects objectAtIndex:i];
        NSString * str = [NSString stringWithFormat:@"%@ | %@", [dicOne valueForKey:global_key_project_number], [dicOne valueForKey:global_key_project_name]];
        [aryMut addObject:str];
        [mAryOrg addObject:str];
    }
    [aryMut insertObject:@"All" atIndex:0];
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

    if (filteredArray && filteredArray.count)
    {
        mAryFilteredContent = [filteredArray mutableCopy];
    }
    [self updateProjectView];
}
- (void) updateProjectView
{
    [viewProject setFrame:CGRectMake(viewProject.frame.origin.x, viewProject.frame.origin.y, viewProject.frame.size.width, btnProjectHeight * mAryFilteredIndex.count)];
    [viewProject.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    for (int i = 0; i < mAryFilteredIndex.count; i ++)
    {
        UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(leftPadding, i * btnProjectHeight - 1, viewProject.frame.size.width - leftPadding, viewProject.frame.size.height / mAryFilteredIndex.count - 1)];
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
        btn.tag = i;
        [btn addTarget:self action:@selector(onProject:) forControlEvents:UIControlEventTouchUpInside];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [viewProject addSubview:btn];
        UIView * viewSep = [[UIView alloc] initWithFrame:CGRectMake(leftPadding, btn.frame.origin.y + btn.frame.size.height, btn.frame.size.width, 1)];
        [viewSep setBackgroundColor:global_darkgray_color];
        [viewProject addSubview:viewSep];
    }
}
- (void) updateTableView {
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMM yy"];
    NSDate * dateFrom = [formatter dateFromString:strDateSaveStart];
    NSDate * dateTo = [formatter dateFromString:strDateSaveEnd];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    NSString * strStart = [formatter stringFromDate:dateFrom];
    NSString * strEnd = [formatter stringFromDate:dateTo];
    NSString * strProjectID = @"";
    if (selectedProjectIndex != 0)
    {
        NSString * strIndex = [mAryFilteredIndex objectAtIndex:selectedProjectIndex];
        NSDictionary * dic = [mArayProjects objectAtIndex:strIndex.integerValue - 1];
        strProjectID = [dic valueForKey:global_key_project_id];
    }
    mAryTaskList = [[NSMutableArray alloc] init];
    AppDelegate * app = (AppDelegate*) [UIApplication sharedApplication].delegate;
    [app showHUD];
    
    //TaskList API
    
    User * user = [GlobalUtils loadUserObjectWithKey:global_user_info_save];
    
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setObject:@"yes" forKey:global_key_is_mng_jobber];
    [param setObject:user.strUserID forKey:global_key_user_id];
    [param setObject:user.strCompanyID forKey:global_key_company_id];
    [param setObject:@"yes" forKey:global_key_is_summary];
    [param setObject:user.strRefRoleID forKey:global_key_role_id];
    [param setObject:@"" forKey:global_key_approve_status];
    [param setObject:@"1" forKey:global_key_page_number];
    [param setObject:strStart forKey:global_key_start_date];
    [param setObject:strEnd forKey:global_key_end_date];
    [param setObject:strProjectID forKey:global_key_project_id];
    
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
                         aryOvertimeData = [dicResObject objectForKey:@"overtimeData"];
                         NSArray * ary = [dicResObject objectForKey:global_key_work_details];
                         mAryTaskList = [[NSMutableArray alloc] init];
                         if (ary && ary.count) {
                             mAryTaskList = [ary mutableCopy];
                             int sumKm = 0, sumOvertime = 0, sumHours = 0;
                             for (int i = 0; i < mAryTaskList.count; i ++)
                             {
                                 NSDictionary * dicElement = [mAryTaskList objectAtIndex:i];
                                 NSString * strKm = [dicElement valueForKey:global_key_km_drive];
                                 NSString * strHours = [dicElement valueForKey:global_key_total_work_time];
                                 NSString * strOvertime = [dicElement valueForKey:global_key_total_work_overtime];
                                 
                                 sumKm += strKm.intValue;
                                 sumOvertime += strOvertime.intValue;
                                 sumHours += strHours.intValue;
                                 
                             }
                             [lblKilometers setText:[NSString stringWithFormat:@"%d Km", sumKm]];
                             NSString * strValue = [NSString stringWithFormat:@"%d", sumHours];
                             int hour = strValue.intValue / 60;
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
                             int minute = strValue.intValue - hour * 60;
                             if (minute < 10)
                             {
                                 strMinute = [NSString stringWithFormat:@"0%d", minute];
                             }
                             else
                             {
                                 strMinute = [NSString stringWithFormat:@"%d", minute];
                             }
                             NSString * strHours = [NSString stringWithFormat:@"%@h %@m", strHour, strMinute];
                             [lblTotalHours setText:[NSString stringWithFormat:@"%@", strHours]];
                             
                             strValue = [NSString stringWithFormat:@"%d", sumOvertime];
                             hour = strValue.intValue / 60;
                             if (hour < 10)
                             {
                                 strHour = [NSString stringWithFormat:@"0%d", hour];
                             }
                             else
                             {
                                 strHour = [NSString stringWithFormat:@"%d", hour];
                             }
                             minute = strValue.intValue - hour * 60;
                             if (minute < 10)
                             {
                                 strMinute = [NSString stringWithFormat:@"0%d", minute];
                             }
                             else
                             {
                                 strMinute = [NSString stringWithFormat:@"%d", minute];
                             }
                             strHours = [NSString stringWithFormat:@"%@h %@m", strHour, strMinute];
                             [lblOvertime setText:[NSString stringWithFormat:@"%@", strHours]];
                         }
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

#pragma mark - Text Delegate
- (void) dismissKeyboards {
    [viewProject setHidden:YES];
    [txtProject resignFirstResponder];
    [txtDateTo resignFirstResponder];
    [txtDateFrom resignFirstResponder];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (textField == txtProject)
    {
        [viewProject setHidden:YES];
    }
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == txtProject) {
        strFilter = [[textField text] stringByReplacingCharactersInRange:range withString:string];
        [self updateProjectsArray];
    }
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    [textField setReturnKeyType:UIReturnKeyDone];
    if (textField == txtProject)
    {
        [viewProject setHidden:NO];
        [self updateProjectsArray];
    }
    
    return YES;
}

@end
