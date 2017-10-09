//
//  RegisterTimeVC.m
//  Onjyb
//
//  Created by Nadia Drabyk on 7/18/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import "RegisterTimeVC.h"
#import "ExtraWorkCreateVC.h"
#import "ImagePreviewVC.h"
#import "AFNetworking.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#import "MineHoursVC.h"

@interface RegisterTimeVC ()

@end

@implementation RegisterTimeVC

@synthesize dicInfo;

#define cell_Project                        0
#define cell_Branch                         1
#define cell_SelectWorkingHours             2
#define cell_SelectBreakTime                3
#define cell_PTOBank                        4
#define cell_SelectOverTime                 5
#define cell_Kilometers                     6
#define cell_ExtraWork                      7
#define cell_Attachment                     8
#define cell_Comments                       9
#define cell_SigningHours                   10
#define cell_TotalOverTime                  11
#define cell_Num                            12

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:AMLocalizedString(@"Register Time", @"Register Time")];
    g_dicExtraInfo = nil;
    leftPadding = 16.f;
    topPadding = 10.f;
    cellHeight = global_screen_size.height / 13;
    if (global_screen_size.width < 330)
    {
        leftPadding = 12.f;
        topPadding = 8.f;
        [lblTopDate setFont:[UIFont boldSystemFontOfSize:14.f]];
    }
    else
    {
        [lblTopDate setFont:[UIFont boldSystemFontOfSize:16.f]];
    }
    btnProjectHeight = cellHeight - topPadding;
    NSString * strDateTmp = [dicInfo valueForKey:global_key_work_date];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate * date = [formatter dateFromString:strDateTmp];
    [formatter setDateFormat:@"dd MMM yy"];
    NSString * strDate = [formatter stringFromDate:date];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    strDateSave = [formatter stringFromDate:date];
    [lblTopDate setText:[NSString stringWithFormat:@"%@         %@", AMLocalizedString(@"Date", nil), strDate]];
    [viewTop setBackgroundColor:global_blue_color];
    [lblTopDate setFrame:CGRectMake(leftPadding, 0, 300, global_screen_size.width * 2 / 15)];
    [btnTopDate setFrame:CGRectMake(global_screen_size.width - leftPadding - global_screen_size.width / 15, global_screen_size.width / 30, global_screen_size.width / 15, global_screen_size.width / 15)];
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboards)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
    
    [self initViews];
    dimView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, global_screen_size.width, global_screen_size.height)];
    [dimView setBackgroundColor:[UIColor blackColor]];
    [dimView setAlpha:0.6];
    
    viewProject = [[UIScrollView alloc] initWithFrame:CGRectMake(leftPadding, global_screen_size.width * 2 / 15 + cellHeight + 0.5, global_screen_size.width - 2 * leftPadding, btnProjectHeight * 5)];
    [viewProject setBackgroundColor:[UIColor colorWithRed:240/255.f green:240/255.f blue:240/255.f alpha:1.f]];
    viewProject.layer.cornerRadius = 3.f;
    viewProject.layer.borderColor = [UIColor lightGrayColor].CGColor;
    viewProject.layer.borderWidth = 1.f;
    viewProject.layer.masksToBounds = YES;
    [viewProject setHidden:YES];
    [self.view addSubview:viewProject];
    [self.view bringSubviewToFront:viewTop];
    
    [self.view addSubview:dimView];
    
    viewSignature.layer.cornerRadius = 10;
    viewSignature.layer.masksToBounds = YES;
    
    drawSignatureView.layer.cornerRadius = 5.f;
    drawSignatureView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    drawSignatureView.layer.borderWidth = 0.5f;
    drawSignatureView.layer.masksToBounds = YES;

    [drawSignatureView setPreviousPoint:CGPointZero];
    [drawSignatureView setPrePreviousPoint:CGPointZero];
    [drawSignatureView setLineWidth:1.0];
    [drawSignatureView setCurrentColor:[UIColor blackColor]];

    NSString *strIP = [self getIPAddress];
    lblIP.text = [NSString stringWithFormat:@"%@ %@", AMLocalizedString(@"IP Address:", nil), strIP];
    
    
    [lblName setText:AMLocalizedString(@"Name:", nil)];
    [lblEmail setText:AMLocalizedString(@"Email:", nil)];
    [lblContactName setText:AMLocalizedString(@"Contact person:", nil)];
    [lblContactEmail setText:AMLocalizedString(@"Contact email:", nil)];
    [lblSignature setText:AMLocalizedString(@"Signature:", nil)];
    
    [btnNull setTitle:AMLocalizedString(@"Null signature", nil) forState:UIControlStateNormal];
    [btnSignCancel setTitle:AMLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [btnSignSave setTitle:AMLocalizedString(@"Save", nil) forState:UIControlStateNormal];

    NSString* str = [g_dicProductMaster objectForKey:global_key_isworkovertimeautomatic];
    if([str isEqualToString:@"NO"])
        isworkovertimeautomatic = NO;
    else
        isworkovertimeautomatic = YES;
    aryRulesList = [g_dicProductMaster objectForKey:global_key_rules_list];
}

- (void) viewWillAppear:(BOOL)animated {
    [self updateProjectsArray];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyRefreshExtra:) name:global_notification_extra_save object:nil];
    if (g_dicExtraInfo)
    {
        NSDictionary * dicProgress = [NSDictionary dictionaryWithDictionary:g_dicExtraInfo];
        if (dicProgress == NULL || [dicProgress isEqual:[NSNull null]]) {
            return;
        }
        NSString * strIndex = [dicProgress valueForKey:global_key_index];
        if (strIndex.integerValue > mArayExtraWork.count)
        {
            [mArayExtraWork addObject:dicProgress];
        }
        else
        {
            [mArayExtraWork replaceObjectAtIndex:strIndex.integerValue withObject:dicProgress];
        }
        [tblView reloadData];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openMenu:) name:global_notification_slide_open object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(revealMenu:) name:global_notification_slide_reveal object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeMenu:) name:global_notification_slide_close object:nil];
    [dimView setHidden:YES];
}

- (void) viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    g_dicExtraInfo = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:global_notification_slide_close object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:global_notification_slide_open object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:global_notification_slide_reveal object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Actions

- (IBAction)onMenu:(id)sender
{
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
}

- (IBAction)onDateTop:(id)sender {
    [self dismissKeyboards];
    [txtStartDate becomeFirstResponder];
}

- (void) onStartWorkingHours {
    [self dismissKeyboards];
    [txtStartWorking becomeFirstResponder];
}
- (void) onEndWorkingHours {
    [self dismissKeyboards];
    [txtEndWorking becomeFirstResponder];
}
- (void) onPlusBreakTimeHour{
    [self dismissKeyboards];
    if (valueBreakTime >= 1380)
    {
        return;
    }
    valueBreakTime += 60;
    
    int hour = valueBreakTime / 60;
    NSString * strHour;
    if (hour < 10)
    {
        strHour = [NSString stringWithFormat:@"0%d %@", hour, AMLocalizedString(@"Hrs", nil)];
    }
    else
    {
        strHour = [NSString stringWithFormat:@"%d %@", hour, AMLocalizedString(@"Hrs", nil)];
    }
    [lblBreakTimeHours setText:strHour];
    [self setTotalWithout];
    
}
- (void) onPlusBreakTimeMinute{
    [self dismissKeyboards];
    if (valueBreakTime >= 1439)
    {
        return;
    }
    valueBreakTime += 1;
//    int minute = valueBreakTime % 60;
//    NSString * strMinute;
//    if (minute < 10)
//    {
//        strMinute = [NSString stringWithFormat:@"0%d Min", minute];
//    }
//    else
//    {
//        strMinute = [NSString stringWithFormat:@"%d Min", minute];
//    }
//
//    [lblBreakTimeMinutes setText:strMinute];
    
    [lblBreakTimeMinutes setText:[NSString stringWithFormat:@"%d Min", valueBreakTime]];

    [self setTotalWithout];
}

- (void) onMinusBreakTimeHour{
    [self dismissKeyboards];
    if (valueBreakTime < 60)
    {
        return;
    }
    valueBreakTime -= 60;
    int hour = valueBreakTime / 60;
    NSString * strHour;
    if (hour < 10)
    {
        strHour = [NSString stringWithFormat:@"0%d %@", hour, AMLocalizedString(@"Hrs", nil)];
    }
    else
    {
        strHour = [NSString stringWithFormat:@"%d %@", hour, AMLocalizedString(@"Hrs", nil)];
    }
    [lblBreakTimeHours setText:strHour];
    [self setTotalWithout];
}
- (void) onMinusBreakTimeMinute{
    [self dismissKeyboards];
    if (valueBreakTime < 1)
    {
        return;
    }
    valueBreakTime -= 1;
//    int minute = valueBreakTime % 60;
//    NSString * strMinute;
//    if (minute < 10)
//    {
//        strMinute = [NSString stringWithFormat:@"0%d Min", minute];
//    }
//    else
//    {
//        strMinute = [NSString stringWithFormat:@"%d Min", minute];
//    }
//    [lblBreakTimeMinutes setText:strMinute];
    [lblBreakTimeMinutes setText:[NSString stringWithFormat:@"%d %@", valueBreakTime, AMLocalizedString(@"Min", nil)]];

    [self setTotalWithout];
}

- (void)onBreakTimeHour {
    [self dismissKeyboards];
    [txtBreakHours becomeFirstResponder];
}
- (void)onBreakTimeMinute {
    [self dismissKeyboards];
    [txtBreakMinutes becomeFirstResponder];
}
- (void) onOvertime50Hour{
    [self dismissKeyboards];
    [txt50Hours becomeFirstResponder];
}
- (void) onOvertime50Minute{
    [self dismissKeyboards];
    [txt50Minutes becomeFirstResponder];
}
- (void) onOvertime100Hour{
    [self dismissKeyboards];
    [txt100Hours becomeFirstResponder];
}
- (void) onOvertime100Minute{
    [self dismissKeyboards];
    [txt100Minutes becomeFirstResponder];
}
- (void)onKilometer{
    [self dismissKeyboards];
    [txtKm becomeFirstResponder];
}
- (void)onKilometerPlus{
    [self dismissKeyboards];
//    if (valueKm >= 99) return;
    valueKm += 1;
    NSString * strKm;
    if (valueKm < 10)
    {
        strKm = [NSString stringWithFormat:@"0%d Km", valueKm];
    }
    else
    {
        strKm = [NSString stringWithFormat:@"%d Km", valueKm];
    }
    [lblKilometers setText:strKm];
}
- (void)onKilometerMinus{
    [self dismissKeyboards];
    if (valueKm < 1) return;
    valueKm -= 1;
    NSString * strKm;
    strKm = [NSString stringWithFormat:@"%d Km", valueKm];
    [lblKilometers setText:strKm];
}
- (void)onAdditionalWork{
    [self dismissKeyboards];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    ExtraWorkCreateVC * vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"ExtraWorkCreateVC"];
    vc.indexOfArray = (int)(mArayExtraWork.count) + 1;
    vc.dicInfo = nil;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)onExtraDetails:(UIButton*) btn{
    [self dismissKeyboards];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    ExtraWorkCreateVC * vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"ExtraWorkCreateVC"];
    vc.indexOfArray = (int)(btn.tag);
    NSDictionary * dicOne = [mArayExtraWork objectAtIndex:btn.tag];
    vc.dicInfo = [dicOne mutableCopy];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void) onExtraRemove:(UIButton *)btn
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Are you sure to remove?", @"Are you sure to remove?") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:AMLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                    {
                                        
                                    }];
    [alert addAction:defaultAction];
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:AMLocalizedString(@"Ok", @"Ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                               {
                                   [mArayExtraWork removeObjectAtIndex:btn.tag];
                                   [tblView reloadData];
                               }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}
- (void)onAttachPlus {
    [self dismissKeyboards];
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:AMLocalizedString(@"Profile Image", @"Profile Image") delegate:self cancelButtonTitle:AMLocalizedString(@"Close", @"Close") destructiveButtonTitle:nil otherButtonTitles:
                            AMLocalizedString(@"Take Photo", @"Take Photo") , AMLocalizedString(@"Choose from photos", @"Choose from photos")
                            ,
                            nil];
    [popup showInView:self.view];
}
- (void)onAttachRemove:(UIButton*) btn {
    [self dismissKeyboards];
    [mArayAttachment removeObjectAtIndex:btn.tag];
    [tblView reloadData];
}
- (void)onAttachPreview:(UIButton*) btn {
    [self dismissKeyboards];
    UIImage * imgPreview = btn.currentBackgroundImage;
    if (!imgPreview) return;
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    ImagePreviewVC * vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"ImagePreviewVC"];
    vc.imgContent = imgPreview;
    [self presentViewController:vc animated:YES completion:nil];
}
- (void)onSigningHours {
    [self dismissKeyboards];
//    [[drawSignatureView drawImageView] setImage:nil];

    User * user = [GlobalUtils loadUserObjectWithKey:global_user_info_save];
    txtEmail.text = user.strEmail;
    txtSignature.text = user.strFirstName;

    NSDictionary * dicProject = [mArayProjects objectAtIndex:selectedProjectIndex];
    NSString* contactName = [dicProject objectForKey:@"project_contact_name"];
    NSString* contactEmail = [dicProject objectForKey:@"project_contact_email"];
//    txtSignature.text = contactName;
//    txtEmail.text = contactEmail;
    txtContactName.text = contactName;
    txtContactEmail.text = contactEmail;

    viewSignatureDim.hidden = NO;
    viewSignature.hidden = NO;
    [self.view bringSubviewToFront:viewSignature];
}
- (IBAction)onNullSignature:(id)sender {
    [[drawSignatureView drawImageView] setImage:nil];
}
- (IBAction)saveSignature:(id)sender {
    NSString* strSignature = txtSignature.text;
    if(strSignature == NULL || strSignature.length < 1){
        [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Please input 'Name:' filed.", @"Please input 'Name:' filed.") cancel:AMLocalizedString(@"Ok", @"Ok")];
        return;
    }
    NSString* strEmail = txtEmail.text;
    if(strEmail == NULL || strEmail.length < 1){
        [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Please Enter Email Address", @"Please Enter Email Address") cancel:AMLocalizedString(@"Ok", @"Ok")];
        return;
    }
//    User * user = [GlobalUtils loadUserObjectWithKey:global_user_info_save];

    UIImage *image = [drawSignatureView image];
    if (image == nil) {
        [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Please draw Signature.", @"Please draw Signature") cancel:AMLocalizedString(@"Ok", @"Ok")];
        return;
    }
    
    NSString* strContactName = txtContactName.text;
    if(strContactName == NULL || strContactName.length < 1){
        [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Please add Contact person", @"Please add Contact person") cancel:AMLocalizedString(@"Ok", @"Ok")];
        return;
    }

    NSString* strContactEmail = txtContactEmail.text;
    if(strContactEmail == NULL || strContactEmail.length < 1){
        [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Please add Contact email", @"Please add Contact email") cancel:AMLocalizedString(@"Ok", @"Ok")];
        return;
    }

    User * user = [GlobalUtils loadUserObjectWithKey:global_user_info_save];
    if(![strEmail isEqualToString:user.strEmail] || ![strSignature isEqualToString:user.strFirstName]){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Are you sure, if name is correct?", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:AMLocalizedString(@"NO", @"NO") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                       {
                                           
                                       }];
        [alert addAction:cancelAction];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:AMLocalizedString(@"YES", @"YES") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                        {
                                            viewSignatureDim.hidden = YES;
                                            viewSignature.hidden = YES;
                                        }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];

    }else{
        viewSignatureDim.hidden = YES;
        viewSignature.hidden = YES;
    }
}

- (IBAction)cancelSignature:(id)sender {
    txtSignature.text = NULL;
    [[drawSignatureView drawImageView] setImage:nil];

    viewSignatureDim.hidden = YES;
    viewSignature.hidden = YES;

}

- (void)onProject:(UIButton *) btn {
    NSString * strIndex = [mAryFilteredIndex objectAtIndex:btn.tag];
    selectedProjectIndex = strIndex.intValue;
    strFilter = [mAryFilteredContent objectAtIndex:btn.tag];
    [txtSelectProject setText:strFilter];
    [self dismissKeyboards];
}
- (void)onSave {
    [self dismissKeyboards];
    
    if (txtSelectProject.text.length == 0)
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
//    if (![strSelected isEqualToString:txtSelectProject.text])
//    {
//        [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Please select project.", @"Please select project.") cancel:AMLocalizedString(@"Ok", @"Ok")];
//        return;
//    }
    if (txtComment.text.length == 0)
    {
        [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Please input comment.", @"Please input comment.") cancel:AMLocalizedString(@"Ok", @"Ok")];
        return;
    }
    
    if (valueEnd < valueStart){
        [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"The finish time can't be less than the start time", @"The finish time can't be less than the start time") cancel:AMLocalizedString(@"Ok", @"Ok")];
        return;

    }
    NSString * param_service_id = @"";
    param_service_id = @"0";
    int value = valueEnd - valueStart - value50 - value100 - valueBreakTime;
    if (value < 0)
    {
        value = 0;
    }
    NSString * param_total_time = [NSString stringWithFormat:@"%d", value];
    NSString * param_language = @"en";
    User * user = [GlobalUtils loadUserObjectWithKey:global_user_info_save];
    NSString * param_user_id = user.strUserID;
    NSString * param_app_version = @"";
    NSString * param_over_time1 = [NSString stringWithFormat:@"%d", value50];
    NSString * param_over_time2 = [NSString stringWithFormat:@"%d", value100];
    NSString * param_work_id = @"";
    NSString * param_is_automatic = @"NO";
    NSString * param_work_start_time = lblWorkingHoursStart.text;
    NSString * param_work_end_time = lblWorkingHoursEnd.text;
    NSMutableArray * param_overtime_details = [[NSMutableArray alloc] init];
    NSMutableDictionary * dic50over = [[NSMutableDictionary alloc] init];
    [dic50over setObject:@"50" forKey:global_key_rule];
    [dic50over setObject:@"M" forKey:global_key_ot_type];
    [dic50over setObject:@"0" forKey:global_key_minutes];
    [dic50over setObject:[NSString stringWithFormat:@"%d", value50] forKey:global_key_actual_minute];
    NSMutableDictionary * dic100over = [[NSMutableDictionary alloc] init];
    [dic100over setObject:@"100" forKey:global_key_rule];
    [dic100over setObject:@"M" forKey:global_key_ot_type];
    [dic100over setObject:@"0" forKey:global_key_minutes];
    [dic100over setObject:[NSString stringWithFormat:@"%d", value100] forKey:global_key_actual_minute];
    [param_overtime_details addObject:dic50over];
    [param_overtime_details addObject:dic100over];
    
    NSString * param_os = @"ios";
    NSString * param_branch_id = @"0";
    
    NSMutableArray * param_extra_service = [[NSMutableArray alloc] init];
    for (int i = 0; i < mArayExtraWork.count; i ++)
    {
        NSDictionary * dicOne = [mArayExtraWork objectAtIndex:i];
        NSString * strFlag = [dicOne valueForKey:global_key_index];
        NSMutableDictionary * dicAdd = [[NSMutableDictionary alloc] init];
        if (strFlag)
        {
            NSString * strHour = [dicOne valueForKey:global_key_notify_work_hours];
            NSString * strMinutes = [dicOne valueForKey:global_key_notify_work_minutes];
            
            [dicAdd setValue:[NSString stringWithFormat:@"%d", strHour.intValue * 60 + strMinutes.intValue] forKey:global_key_service_time];
            [dicAdd setValue:[dicOne valueForKey:global_key_notify_comments] forKey:global_key_service_comment];
            [dicAdd setValue:@"1" forKey:global_key_service_id];
        }
        else
        {
            [dicAdd setValue:[dicOne valueForKey:global_key_service_time] forKey:global_key_service_time];
            [dicAdd setValue:[dicOne valueForKey:global_key_service_comment] forKey:global_key_service_comment];
            [dicAdd setValue:@"1" forKey:global_key_service_id];
        }
        [param_extra_service addObject:dicAdd];
    }
    NSString * param_company_id = user.strCompanyID;
//    NSString * strProjectIndex = [mAryFilteredIndex objectAtIndex:selectedProjectIndex];
//    NSDictionary * dicProject = [mArayProjects objectAtIndex:strProjectIndex.integerValue];
    NSDictionary * dicProject = [mArayProjects objectAtIndex:selectedProjectIndex];
    NSString * param_project_id = [dicProject valueForKey:global_key_project_id];
    int hour50 = value50 / 60;
    NSString * strHour50;
    if (hour50 < 10)
    {
        strHour50 = [NSString stringWithFormat:@"0%d", hour50];
    }
    else
    {
        strHour50 = [NSString stringWithFormat:@"%d", hour50];
    }
    int minute50 = value50 % 60;
    NSString * strMinute50;
    if (minute50 < 10)
    {
        strMinute50 = [NSString stringWithFormat:@"0%d", minute50];
    }
    else
    {
        strMinute50 = [NSString stringWithFormat:@"%d", minute50];
    }
    
    int hour100 = value100 / 60;
    NSString * strHour100;
    if (hour100 < 10)
    {
        strHour100 = [NSString stringWithFormat:@"0%d", hour100];
    }
    else
    {
        strHour100 = [NSString stringWithFormat:@"%d", hour100];
    }
    
    int minute100 = value100 % 60;
    NSString * strMinute100;
    if (minute100 < 10)
    {
        strMinute100 = [NSString stringWithFormat:@"0%d", minute100];
    }
    else
    {
        strMinute100 = [NSString stringWithFormat:@"%d", minute100];
    }
    
    NSString * param_over_time1_start_time = [NSString stringWithFormat:@"%@", strHour100];
    NSString * param_over_time1_end_time = [NSString stringWithFormat:@"%@", strMinute100];
    NSString * param_over_time2_start_time = [NSString stringWithFormat:@"%@", strHour50];
    NSString * param_over_time2_end_time = [NSString stringWithFormat:@"%@", strMinute50];
    value = valueEnd - valueStart;
    if (value < 0)
    {
        value = 0;
    }
    NSString * param_work_hour = [NSString stringWithFormat:@"%d", value];
    NSString * param_attachment_ids = [NSString stringWithFormat:@""];
    NSString * param_work_date = strDateSave;
    NSString * param_comments = txtComment.text;
    NSString * param_break_time = [NSString stringWithFormat:@"%d", valueBreakTime];
    NSString * strKM = lblKilometers.text;
    NSArray * aryKm = [strKM componentsSeparatedByString:@" "];
    NSString * strKmValue = [aryKm objectAtIndex:0];
    NSString * param_km_drive = strKmValue;
    NSString * param_role_id = user.strRefRoleID;
    NSString * param_approve_status = global_value_pendding;
    
    AppDelegate * app = (AppDelegate*) [UIApplication sharedApplication].delegate;
    [app showHUD];
    
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setObject:param_service_id forKey:global_key_service_id];
    [param setObject:param_total_time forKey:global_key_total_time];
    [param setObject:param_language forKey:global_key_language];
    [param setObject:param_user_id forKey:global_key_user_id];
    [param setObject:param_app_version forKey:global_key_app_version];
    [param setObject:param_over_time1 forKey:global_key_over_time1];
    [param setObject:param_over_time2 forKey:global_key_over_time2];
    [param setObject:param_work_id forKey:global_key_work_id];
    [param setObject:param_is_automatic forKey:global_key_is_automatic];
    [param setObject:param_work_start_time forKey:global_key_work_start_time];
    [param setObject:param_overtime_details forKey:global_key_overtime_details];
    [param setObject:param_os forKey:global_key_os];
    [param setObject:param_branch_id forKey:global_key_branch_id];
    [param setObject:param_extra_service forKey:global_key_extra_service];
    [param setObject:param_company_id forKey:global_key_company_id];
    [param setObject:param_project_id forKey:global_key_project_id];
    [param setObject:param_work_end_time forKey:global_key_work_end_time];
    [param setObject:param_over_time1_start_time forKey:global_key_over_time1_start_time];
    [param setObject:param_over_time1_end_time forKey:global_key_over_time1_end_time];
    [param setObject:param_over_time2_start_time forKey:global_key_over_time2_start_time];
    [param setObject:param_over_time2_end_time forKey:global_key_over_time2_end_time];
    [param setObject:param_work_hour forKey:global_key_work_hour];
    [param setObject:param_attachment_ids forKey:global_key_attachment_ids];
    [param setObject:param_work_date forKey:global_key_work_date];
    [param setObject:param_comments forKey:global_key_comments];
    [param setObject:param_break_time forKey:global_key_break_time];
    [param setObject:param_km_drive forKey:global_key_km_drive];
    [param setObject:param_role_id forKey:global_key_role_id];
    [param setObject:param_approve_status forKey:global_key_approve_status];
    
    NSString *sign = txtSignature.text;
    if(sign && sign.length > 0)
        [param setObject:sign forKey:@"txtSignedBy"];
    NSString *signEmail = txtEmail.text;
    if(signEmail && signEmail.length > 0)
        [param setObject:signEmail forKey:@"txtSignedEmail"];

    UIImage *imagSingature = drawSignatureView.image;
    if(imagSingature){
        NSData *pngData = UIImagePNGRepresentation(imagSingature);
        NSString *stringImage = [pngData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        [param setObject:[NSString stringWithFormat:@"data:image/png;base64,%@", stringImage] forKey:@"signature"];
    }

    NSString *contactName = txtContactName.text;
    if(contactName && contactName.length > 0)
        [param setObject:contactName forKey:@"txtContactName"];
    NSString *contactEmail = txtContactEmail.text;
    if(contactEmail && contactEmail.length > 0)
        [param setObject:contactEmail forKey:@"txtContactEmail"];

    //0926
    if(btnPTOBank.selected)
        [param setObject:@"yes" forKey:@"is_ptobank"];
    else
        [param setObject:@"no" forKey:@"is_ptobank"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager POST:global_api_approve parameters:param success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject)
         {
        [app hideHUD];
        NSDictionary * dicResult = (NSDictionary*) responseObject;
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
                        if(mArayAttachment.count > 0){
                            NSString *strWork_id = [dicResObject objectForKey:@"work_id"];
                            [self uploadImagesWithWorkID:strWork_id];
                        }
                        
                        NSArray* aryService = [dicResObject objectForKey:@"extra_service"];
                        for (int k = 0; k < aryService.count; k++) {
                            NSDictionary * dic = [aryService objectAtIndex:k];
                            NSString * strServiceID = [dic objectForKey:@"service_id"];
                            NSDictionary * dicOne = [mArayExtraWork objectAtIndex:k];
                            NSArray * aryImages = [dicOne valueForKey:global_key_notify_images];
                            [self uploadImagesWithServiceID:strServiceID arrayImages:aryImages];
                        }

                        [self getMasterUpdated];

                        NSString * errorString;
                        errorString = [NSString stringWithFormat:@"%@", [dicResult valueForKey:global_key_res_message]];
                        errorString = AMLocalizedString(errorString, nil);
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:AMLocalizedString(@"Onjyb", @"Onjyb") message:errorString preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction* okAction = [UIAlertAction actionWithTitle:AMLocalizedString(@"Ok", @"Ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                                   {
                                                           UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                                                                    bundle: nil];
                                                           
                                                           MineHoursVC * vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"MineHoursVC"];
                                                           [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc withSlideOutAnimation:YES andCompletion:^{
                                                               [vc onPending];
                                                           }];

                                                       
                                                   }];
                        [alert addAction:okAction];
                        [self presentViewController:alert animated:YES completion:nil];
                        
                    }
                    return;
                }
                NSString * errorString = AMLocalizedString(@"Error occured.", @"Error occured.");
                if ([dicResult valueForKey:global_key_res_message])
                {
                    errorString = [NSString stringWithFormat:@"%@", [dicResult valueForKey:global_key_res_message]];
                    errorString = AMLocalizedString(errorString, nil);
                }
                [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:errorString cancel:AMLocalizedString(@"Ok", @"Ok")];
                return;
            }
            NSString * errorString = AMLocalizedString(@"Error occured.", @"Error occured.");
            [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:errorString cancel:AMLocalizedString(@"Ok", @"Ok")];
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [app hideHUD];
        [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Could not connect with server. Please try again later!", @"Could not connect with server. Please try again later!") cancel:AMLocalizedString(@"Ok", @"Ok")];
        return;

    }];

}
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
    viewSignatureDim.hidden = YES;
    viewSignature.hidden = YES;

}
- (void)uploadImagesWithWorkID:(NSString*)work_id{
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setObject:work_id forKey:@"map_id"];
    [param setObject:@"" forKey:@"image_id"];
    [param setObject:@"worksheet" forKey:@"map_type"];

    for(int i = 0; i < mArayAttachment.count; i++){
        UIImage *image = [mArayAttachment objectAtIndex:0];
        NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
        NSString * strNamePhoto = [NSString stringWithFormat:@"Pic%f.jpg", timeStamp];
        [MyRequest IMAGE_POST_JSON:global_api_imagesUpload parameters:param imagePicked:image strParamPhoto:global_key_user_photo strNamePhoto:strNamePhoto  completed:nil];
    }

}
- (void)uploadImagesWithServiceID:(NSString*)service_id arrayImages:(NSArray*)aryImages{
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setObject:service_id forKey:@"map_id"];
    [param setObject:@"" forKey:@"image_id"];
    [param setObject:@"service" forKey:@"map_type"];
    
        for(UIImage * image in aryImages){
            NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
            NSString * strNamePhoto = [NSString stringWithFormat:@"PicService%f.jpg", timeStamp];
            [MyRequest IMAGE_POST_JSON:global_api_imagesUpload parameters:param imagePicked:image strParamPhoto:global_key_user_photo strNamePhoto:strNamePhoto  completed:nil];

        }
}
- (void)onButtonStart:(id)sender{
    [self onStartWorkingWithDate:[NSDate date]];
}
- (void)onButtonFinish:(id)sender{
    [self onEndWorkingWithDate:[NSDate date]];
}

- (void) onStartWorkingWithDate:(NSDate*)date{
    //    NSDate * date = [mPickerStartWorking date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    valueStart = (int)(hour * 60 + minute);
    NSString * strHour;
    if (hour < 10)
    {
        strHour = [NSString stringWithFormat:@"0%ld", (long)hour];
    }
    else
    {
        strHour = [NSString stringWithFormat:@"%ld", (long)hour];
    }
    NSString * strMinute;
    if (minute < 10)
    {
        strMinute = [NSString stringWithFormat:@"0%ld", (long)minute];
    }
    else
    {
        strMinute = [NSString stringWithFormat:@"%ld", (long)minute];
    }
    [lblWorkingHoursStart setText:[NSString stringWithFormat:@"%@:%@", strHour, strMinute]];
    [self setTotalWithout];

}
- (void) onEndWorkingWithDate:(NSDate*)date{
    //    NSDate * date = [mPickerEndWorking date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    NSString * strHour;
    if (hour < 10)
    {
        strHour = [NSString stringWithFormat:@"0%ld", (long)hour];
    }
    else
    {
        strHour = [NSString stringWithFormat:@"%ld", (long)hour];
    }
    NSString * strMinute;
    if (minute < 10)
    {
        strMinute = [NSString stringWithFormat:@"0%ld", (long)minute];
    }
    else
    {
        strMinute = [NSString stringWithFormat:@"%ld", (long)minute];
    }
    NSString *endTime = [NSString stringWithFormat:@"%@:%@", strHour, strMinute];
    if([lblWorkingHoursStart.text isEqualToString:endTime]){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Start time and end time cannot be same.", @"nil") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:AMLocalizedString(@"Ok", @"Ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                   {
                                   }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];

        return;
    }
    valueEnd = (int)(hour * 60 + minute);

    [lblWorkingHoursEnd setText:endTime];
    [self setTotalWithout];

}
- (void) onDatePickerDone
{
    if ([txtKm isFirstResponder])
    {
//        NSUInteger selectedRow = [mPickerKm selectedRowInComponent:0];
//        valueKm = (int)selectedRow;
//        [lblKilometers setText:[NSString stringWithFormat:@"%lu Km", (unsigned long)selectedRow]];
    }
    if ([txtStartDate isFirstResponder])
    {
        NSDate * date = mPickerStartDate.date;
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd/MM/yyyy"];
        strDateSave = [formatter stringFromDate:date];
        [formatter setDateFormat:@"dd MMM yy"];
        NSString * str = [formatter stringFromDate:date];
//        [lblTopDate setText:[NSString stringWithFormat:@"Start         %@", str]];
        [lblTopDate setText:[NSString stringWithFormat:@"%@         %@", AMLocalizedString(@"Date", nil), str]];

    }
    if ([txtStartWorking isFirstResponder])
    {
        [self onStartWorkingWithDate:[mPickerStartWorking date]];
    }
    if ([txtEndWorking isFirstResponder])
    {
        [self onEndWorkingWithDate:[mPickerEndWorking date]];
    }
    if ([txtBreakHours isFirstResponder])
    {
        NSUInteger hour = [mPickerBreakHours selectedRowInComponent:0];
        int minute = valueBreakTime % 60;
        valueBreakTime = (int)(hour * 60 + minute);
        NSString * strHour;
        if (hour < 10)
        {
            strHour = [NSString stringWithFormat:@"0%lu", (unsigned long)hour];
        }
        else
        {
            strHour = [NSString stringWithFormat:@"%lu", (unsigned long)hour];
        }
        [lblBreakTimeHours setText:[NSString stringWithFormat:@"%@ %@", strHour, AMLocalizedString(@"Hrs", nil)]];
        [self setTotalWithout];
    }
    if ([txtBreakMinutes isFirstResponder])
    {
        NSUInteger minute = [mPickerBreakMinutes selectedRowInComponent:0];
//        int hour = valueBreakTime / 60;
//        valueBreakTime = (int)(hour * 60 + minute);
        valueBreakTime = (int)minute * 10;
//        NSString * strMinute;
//        if (minute < 10)
//        {
//            strMinute = [NSString stringWithFormat:@"0%lu", (unsigned long)minute];
//        }
//        else
//        {
//            strMinute = [NSString stringWithFormat:@"%lu", (unsigned long)minute];
//        }
        [lblBreakTimeMinutes setText:[NSString stringWithFormat:@"%d %@", valueBreakTime, AMLocalizedString(@"Min", nil)]];
        [self setTotalWithout];
    }
    if ([txt50Hours isFirstResponder])
    {
        NSUInteger hour = [mPicker50Hours selectedRowInComponent:0];
        int minute = value50 % 60;
        value50 = (int)(hour * 60 + minute);
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
        [lblOvertime50Hours setText:[NSString stringWithFormat:@"%@ %@", strHour, AMLocalizedString(@"Hrs", nil)]];
        [lblTotalovertime50 setText:[NSString stringWithFormat:@"%@ %@ | %@ m", strHour, AMLocalizedString(@"h", nil), strMinute]];
        [self setTotalWithout];
    }
    if ([txt50Minutes isFirstResponder])
    {
        NSUInteger minute = [mPicker50Minutes selectedRowInComponent:0];
        int hour = value50 / 60;
        value50 = (int)(hour * 60 + minute);
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
        [lblOvertime50Minutes setText:[NSString stringWithFormat:@"%@ %@", strMinute, AMLocalizedString(@"Min", nil)]];
        [lblTotalovertime50 setText:[NSString stringWithFormat:@"%@ %@ | %@ m", strHour, AMLocalizedString(@"h", nil), strMinute]];
        [self setTotalWithout];
    }
    if ([txt100Hours isFirstResponder])
    {
        NSUInteger hour = [mPicker100Hours selectedRowInComponent:0];
        int minute = value100 % 60;
        value100 = (int)(hour * 60 + minute);
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
        [lblTotalovertime100 setText:[NSString stringWithFormat:@"%@ %@ | %@ m", strHour, AMLocalizedString(@"h", nil), strMinute]];
        [lblOvertime100Hours setText:[NSString stringWithFormat:@"%@ %@", strHour, AMLocalizedString(@"Hrs", nil)]];
        [self setTotalWithout];
    }
    if ([txt100Minutes isFirstResponder])
    {
        NSUInteger minute = [mPicker100Minutes selectedRowInComponent:0];
        int hour = value100 / 60;
        value100 = (int)(hour * 60 + minute);
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
        [lblTotalovertime100 setText:[NSString stringWithFormat:@"%@ %@ | %@ m", strHour, AMLocalizedString(@"h", nil), strMinute]];
        [lblOvertime100Minutes setText:[NSString stringWithFormat:@"%@ %@", strMinute, AMLocalizedString(@"Min", nil)]];
        [self setTotalWithout];
    }
    [self dismissKeyboards];
}
-(IBAction)onOvertimeArrow:(UIButton*)sender{
    sender.selected = !sender.selected;
    isSelectOvertimeArrowButton = sender.selected;
    [tblView reloadData];
}
#pragma mark - TableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return cell_Num;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == cell_SelectWorkingHours)
    {
        return cellHeight * 4;
    }
    if (indexPath.row == cell_Project){
        return cellHeight + topPadding;
    }
    if (indexPath.row == cell_PTOBank){
        return cellHeight;
    }
    if (indexPath.row == cell_SelectBreakTime || indexPath.row == cell_Kilometers)
    {
        return cellHeight * 2 - topPadding * 3;
    }
    if (indexPath.row == cell_SelectOverTime)
    {
        
        if(isworkovertimeautomatic)
            return 0;
        if(!isSelectOvertimeArrowButton)
            return cellHeight;

        return cellHeight * 6 - topPadding * 10;
    }
    if (indexPath.row == cell_ExtraWork)
    {
        if (!mArayExtraWork) mArayExtraWork = [[NSMutableArray alloc] init];
        if (mArayExtraWork && mArayExtraWork.count)
            return (1.5 * mArayExtraWork.count + 1) * cellHeight;
        return cellHeight * 2.5;
    }
    if (indexPath.row == cell_Attachment)
    {
        if (!mArayAttachment) mArayAttachment = [[NSMutableArray alloc] init];
        int num;
        CGFloat widthOne = (global_screen_size.width - 2 * leftPadding) / 5 - 8;
        if ((mArayAttachment.count + 1) % 5 == 0) num = (int) ((mArayAttachment.count + 1) / 5);
        else num = (int) ((mArayAttachment.count + 1) / 5) + 1;
        return cellHeight + topPadding + (widthOne + 8) * num;
    }
    if (indexPath.row == cell_Comments)
    {
        return cellHeight + txtComment.frame.size.height + topPadding;
    }
    if (indexPath.row == cell_TotalOverTime)
    {
//        if(isworkovertimeautomatic){
            CGFloat h = cellHeight - 2 * topPadding;
            return topPadding + h + h * aryRulesList.count + h * 3 + 2 * topPadding;
//        }
//        return cellHeight * 6 - 9 * topPadding;
    }
    return cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPah
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"registerTimeDetailCell"];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"registerTimeDetailCell"];
    }
    [cell.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    cell.backgroundColor = [UIColor clearColor];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (indexPah.row == cell_Project)
    {
        [cell addSubview:txtSelectProject];
    }
    if (indexPah.row == cell_Branch)
    {
        [cell addSubview:txtSelectBranch];
    }
    if (indexPah.row == cell_SelectWorkingHours)
    {
        UIView * viewContainer = [[UIView alloc] initWithFrame:CGRectMake(leftPadding, topPadding, global_screen_size.width - 2 * leftPadding, cellHeight * 4 - topPadding * 2)];
        [viewContainer setBackgroundColor:[UIColor clearColor]];
        viewContainer.layer.borderColor = global_darkgray_color.CGColor;
        viewContainer.layer.cornerRadius = 4.f;
        viewContainer.layer.borderWidth = 1.f;
        
        [cell addSubview:viewContainer];
        UIView * viewgray = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewContainer.frame.size.width, viewContainer.frame.size.height / 2)];
        [viewgray setBackgroundColor:global_gray_color];
        [viewContainer addSubview:viewgray];
        
        UILabel * lblWorkHoursTitle = [[UILabel alloc] initWithFrame:CGRectMake(leftPadding, 0, viewgray.frame.size.width - 2 * leftPadding, viewgray.frame.size.height / 2)];
        [lblWorkHoursTitle setTextColor: global_nav_color];
        [lblWorkHoursTitle setText:AMLocalizedString(@"Select Working Hours", @"Select Working Hours")];
        UILabel * lblWorkHoursDescription = [[UILabel alloc] initWithFrame:CGRectMake(lblWorkHoursTitle.frame.origin.x, lblWorkHoursTitle.frame.size.height * 0.75, lblWorkHoursTitle.frame.size.width, lblWorkHoursTitle.frame.size.height * 1.1)];
        [lblWorkHoursDescription setNumberOfLines:0];
        [lblWorkHoursDescription setText:AMLocalizedString(@"Register working hours by clicking on start and finish buttons or manually.", @"Register working hours by clicking on start and finish buttons or manually.")];
        [lblWorkHoursDescription setTextColor:[UIColor grayColor]];
        
        [viewgray addSubview:lblWorkHoursTitle];
        [viewgray addSubview:lblWorkHoursDescription];
        
        UIBezierPath *maskPathNF = [UIBezierPath bezierPathWithRoundedRect:viewgray.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(4.0, 4.0)];
        CAShapeLayer *maskLayerNF = [[CAShapeLayer alloc] init];
        maskLayerNF.frame = self.view.bounds;
        maskLayerNF.path  = maskPathNF.CGPath;
        viewgray.layer.mask = maskLayerNF;
        
        UIButton * btnWorkingHourStart = [[UIButton alloc] initWithFrame:CGRectMake(leftPadding, viewgray.frame.size.height + viewgray.frame.size.height / 8 - 2, viewgray.frame.size.height / 4 * 2.5, viewgray.frame.size.height / 4 + 4)];
        [btnWorkingHourStart setBackgroundColor:global_green_color];
        [btnWorkingHourStart setTitle:AMLocalizedString(@"Start", @"Start") forState:UIControlStateNormal];
        [btnWorkingHourStart setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnWorkingHourStart.layer.cornerRadius = 4.f;
        btnWorkingHourStart.layer.masksToBounds = YES;
        [btnWorkingHourStart addTarget:self action:@selector(onButtonStart:) forControlEvents:UIControlEventTouchUpInside];
        UIButton * btnHourStart = [[UIButton alloc] initWithFrame:CGRectMake(viewContainer.frame.size.width - clockHeight - 10, btnWorkingHourStart.frame.origin.y + btnWorkingHourStart.frame.size.height / 2 - clockHeight / 2, clockHeight, clockHeight)];
        [btnHourStart setBackgroundImage:[UIImage imageNamed:@"clock"] forState:UIControlStateNormal];
        [btnHourStart addTarget:self action:@selector(onStartWorkingHours) forControlEvents:UIControlEventTouchUpInside];
        UIView * viewSepOne = [[UIView alloc] initWithFrame:CGRectMake(viewContainer.frame.size.width - clockHeight - 20, btnWorkingHourStart.frame.origin.y, 1.5, btnWorkingHourStart.frame.size.height)];
        [viewSepOne setBackgroundColor:global_darkgray_color];
        [lblWorkingHoursStart setFrame:CGRectMake(viewSepOne.frame.origin.x - 8 - 200, viewgray.frame.size.height, 200, viewgray.frame.size.height / 2)];
        [lblWorkingHoursStart setTextColor:[UIColor grayColor]];
        [lblWorkingHoursStart setTextAlignment:NSTextAlignmentRight];
        [lblWorkingHoursStart setBackgroundColor:[UIColor clearColor]];
        [viewContainer addSubview:lblWorkingHoursStart];
        [viewContainer addSubview:btnWorkingHourStart];
        [viewContainer addSubview:btnHourStart];
        [viewContainer addSubview:viewSepOne];
        UIButton * btnStartLabel = [[UIButton alloc] initWithFrame:lblWorkingHoursStart.frame];
        [btnStartLabel setBackgroundColor:[UIColor clearColor]];
        [btnStartLabel addTarget:self action:@selector(onStartWorkingHours) forControlEvents:UIControlEventTouchUpInside];
        [viewContainer addSubview:btnStartLabel];
        
        UIButton * btnWorkingHourEnd = [[UIButton alloc] initWithFrame:CGRectMake(leftPadding, viewgray.frame.size.height + viewgray.frame.size.height / 8 - 2 + viewgray.frame.size.height / 2, viewgray.frame.size.height / 4 * 2.5, viewgray.frame.size.height / 4 + 4)];
        [btnWorkingHourEnd setBackgroundColor:global_red_color];
        [btnWorkingHourEnd setTitle:AMLocalizedString(@"Finish", @"Finish") forState:UIControlStateNormal];
        [btnWorkingHourEnd setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnWorkingHourEnd.layer.cornerRadius = 4.f;
        btnWorkingHourEnd.layer.masksToBounds = YES;
        [btnWorkingHourEnd addTarget:self action:@selector(onButtonFinish:) forControlEvents:UIControlEventTouchUpInside];
        UIButton * btnHourEnd = [[UIButton alloc] initWithFrame:CGRectMake(viewContainer.frame.size.width - clockHeight - 10, btnWorkingHourEnd.frame.origin.y + btnWorkingHourEnd.frame.size.height / 2 - clockHeight / 2, clockHeight, clockHeight)];
        [btnHourEnd setBackgroundImage:[UIImage imageNamed:@"clock"] forState:UIControlStateNormal];
        [btnHourEnd addTarget:self action:@selector(onEndWorkingHours) forControlEvents:UIControlEventTouchUpInside];
        UIView * viewSepTwo = [[UIView alloc] initWithFrame:CGRectMake(viewContainer.frame.size.width - clockHeight - 20, btnWorkingHourEnd.frame.origin.y, 1.5, btnWorkingHourEnd.frame.size.height)];
        [viewSepTwo setBackgroundColor:global_darkgray_color];
        [lblWorkingHoursEnd setFrame:CGRectMake(viewSepTwo.frame.origin.x - 8 - 200, viewgray.frame.size.height * 1.5, 200, viewgray.frame.size.height / 2)];
        [lblWorkingHoursEnd setTextColor:[UIColor grayColor]];
        [lblWorkingHoursEnd setTextAlignment:NSTextAlignmentRight];
        [lblWorkingHoursEnd setBackgroundColor:[UIColor clearColor]];
        [viewContainer addSubview:lblWorkingHoursEnd];
        [viewContainer addSubview:btnWorkingHourEnd];
        [viewContainer addSubview:btnHourEnd];
        [viewContainer addSubview:viewSepTwo];
        UIButton * btnEndLabel = [[UIButton alloc] initWithFrame:lblWorkingHoursEnd.frame];
        [btnEndLabel setBackgroundColor:[UIColor clearColor]];
        [btnEndLabel addTarget:self action:@selector(onEndWorkingHours) forControlEvents:UIControlEventTouchUpInside];
        [viewContainer addSubview:btnEndLabel];
        
        UIView * viewSepHorizon = [[UIView alloc] initWithFrame:CGRectMake(0, viewContainer.frame.size.height * 3 / 4, viewContainer.frame.size.width, 1)];
        [viewSepHorizon setBackgroundColor:global_darkgray_color];
        [viewContainer addSubview:viewSepHorizon];
        
        if (global_screen_size.width < 330)
        {
            [lblWorkHoursTitle setFont:[UIFont boldSystemFontOfSize:13.f]];
            [lblWorkHoursDescription setFont:[UIFont boldSystemFontOfSize:11.f]];
            [btnWorkingHourStart.titleLabel setFont:[UIFont boldSystemFontOfSize:13.f]];
            [btnWorkingHourEnd.titleLabel setFont:[UIFont boldSystemFontOfSize:13.f]];
        }
        else
        {
            [lblWorkHoursTitle setFont:[UIFont boldSystemFontOfSize:16.f]];
            [lblWorkHoursDescription setFont:[UIFont boldSystemFontOfSize:13.f]];
            [btnWorkingHourStart.titleLabel setFont:[UIFont boldSystemFontOfSize:15.f]];
            [btnWorkingHourEnd.titleLabel setFont:[UIFont boldSystemFontOfSize:15.f]];
        }
    }
    if (indexPah.row == cell_SelectBreakTime)
    {
        UILabel * lbl = [[UILabel alloc] initWithFrame:CGRectMake(leftPadding, 0, 300, cellHeight - 2 * topPadding)];
        [lbl setTextColor:global_nav_color];
        [lbl setText:AMLocalizedString(@"Select Break Hours", @"Select Break Hours")];
        [cell addSubview:lbl];

//        UIView * viewHour = [[UIView alloc] initWithFrame:CGRectMake(leftPadding, lbl.frame.size.height, (global_screen_size.width - leftPadding * 3) / 2, cellHeight - 2 * topPadding)];
//        [viewHour setBackgroundColor:global_gray_color];
//        viewHour.layer.cornerRadius = 4.f;
//        viewHour.layer.borderWidth = 1.f;
//        viewHour.layer.borderColor = global_darkgray_color.CGColor;
//        
//        UIButton * btnMinusHour = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, viewHour.frame.size.width / 6, viewHour.frame.size.height)];
//        [btnMinusHour setBackgroundColor:[UIColor clearColor]];
//        [btnMinusHour addTarget:self action:@selector(onMinusBreakTimeHour) forControlEvents:UIControlEventTouchUpInside];
//        [btnMinusHour setTitleColor:global_nav_color forState:UIControlStateNormal];
//        [btnMinusHour setTitle:@"-" forState:UIControlStateNormal];
//        
//        UIButton * btnHourBreak = [[UIButton alloc] initWithFrame:CGRectMake(btnMinusHour.frame.size.width, 0, btnMinusHour.frame.size.width * 4, viewHour.frame.size.height)];
//        [btnHourBreak setBackgroundColor:[UIColor clearColor]];
//        [btnHourBreak addTarget:self action:@selector(onBreakTimeHour) forControlEvents:UIControlEventTouchUpInside];
//        
//        [lblBreakTimeHours setFrame:btnHourBreak.frame];
//        [lblBreakTimeHours setBackgroundColor:[UIColor whiteColor]];
//        [lblBreakTimeHours setTextAlignment:NSTextAlignmentCenter];
//        
//        UIButton * btnPlusHour = [[UIButton alloc] initWithFrame:CGRectMake(btnMinusHour.frame.size.width * 5, 0, btnMinusHour.frame.size.width, btnMinusHour.frame.size.height)];
//        [btnPlusHour setBackgroundColor:[UIColor clearColor]];
//        [btnPlusHour addTarget:self action:@selector(onPlusBreakTimeHour) forControlEvents:UIControlEventTouchUpInside];
//        [btnPlusHour setTitleColor:global_nav_color forState:UIControlStateNormal];
//        [btnPlusHour setTitle:@"+" forState:UIControlStateNormal];
//        
//        [viewHour addSubview:lblBreakTimeHours];
//        [viewHour addSubview:btnMinusHour];
//        [viewHour addSubview:btnHourBreak];
//        [viewHour addSubview:btnPlusHour];
//        [cell addSubview:viewHour];
        
//        UIView * viewMinute = [[UIView alloc] initWithFrame:CGRectMake(leftPadding + viewHour.frame.size.width + viewHour.frame.origin.x, lbl.frame.size.height, (global_screen_size.width - leftPadding * 3) / 2, cellHeight - 2 * topPadding)];
        UIView * viewMinute = [[UIView alloc] initWithFrame:CGRectMake(leftPadding, lbl.frame.size.height, (global_screen_size.width - leftPadding * 2), cellHeight - 2 * topPadding)];
        [viewMinute setBackgroundColor:global_gray_color];
        viewMinute.layer.cornerRadius = 4.f;
        viewMinute.layer.borderWidth = 1.f;
        viewMinute.layer.borderColor = global_darkgray_color.CGColor;
        
        UIButton * btnMinusMinute = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, viewMinute.frame.size.width / 12, viewMinute.frame.size.height)];
        [btnMinusMinute setBackgroundColor:[UIColor clearColor]];
        [btnMinusMinute addTarget:self action:@selector(onMinusBreakTimeMinute) forControlEvents:UIControlEventTouchUpInside];
        [btnMinusMinute setTitleColor:global_nav_color forState:UIControlStateNormal];
        [btnMinusMinute setTitle:@"-" forState:UIControlStateNormal];
        
        UIButton * btnMinuteBreak = [[UIButton alloc] initWithFrame:CGRectMake(btnMinusMinute.frame.size.width, 0, viewMinute.frame.size.width - btnMinusMinute.frame.size.width * 2, viewMinute.frame.size.height)];
        [btnMinuteBreak setBackgroundColor:[UIColor clearColor]];
        [btnMinuteBreak addTarget:self action:@selector(onBreakTimeMinute) forControlEvents:UIControlEventTouchUpInside];
        
        [lblBreakTimeMinutes setFrame:btnMinuteBreak.frame];
        [lblBreakTimeMinutes setBackgroundColor:[UIColor whiteColor]];
        [lblBreakTimeMinutes setTextAlignment:NSTextAlignmentCenter];
        [lblBreakTimeHours setTextColor:[UIColor grayColor]];
        [lblBreakTimeMinutes setTextColor:[UIColor grayColor]];
        
        UIButton * btnPlusMinute = [[UIButton alloc] initWithFrame:CGRectMake(viewMinute.frame.size.width - btnMinusMinute.frame.size.width, 0, btnMinusMinute.frame.size.width, btnMinusMinute.frame.size.height)];
        [btnPlusMinute setBackgroundColor:[UIColor clearColor]];
        [btnPlusMinute addTarget:self action:@selector(onPlusBreakTimeMinute) forControlEvents:UIControlEventTouchUpInside];
        [btnPlusMinute setTitleColor:global_nav_color forState:UIControlStateNormal];
        [btnPlusMinute setTitle:@"+" forState:UIControlStateNormal];
        
        [viewMinute addSubview:lblBreakTimeMinutes];
        [viewMinute addSubview:btnMinusMinute];
        [viewMinute addSubview:btnMinuteBreak];
        [viewMinute addSubview:btnPlusMinute];
        [cell addSubview:viewMinute];
        if (global_screen_size.width < 330)
        {
            [lbl setFont:[UIFont boldSystemFontOfSize:14.f]];
        }
        else
        {
            [lbl setFont:[UIFont boldSystemFontOfSize:16.f]];
        }
    }
    if (indexPah.row == cell_PTOBank)
    {
        [cell addSubview:btnPTOBank];
    }
    if (indexPah.row == cell_SelectOverTime)
    {
        if(isworkovertimeautomatic){
            [self setTotalWithout];
            return cell;
        }
        CGFloat hOvertime = cellHeight * 6 - 12 * topPadding;
        CGFloat hTitle = cellHeight - 2 * topPadding;

        if(!isSelectOvertimeArrowButton)
            hOvertime = hTitle;
        
        UIView * viewContainer = [[UIView alloc] initWithFrame:CGRectMake(leftPadding, topPadding, global_screen_size.width - 2 * leftPadding, hOvertime)];
        viewContainer.layer.cornerRadius = 4.f;
        viewContainer.layer.borderColor = global_darkgray_color.CGColor;
        viewContainer.layer.borderWidth = 1.f;
        viewContainer.layer.masksToBounds = YES;
        
        UIView * viewTitleOver = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewContainer.frame.size.width, hTitle)];
        
        [viewTitleOver setBackgroundColor:global_gray_color];
        UILabel * lblTitleOver = [[UILabel alloc] initWithFrame:CGRectMake(leftPadding, 0, 300, hTitle)];
        UIBezierPath *maskPathNF = [UIBezierPath bezierPathWithRoundedRect:viewTitleOver.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(4.0, 4.0)];
        CAShapeLayer *maskLayerNF = [[CAShapeLayer alloc] init];
        maskLayerNF.frame = self.view.bounds;
        maskLayerNF.path  = maskPathNF.CGPath;
        viewTitleOver.layer.mask = maskLayerNF;
        [lblTitleOver setText:AMLocalizedString(@"Select Overtime", @"Select Overtime")];
        [lblTitleOver setTextColor:global_nav_color];
        [viewTitleOver addSubview:lblTitleOver];
        
        CGFloat sz = 24;
        UIButton *btnOvertimeArrow = [[UIButton alloc] initWithFrame:CGRectMake(viewContainer.frame.size.width - leftPadding - sz, (hTitle - sz) / 2, sz, sz)];
        [btnOvertimeArrow setImage:[UIImage imageNamed:@"blue_down_arrow"] forState:UIControlStateNormal];
        [btnOvertimeArrow setImage:[UIImage imageNamed:@"blue_up_arrow"] forState:UIControlStateSelected];
        [btnOvertimeArrow addTarget:self action:@selector(onOvertimeArrow:) forControlEvents:UIControlEventTouchUpInside];
        [viewTitleOver addSubview:btnOvertimeArrow];
        btnOvertimeArrow.selected = isSelectOvertimeArrowButton;
        
        [viewContainer addSubview:viewTitleOver];
        
        UIView * view50 = [[UIView alloc] initWithFrame:CGRectMake(0, lblTitleOver.frame.size.height, viewContainer.frame.size.width, lblTitleOver.frame.size.height * 2.5)];
        view50.layer.borderWidth = 1.f;
        view50.layer.borderColor = global_darkgray_color.CGColor;
        [viewContainer addSubview:view50];
        
        UILabel * lbl50Title = [[UILabel alloc] initWithFrame:CGRectMake(leftPadding, 0, 300, view50.frame.size.height / 2.5)];
        [lbl50Title setTextColor:global_nav_color];
        [lbl50Title setText:AMLocalizedString(@"50% Overtime", @"50% Overtime")];
        [view50 addSubview:lbl50Title];
        
        [lblOvertime50Hours setFrame:CGRectMake(lbl50Title.frame.origin.x, lbl50Title.frame.origin.y + lbl50Title.frame.size.height, 200, lbl50Title.frame.size.height * 1.5)];
        [lblOvertime50Hours setTextColor:[UIColor grayColor]];
        [view50 addSubview:lblOvertime50Hours];
        UIView * viewSep50 = [[UIView alloc] initWithFrame:CGRectMake(view50.frame.size.width / 2 - 0.5, lblOvertime50Hours.frame.origin.y + lblOvertime50Hours.frame.size.height / 5, 1, lblOvertime50Hours.frame.size.height * 3 / 5)];
        [viewSep50 setBackgroundColor:global_darkgray_color];
        [view50 addSubview:viewSep50];
        
        UIImageView * imghour50 = [[UIImageView alloc] initWithFrame:CGRectMake(viewSep50.frame.origin.x - 8 - clockHeight, lblOvertime50Hours.frame.origin.y + lblOvertime50Hours.frame.size.height / 2 - clockHeight / 2, clockHeight, clockHeight)];
        [imghour50 setImage:[UIImage imageNamed:@"clock"]];
        [view50 addSubview:imghour50];
        
        UIButton *btn50Hour = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, view50.frame.size.width / 2, view50.frame.size.height)];
        [btn50Hour addTarget:self action:@selector(onOvertime50Hour) forControlEvents:UIControlEventTouchUpInside];
        [view50 addSubview:btn50Hour];
        
        
        [lblOvertime50Minutes setFrame:CGRectMake(lbl50Title.frame.origin.x + view50.frame.size.width / 2, lbl50Title.frame.origin.y + lbl50Title.frame.size.height, 200, lbl50Title.frame.size.height * 1.5)];
        [lblOvertime50Minutes setTextColor:[UIColor grayColor]];
        [view50 addSubview:lblOvertime50Minutes];
        
        UIImageView * imgminute50 = [[UIImageView alloc] initWithFrame:CGRectMake(viewSep50.frame.origin.x - 8 - clockHeight + view50.frame.size.width / 2, lblOvertime50Hours.frame.origin.y + lblOvertime50Hours.frame.size.height / 2 - clockHeight / 2, clockHeight, clockHeight)];
        [imgminute50 setImage:[UIImage imageNamed:@"clock"]];
        [view50 addSubview:imgminute50];
        
        UIButton *btn50Minute = [[UIButton alloc] initWithFrame:CGRectMake(view50.frame.size.width / 2, 0, view50.frame.size.width / 2, view50.frame.size.height)];
        [btn50Minute addTarget:self action:@selector(onOvertime50Minute) forControlEvents:UIControlEventTouchUpInside];
        [view50 addSubview:btn50Minute];
        
        UIView * view100 = [[UIView alloc] initWithFrame:CGRectMake(0, view50.frame.size.height + view50.frame.origin.y, viewContainer.frame.size.width, lblTitleOver.frame.size.height * 2.5)];
        [viewContainer addSubview:view100];
        
        UILabel * lbl100Title = [[UILabel alloc] initWithFrame:CGRectMake(leftPadding, 0, 300, view50.frame.size.height * 2 / 5)];
        [lbl100Title setTextColor:global_nav_color];
        [lbl100Title setText:AMLocalizedString(@"100% Overtime", @"100% Overtime")];
        [view100 addSubview:lbl100Title];
        
        [lblOvertime100Hours setFrame:CGRectMake(lbl50Title.frame.origin.x, lbl50Title.frame.origin.y + lbl50Title.frame.size.height, 200, lbl50Title.frame.size.height * 1.5)];
        [lblOvertime100Hours setTextColor:[UIColor grayColor]];
        [view100 addSubview:lblOvertime100Hours];
        UIView * viewSep100 = [[UIView alloc] initWithFrame:CGRectMake(view50.frame.size.width / 2 - 0.5, lblOvertime50Hours.frame.origin.y + lblOvertime50Hours.frame.size.height / 5, 1, lblOvertime50Hours.frame.size.height * 3 / 5)];
        [viewSep100 setBackgroundColor:global_darkgray_color];
        [view100 addSubview:viewSep100];
        
        UIImageView * imghour100 = [[UIImageView alloc] initWithFrame:CGRectMake(viewSep50.frame.origin.x - 8 - clockHeight, lblOvertime50Hours.frame.origin.y + lblOvertime50Hours.frame.size.height / 2 - clockHeight / 2, clockHeight, clockHeight)];
        [imghour100 setImage:[UIImage imageNamed:@"clock"]];
        [view100 addSubview:imghour100];
        
        UIButton *btn100Hour = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, view50.frame.size.width / 2, view50.frame.size.height)];
        [btn100Hour addTarget:self action:@selector(onOvertime100Hour) forControlEvents:UIControlEventTouchUpInside];
        [view100 addSubview:btn100Hour];
        
        
        [lblOvertime100Minutes setFrame:CGRectMake(lbl50Title.frame.origin.x + view50.frame.size.width / 2, lbl50Title.frame.origin.y + lbl50Title.frame.size.height, 200, lbl50Title.frame.size.height * 1.5)];
        [lblOvertime100Minutes setTextColor:[UIColor grayColor]];
        [view100 addSubview:lblOvertime100Minutes];
        
        UIImageView * imgminute100 = [[UIImageView alloc] initWithFrame:CGRectMake(viewSep50.frame.origin.x - 8 - clockHeight + view50.frame.size.width / 2, lblOvertime50Hours.frame.origin.y + lblOvertime50Hours.frame.size.height / 2 - clockHeight / 2, clockHeight, clockHeight)];
        [imgminute100 setImage:[UIImage imageNamed:@"clock"]];
        [view100 addSubview:imgminute100];
        
        UIButton *btn100Minute = [[UIButton alloc] initWithFrame:CGRectMake(view50.frame.size.width / 2, 0, view50.frame.size.width / 2, view50.frame.size.height)];
        [btn100Minute addTarget:self action:@selector(onOvertime100Minute) forControlEvents:UIControlEventTouchUpInside];
        [view100 addSubview:btn100Minute];
        
        [cell addSubview:viewContainer];
        if (global_screen_size.width < 330)
        {
            [lblTitleOver setFont:[UIFont boldSystemFontOfSize:14.f]];
            [lbl50Title setFont:[UIFont boldSystemFontOfSize:12.f]];
            [lbl100Title setFont:[UIFont boldSystemFontOfSize:12.f]];
        }
        else
        {
            [lblTitleOver setFont:[UIFont boldSystemFontOfSize:16.f]];
            [lbl50Title setFont:[UIFont boldSystemFontOfSize:14.f]];
            [lbl100Title setFont:[UIFont boldSystemFontOfSize:14.f]];
        }
    }
    
    if (indexPah.row == cell_Kilometers)
    {
        UILabel * lbl = [[UILabel alloc] initWithFrame:CGRectMake(leftPadding, 0, 300, cellHeight - 2 * topPadding)];
        [lbl setTextColor:global_nav_color];
        [lbl setText:AMLocalizedString(@"Kilometers", @"Kilometers")];
        UIView * viewContainer = [[UIView alloc] initWithFrame:CGRectMake(leftPadding, lbl.frame.size.height, global_screen_size.width - leftPadding * 2, cellHeight - 2 * topPadding)];
        [viewContainer setBackgroundColor:global_gray_color];
        viewContainer.layer.cornerRadius = 4.f;
        viewContainer.layer.borderWidth = 1.f;
        viewContainer.layer.borderColor = global_darkgray_color.CGColor;
        
        UIButton * btnMinusKm = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, (global_screen_size.width - 3 * leftPadding) / 2 / 6, viewContainer.frame.size.height)];
        [btnMinusKm setBackgroundColor:[UIColor clearColor]];
        [btnMinusKm addTarget:self action:@selector(onKilometerMinus) forControlEvents:UIControlEventTouchUpInside];
        [btnMinusKm setTitleColor:global_nav_color forState:UIControlStateNormal];
        [btnMinusKm setTitle:@"-" forState:UIControlStateNormal];
        
        UIButton * btnKilometers = [[UIButton alloc] initWithFrame:CGRectMake(btnMinusKm.frame.size.width, 0, viewContainer.frame.size.width - 2 * btnMinusKm.frame.size.width, viewContainer.frame.size.height)];
        [btnKilometers setBackgroundColor:[UIColor clearColor]];
        [btnKilometers addTarget:self action:@selector(onKilometer) forControlEvents:UIControlEventTouchUpInside];
        
        [lblKilometers setFrame:btnKilometers.frame];
        [lblKilometers setBackgroundColor:[UIColor whiteColor]];
        [lblKilometers setTextAlignment:NSTextAlignmentCenter];
        [lblKilometers setTextColor:[UIColor grayColor]];
        
        UIButton * btnPlusKm = [[UIButton alloc] initWithFrame:CGRectMake(viewContainer.frame.size.width - btnMinusKm.frame.size.width, 0, btnMinusKm.frame.size.width, btnMinusKm.frame.size.height)];
        [btnPlusKm setBackgroundColor:[UIColor clearColor]];
        [btnPlusKm addTarget:self action:@selector(onKilometerPlus) forControlEvents:UIControlEventTouchUpInside];
        [btnPlusKm setTitleColor:global_nav_color forState:UIControlStateNormal];
        [btnPlusKm setTitle:@"+" forState:UIControlStateNormal];
        
        [viewContainer addSubview:lblKilometers];
        [viewContainer addSubview:btnMinusKm];
        [viewContainer addSubview:btnKilometers];
        [viewContainer addSubview:btnPlusKm];
        [cell addSubview:lbl];
        [cell addSubview:viewContainer];
        
    }
    if (indexPah.row == cell_ExtraWork)
    {
        UIButton * btnAdd = [[UIButton alloc] initWithFrame:CGRectMake(leftPadding, topPadding, global_screen_size.width - 2 * leftPadding, cellHeight - 2 * topPadding)];
        [btnAdd setBackgroundColor:[UIColor clearColor]];
        [btnAdd addTarget:self action:@selector(onAdditionalWork) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel * lblAdd = [[UILabel alloc] initWithFrame:btnAdd.frame];
        [lblAdd setTextColor:[UIColor whiteColor]];
        [lblAdd setText:AMLocalizedString(@"Additional Work", @"Additional Work")];
        [lblAdd setBackgroundColor:global_nav_color];
        lblAdd.layer.cornerRadius = 4.f;
        lblAdd.layer.masksToBounds = YES;
        [lblAdd setTextAlignment:NSTextAlignmentCenter];
        
        if (global_screen_size.width < 330)
        {
            [lblAdd setFont:[UIFont boldSystemFontOfSize:14.f]];
        }
        else
        {
            [lblAdd setFont:[UIFont boldSystemFontOfSize:16.f]];
        }
        
        UIImageView * imgNext = [[UIImageView alloc] initWithFrame:CGRectMake(btnAdd.frame.origin.x + btnAdd.frame.size.width / 2 + [GlobalUtils widthOfString:lblAdd.text withFont:lblAdd.font] / 2 + 6, btnAdd.frame.origin.y + btnAdd.frame.size.height / 4, btnAdd.frame.size.height / 2, btnAdd.frame.size.height / 2)];
        [imgNext setImage:[UIImage imageNamed:@"white_next_arrow"]];
        
        [cell addSubview:lblAdd];
        [cell addSubview:imgNext];
        [cell addSubview:btnAdd];
        
        if (mArayExtraWork && mArayExtraWork.count) {
            CGFloat yCoor = btnAdd.frame.origin.y + btnAdd.frame.size.height + topPadding;
            for (int i = 0; i < mArayExtraWork.count; i ++)
            {
                NSDictionary * dicOne = [mArayExtraWork objectAtIndex:i];
                NSString * strFlag = [dicOne valueForKey:global_key_index];
                UIView * viewContainer = [[UIView alloc] initWithFrame:CGRectMake(btnAdd.frame.origin.x, yCoor, global_screen_size.width - btnAdd.frame.origin.x * 2, cellHeight * 1.3)];
                [viewContainer setBackgroundColor:[UIColor whiteColor]];
                viewContainer.layer.cornerRadius = 3.f;
                viewContainer.layer.borderColor = [UIColor grayColor].CGColor;
                viewContainer.layer.borderWidth = 1.f;
                viewContainer.layer.masksToBounds = YES;
                
                UILabel * lblExTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, viewContainer.frame.size.width - 30, viewContainer.frame.size.height / 2)];
                [lblExTitle setTextColor:global_nav_color];
                if (!strFlag)
                {
                    [lblExTitle setText:[dicOne valueForKey:global_key_service_name]];
                }
                else
                {
                    [lblExTitle setText:[dicOne valueForKey:global_key_notify_service_name]];
                }
                
                UILabel * lblExHour = [[UILabel alloc] initWithFrame:CGRectMake(lblExTitle.frame.origin.x, lblExTitle.frame.size.height, lblExTitle.frame.size.width - 100, lblExTitle.frame.size.height)];
                [lblExHour setTextColor:[UIColor grayColor]];
                if (!strFlag)
                {
                    NSString * sTime = [dicOne valueForKey:global_key_service_time];
                    int hour = sTime.intValue / 60;
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
                    int minute = sTime.intValue - hour * 60;
                    if (minute < 10)
                    {
                        strMinute = [NSString stringWithFormat:@"0%d", minute];
                    }
                    else
                    {
                        strMinute = [NSString stringWithFormat:@"%d", minute];
                    }
                    
                    
                    [lblExHour setText:[NSString stringWithFormat:@"%@ %@ | %@ m", strHour, AMLocalizedString(@"h", nil), strMinute]];
                }
                else
                {
                    [lblExHour setText:[NSString stringWithFormat:@"%@ %@ | %@ m", [dicOne valueForKey:global_key_notify_work_hours], AMLocalizedString(@"h", nil), [dicOne valueForKey:global_key_notify_work_minutes]]];
                }
                UILabel * lblSeeDetails = [[UILabel alloc] initWithFrame:CGRectMake(viewContainer.frame.size.width * 2 / 3, lblExHour.frame.origin.y, 100, lblExHour.frame.size.height)];
                [lblSeeDetails setTextColor:global_green_color];
                [lblSeeDetails setText:AMLocalizedString(@"See Details", @"See Details")];
                
                UIImageView * img = [[UIImageView alloc] initWithFrame:CGRectMake(viewContainer.frame.size.width - 25 - lblSeeDetails.frame.size.height * 2 / 3, lblSeeDetails.frame.origin.y + lblSeeDetails.frame.size.height / 6, lblSeeDetails.frame.size.height * 2 / 3, lblSeeDetails.frame.size.height * 2 / 3)];
                
                [img setImage:[UIImage imageNamed:@"green_next_arrow"]];
                
                [viewContainer addSubview:lblExTitle];
                [viewContainer addSubview:lblExHour];
                [viewContainer addSubview:lblSeeDetails];
                [viewContainer addSubview:img];
                
                UIButton * btnEx = [[UIButton alloc] initWithFrame:viewContainer.frame];
                [btnEx setBackgroundColor:[UIColor clearColor]];
                [btnEx addTarget:self action:@selector(onExtraDetails:) forControlEvents:UIControlEventTouchUpInside];
                btnEx.tag = i;
                [cell addSubview:viewContainer];
                [cell addSubview:btnEx];
                
                yCoor += cellHeight * 1.5;
                if (global_screen_size.width < 330)
                {
                    [lblExTitle setFont:[UIFont boldSystemFontOfSize:13.f]];
                    [lblExHour setFont:[UIFont boldSystemFontOfSize:13.f]];
                    [lblSeeDetails setFont:[UIFont boldSystemFontOfSize:12.f]];
                }
                else
                {
                    [lblSeeDetails setFont:[UIFont boldSystemFontOfSize:14.f]];
                    [lblExTitle setFont:[UIFont boldSystemFontOfSize:15.f]];
                    [lblExHour setFont:[UIFont boldSystemFontOfSize:15.f]];
                }
                UIButton * btnRemove = [[UIButton alloc] initWithFrame:CGRectMake(viewContainer.frame.origin.x + viewContainer.frame.size.width - viewContainer.frame.size.height / 4, viewContainer.frame.origin.y, viewContainer.frame.size.height / 4, viewContainer.frame.size.height / 4)];
                btnRemove.tag = i;
                [btnRemove addTarget:self action:@selector(onExtraRemove:) forControlEvents:UIControlEventTouchUpInside];
                [btnRemove setBackgroundImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
                [cell addSubview:btnRemove];
                
            }
        }
        else
        {
            UIView * viewContainer = [[UIView alloc] initWithFrame:CGRectMake(btnAdd.frame.origin.x, cellHeight, global_screen_size.width - btnAdd.frame.origin.x * 2, cellHeight * 1.3)];
            [viewContainer setBackgroundColor:[UIColor whiteColor]];
            viewContainer.layer.cornerRadius = 3.f;
            viewContainer.layer.borderColor = [UIColor grayColor].CGColor;
            viewContainer.layer.borderWidth = 1.f;
            viewContainer.layer.masksToBounds = YES;
            
            UITextView * txt = [[UITextView alloc] initWithFrame:CGRectMake(8, 4, viewContainer.frame.size.width - 16, viewContainer.frame.size.height - 8)];
            [txt setTextColor:[UIColor grayColor]];
            [txt setText:AMLocalizedString(@"No Extra Work Added", @"No Extra Work Added")];
            [txt setUserInteractionEnabled:NO];
            [viewContainer addSubview:txt];
            [cell addSubview:viewContainer];
            if (global_screen_size.width < 330)
            {
                [txt setFont:[UIFont boldSystemFontOfSize:14.f]];
            }
            else
            {
                [txt setFont:[UIFont boldSystemFontOfSize:16.f]];
            }
        }
    }
    if (indexPah.row == cell_Attachment)
    {
        UILabel * lblAttachment = [[UILabel alloc] initWithFrame:CGRectMake(leftPadding, 0, global_screen_size.width - 2 * leftPadding, cellHeight)];
        [lblAttachment setText:AMLocalizedString(@"Attachment", @"Attachment")];
        [lblAttachment setTextColor:global_nav_color];
        [lblAttachment setBackgroundColor:[UIColor clearColor]];
        [cell addSubview:lblAttachment];
        if (global_screen_size.width < 330)
        {
            [lblAttachment setFont:[UIFont boldSystemFontOfSize:14.f]];
        }
        else
        {
            [lblAttachment setFont:[UIFont boldSystemFontOfSize:16.f]];
        }
        
        CGFloat widthOne = (global_screen_size.width - 2 * lblAttachment.frame.origin.x) / 5 - 8;
        CGFloat coorX = lblAttachment.frame.origin.x + 4;
        CGFloat coorY = lblAttachment.frame.size.height;
        
        for (int i = 0; i < mArayAttachment.count + 1; i ++)
        {
            coorX = lblAttachment.frame.origin.x + 4 + (i % 5) * (widthOne + 8);
            coorY = (i / 5) * (widthOne + 8) + lblAttachment.frame.size.height;
            UIButton * img = [[UIButton alloc] initWithFrame:CGRectMake(coorX, coorY, widthOne, widthOne)];
            img.tag = i;
            if (i == mArayAttachment.count)
            {
                [img setBackgroundColor:global_gray_color];
                img.layer.borderColor = global_darkgray_color.CGColor;
                img.layer.borderWidth = 1.f;
                [img addTarget:self action:@selector(onAttachPlus) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:img];
                [img setTitle:@"+" forState:UIControlStateNormal];
                [img setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
            }
            else
            {
                [img setTitle:nil forState:UIControlStateNormal];

                NSDictionary * dicOne = [mArayAttachment objectAtIndex:i];
                BOOL flag = NO;
                if (dicOne && [dicOne isKindOfClass:[UIImage class]])
                {
                    flag = YES;
                }
                if (!flag)
                {
                    [GlobalUtils setButtonImgForUrlAndSize:img ID:[dicOne valueForKey:global_key_attachment_name] url:[NSString stringWithFormat:@"%@%@", global_url_photo, [dicOne valueForKey:global_key_attachment_name]] size:CGSizeMake(global_screen_size.width, global_screen_size.width) placeImage:@"" storeDir:global_dir_attachment];
                }
                else
                {
                    [img setBackgroundImage:[mArayAttachment objectAtIndex:i] forState:UIControlStateNormal];
                }
                img.tag = i;
                [img addTarget:self action:@selector(onAttachPreview:) forControlEvents:UIControlEventTouchUpInside];
                CGFloat xRemove = CGRectGetMaxX(img.frame) - img.frame.size.width / 3;
                UIButton * btnRemove = [[UIButton alloc] initWithFrame:CGRectMake(xRemove, img.frame.origin.y - img.frame.size.height / 4, img.frame.size.width / 2, img.frame.size.width / 2)];
                [btnRemove setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
                btnRemove.tag = i;
                [btnRemove addTarget:self action:@selector(onAttachRemove:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:img];
                [cell addSubview:btnRemove];
                
            }
            
        }
    }
    if (indexPah.row == cell_Comments)
    {
        UILabel * lblComments = [[UILabel alloc] initWithFrame:CGRectMake(leftPadding, 0, global_screen_size.width - 2 * leftPadding, cellHeight)];
        [lblComments setText:AMLocalizedString(@"Comments", @"Comments")];
        [lblComments setTextColor:global_nav_color];
        [lblComments setBackgroundColor:[UIColor clearColor]];
        [cell addSubview:lblComments];
        [cell addSubview:txtComment];
    }
    if (indexPah.row == cell_SigningHours)
    {
        UIButton * btnSign = [[UIButton alloc] initWithFrame:CGRectMake(leftPadding, topPadding, global_screen_size.width - 2 * leftPadding, cellHeight - 2 * topPadding)];
        [btnSign addTarget:self action:@selector(onSigningHours) forControlEvents:UIControlEventTouchUpInside];
        [btnSign setBackgroundColor:global_nav_color];
        btnSign.layer.cornerRadius = 4.f;
        [btnSign setTitle:AMLocalizedString(@"Signing Hours", @"Signing Hours") forState:UIControlStateNormal];
        [cell addSubview:btnSign];
        if (global_screen_size.width < 330)
        {
            [btnSign.titleLabel setFont:[UIFont boldSystemFontOfSize:14.f]];
        }
        else
        {
            [btnSign.titleLabel setFont:[UIFont boldSystemFontOfSize:16.f]];
        }
    }
    if (indexPah.row == cell_TotalOverTime)
    {
        //        UIView * viewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, topPadding, global_screen_size.width, cellHeight * 6 - 10 * topPadding)];
        UIView * viewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, topPadding, global_screen_size.width, 1000)];
        [viewContainer setBackgroundColor:global_gray_color];
        [cell addSubview:viewContainer];
        
        UILabel * lblTotalOverTime = [[UILabel alloc] initWithFrame:CGRectMake(leftPadding, 0, global_screen_size.width - 2 * leftPadding, cellHeight - 2 * topPadding)];
        [lblTotalOverTime setTextColor:global_nav_color];
        [lblTotalOverTime setText:AMLocalizedString(@"Total overtime", @"Total overtime")];
        
        UILabel * lblTotal;
        
        CGFloat x = lblTotalOverTime.frame.origin.x + 8;
        CGFloat y = lblTotalOverTime.frame.origin.y + lblTotalOverTime.frame.size.height;
        CGFloat h = lblTotalOverTime.frame.size.height;
        if(isworkovertimeautomatic){
            for(int i = 0; i < aryRulesList.count; i++){
                NSDictionary* dicRule = [aryRulesList objectAtIndex:i];
                NSString* strPercent = [dicRule objectForKey:@"rule"];
                UILabel * lblPercent = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 100, h)];
                [lblPercent setTextColor:[UIColor grayColor]];
                NSString *PERCENT = @"%";
                [lblPercent setText:[NSString stringWithFormat:@"%@%@", strPercent, PERCENT]];
                
                UILabel * lblTotalovertime = [[UILabel alloc] initWithFrame:CGRectMake(x, y, global_screen_size.width - 2 * x, h)];
                [lblTotalovertime setTextAlignment:NSTextAlignmentRight];
                [lblTotalovertime setTextColor:global_green_color];
                
                NSString *strMinutes = [dicRule objectForKey:@"minutes"];
                int min = [strMinutes intValue];
                [lblTotalovertime setText:[NSString stringWithFormat:@"%d %@ | %d m", min / 60, AMLocalizedString(@"h", nil), min % 60]];
                
                
                y += h;
                
                [viewContainer addSubview:lblPercent];
                [viewContainer addSubview:lblTotalovertime];
                
                if (global_screen_size.width < 330)
                {
                    [lblPercent setFont:[UIFont boldSystemFontOfSize:14.f]];
                    [lblTotalovertime setFont:[UIFont boldSystemFontOfSize:14.f]];
                    
                }
                else
                {
                    [lblPercent setFont:[UIFont boldSystemFontOfSize:16.f]];
                    [lblTotalovertime setFont:[UIFont boldSystemFontOfSize:16.f]];
                    
                }
            }
            lblTotal = [[UILabel alloc] initWithFrame:CGRectMake(lblTotalOverTime.frame.origin.x, y, lblTotalOverTime.frame.size.width, h)];

        }else{
            UILabel * lbl50 = [[UILabel alloc] initWithFrame:CGRectMake(lblTotalOverTime.frame.origin.x + 8, lblTotalOverTime.frame.origin.y + lblTotalOverTime.frame.size.height, 100, lblTotalOverTime.frame.size.height)];
            [lbl50 setTextColor:[UIColor grayColor]];
            [lbl50 setText:@"50%"];
            
            [lblTotalovertime50 setFrame:CGRectMake(lbl50.frame.origin.x, lbl50.frame.origin.y, global_screen_size.width - 2 * lbl50.frame.origin.x, lbl50.frame.size.height)];
            [lblTotalovertime50 setTextAlignment:NSTextAlignmentRight];
            [lblTotalovertime50 setTextColor:global_green_color];
            
            
            UILabel * lbl100 = [[UILabel alloc] initWithFrame:CGRectMake(lbl50.frame.origin.x, lbl50.frame.origin.y + lbl50.frame.size.height, lbl50.frame.size.width, lbl50.frame.size.height)];
            [lbl100 setTextColor:[UIColor grayColor]];
            [lbl100 setText:@"100%"];
            
            [lblTotalovertime100 setFrame:CGRectMake(lbl100.frame.origin.x, lbl100.frame.origin.y, lblTotalovertime50.frame.size.width, lblTotalovertime50.frame.size.height)];
            [lblTotalovertime100 setTextAlignment:NSTextAlignmentRight];
            [lblTotalovertime100 setTextColor:global_green_color];
            
            
            lblTotal = [[UILabel alloc] initWithFrame:CGRectMake(lblTotalOverTime.frame.origin.x, lblTotalovertime100.frame.size.height + lbl100.frame.origin.y, lblTotalOverTime.frame.size.width, lblTotalOverTime.frame.size.height)];

            [viewContainer addSubview:lbl50];
            [viewContainer addSubview:lbl100];
            [viewContainer addSubview:lblTotalovertime50];
            [viewContainer addSubview:lblTotalovertime100];
            if (global_screen_size.width < 330)
            {
                [lbl50 setFont:[UIFont boldSystemFontOfSize:14.f]];
                [lblTotalovertime50 setFont:[UIFont boldSystemFontOfSize:14.f]];
                [lblTotalovertime100 setFont:[UIFont boldSystemFontOfSize:14.f]];
                [lbl100 setFont:[UIFont boldSystemFontOfSize:14.f]];
            }
            else
            {
                [lbl50 setFont:[UIFont boldSystemFontOfSize:16.f]];
                [lblTotalovertime50 setFont:[UIFont boldSystemFontOfSize:16.f]];
                [lblTotalovertime100 setFont:[UIFont boldSystemFontOfSize:16.f]];
                [lbl100 setFont:[UIFont boldSystemFontOfSize:16.f]];
            }

        }

        [lblTotal setText:AMLocalizedString(@"Total Hours", @"Total Hours")];
        [lblTotal setTextColor:global_nav_color];
        
        UILabel * lblwithout = [[UILabel alloc] initWithFrame:CGRectMake(lblTotal.frame.origin.x + 8, lblTotal.frame.origin.y + lblTotal.frame.size.height, 200, lblTotal.frame.size.height)];
        [lblwithout setTextColor:[UIColor grayColor]];
        [lblwithout setText:AMLocalizedString(@"Without overtime", @"Without overtime")];
        
        [lblTotalHours setFrame:CGRectMake(lblwithout.frame.origin.x, lblwithout.frame.origin.y, global_screen_size.width - 2 * lblwithout.frame.origin.x, lblwithout.frame.size.height)];
        [lblTotalHours setTextColor:global_green_color];
        [lblTotalHours setTextAlignment:NSTextAlignmentRight];
        
        UIView * viewSep = [[UIView alloc] initWithFrame:CGRectMake(0, 0, global_screen_size.width, 1)];
        [viewSep setBackgroundColor:[UIColor grayColor]];
        
        UIButton * btnSave = [[UIButton alloc] initWithFrame:CGRectMake(leftPadding, lblwithout.frame.origin.y + lblwithout.frame.size.height + topPadding, global_screen_size.width - 2 * leftPadding, cellHeight - 2 * topPadding)];
        [btnSave setBackgroundColor:global_nav_color];
        btnSave.layer.cornerRadius = 4.f;
        [btnSave setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

        [btnSave setTitle:AMLocalizedString(@"Save", @"Save") forState:UIControlStateNormal];
        [btnSave addTarget:self action:@selector(onSave) forControlEvents:UIControlEventTouchUpInside];
        [viewContainer addSubview:lblTotalOverTime];
        [viewContainer addSubview:lblTotal];
        [viewContainer addSubview:lblwithout];
        [viewContainer addSubview:lblTotalHours];
        [viewContainer addSubview:viewSep];
        [viewContainer addSubview:btnSave];
        if (global_screen_size.width < 330)
        {
            [lblTotalOverTime setFont:[UIFont boldSystemFontOfSize:14.f]];
//            [lbl50 setFont:[UIFont boldSystemFontOfSize:14.f]];
//            [lblTotalovertime50 setFont:[UIFont boldSystemFontOfSize:14.f]];
//            [lblTotalovertime100 setFont:[UIFont boldSystemFontOfSize:14.f]];
//            [lbl100 setFont:[UIFont boldSystemFontOfSize:14.f]];
            [lblTotal setFont:[UIFont boldSystemFontOfSize:14.f]];
            [lblwithout setFont:[UIFont boldSystemFontOfSize:14.f]];
            [lblTotalHours setFont:[UIFont boldSystemFontOfSize:14.f]];
            [btnSave.titleLabel setFont:[UIFont boldSystemFontOfSize:14.f]];
        }
        else
        {
            [lblTotalOverTime setFont:[UIFont boldSystemFontOfSize:16.f]];
//            [lbl50 setFont:[UIFont boldSystemFontOfSize:16.f]];
//            [lblTotalovertime50 setFont:[UIFont boldSystemFontOfSize:16.f]];
//            [lblTotalovertime100 setFont:[UIFont boldSystemFontOfSize:16.f]];
//            [lbl100 setFont:[UIFont boldSystemFontOfSize:16.f]];
            [lblTotal setFont:[UIFont boldSystemFontOfSize:16.f]];
            [lblwithout setFont:[UIFont boldSystemFontOfSize:16.f]];
            [lblTotalHours setFont:[UIFont boldSystemFontOfSize:16.f]];
            [btnSave.titleLabel setFont:[UIFont boldSystemFontOfSize:16.f]];
        }
    }
    [self setTotalWithout];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSLog(@"yes----Drag");
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [viewProject setFrame:CGRectMake(leftPadding, global_screen_size.width * 2 / 15 + cellHeight + 0.5 - scrollView.contentOffset.y, global_screen_size.width - 2 * leftPadding, btnProjectHeight * mAryFilteredIndex.count)];
    
}


#pragma mark - Utils
- (NSString *)getIPAddress {
    
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}
- (void) initViews {
    NSDate * date = [NSDate date];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    strDateSave = [formatter stringFromDate:date];
    [formatter setDateFormat:@"dd MMM yy"];
    NSString * strDateForm = [formatter stringFromDate:date];
//    [lblTopDate setText:[NSString stringWithFormat:@"Start         %@", strDateForm]];
    [lblTopDate setText:[NSString stringWithFormat:@"%@         %@", AMLocalizedString(@"Date", nil), strDateForm]];

    CGFloat hTextField = cellHeight - 2 * topPadding;
    txtSelectProject = [[UITextField alloc] initWithFrame:CGRectMake(leftPadding, topPadding * 2, global_screen_size.width - 2 * leftPadding, hTextField)];
    if (g_dicProductMaster)
    {
//        NSArray * ary = [g_dicProductMaster valueForKey:global_key_project_details];
//        NSDictionary * dicOne = [ary objectAtIndex:0];
//        NSString * str = [NSString stringWithFormat:@"%@ | %@", [dicOne valueForKey:global_key_project_number], [dicOne valueForKey:global_key_project_name]];
        
        NSString * str = g_strLastWorkedProjectName;//20170828
        [txtSelectProject setText:str];
        strFilter = str;
        mAryFilteredContent = [[NSMutableArray alloc] init];
        [mAryFilteredContent addObject:str];
        mAryFilteredIndex = [[NSMutableArray alloc] init];
        [mAryFilteredIndex addObject:@"0"];
        mArayProjects = [g_dicProductMaster valueForKey:global_key_project_details];

        for (int i = 0; i < mArayProjects.count; i ++) {
            NSDictionary * dicOne = [mArayProjects objectAtIndex:i];
            NSString * str = [NSString stringWithFormat:@"%@ | %@", [dicOne valueForKey:global_key_project_number], [dicOne valueForKey:global_key_project_name]];
            if([str isEqualToString:strFilter])
                selectedProjectIndex = i;
        }

    }
    [txtSelectProject setBackgroundColor:[UIColor clearColor]];
    txtSelectProject.layer.cornerRadius = 4.f;
    txtSelectProject.layer.borderColor = global_darkgray_color.CGColor;
    txtSelectProject.layer.borderWidth = 1.f;
    txtSelectProject.placeholder = AMLocalizedString(@"Select Project", @"Select Project");
    [txtSelectProject setReturnKeyType:UIReturnKeyDone];
    txtSelectProject.delegate = self;
    UIView *padViewProject = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, txtSelectProject.frame.size.height)];
    txtSelectProject.leftView = padViewProject;
    txtSelectProject.leftViewMode = UITextFieldViewModeAlways;
    [txtSelectProject setTextColor:[UIColor grayColor]];
    {
        UIButton *rightView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, hTextField)];
        [rightView addTarget:self action:@selector(clearTextField:) forControlEvents:UIControlEventTouchUpInside];
        btnClearTxtProject = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnClearTxtProject setFrame:CGRectMake(0, (hTextField - 18)/2, 18, 18)];
        [btnClearTxtProject setImage:[UIImage imageNamed:@"circle_close"] forState:UIControlStateNormal];
        [btnClearTxtProject addTarget:self action:@selector(clearTextField:) forControlEvents:UIControlEventTouchUpInside];
        [rightView addSubview:btnClearTxtProject];
        btnClearTxtProject.hidden = YES;
        
        UIButton *btnArrow = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnArrow setFrame:CGRectMake(22, (hTextField - 24)/2, 24, 24)];
        [btnArrow setImage:[UIImage imageNamed:@"gray_down_arrow"] forState:UIControlStateNormal];
        [btnArrow addTarget:self action:@selector(clearTextField:) forControlEvents:UIControlEventTouchUpInside];
        [rightView addSubview:btnArrow];
        txtSelectProject.rightView = rightView;
        txtSelectProject.rightViewMode = UITextFieldViewModeAlways;
    }

    txtSelectBranch = [[UITextField alloc] initWithFrame:CGRectMake(leftPadding, topPadding, global_screen_size.width - 2 * leftPadding, hTextField)];
    [txtSelectBranch setBackgroundColor:[UIColor clearColor]];
    txtSelectBranch.layer.cornerRadius = 4.f;
    txtSelectBranch.layer.borderColor = global_darkgray_color.CGColor;
    txtSelectBranch.layer.borderWidth = 1.f;
    txtSelectBranch.placeholder = AMLocalizedString(@"Select Branch", @"Select Branch");
    [txtSelectBranch setReturnKeyType:UIReturnKeyDone];
    txtSelectBranch.delegate = self;
    UIView *padViewBranch = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, txtSelectBranch.frame.size.height)];
    txtSelectBranch.leftView = padViewBranch;
    txtSelectBranch.leftViewMode = UITextFieldViewModeAlways;
    [txtSelectBranch setTextColor:[UIColor grayColor]];
    
    {
        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, hTextField)];
        UIButton *btnArrow = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnArrow setFrame:CGRectMake(0, (hTextField - 24)/2, 24, 24)];
        [btnArrow setImage:[UIImage imageNamed:@"gray_down_arrow"] forState:UIControlStateNormal];
//        [btnArrow addTarget:self action:@selector(arrowTextField:) forControlEvents:UIControlEventTouchUpInside];
        [rightView addSubview:btnArrow];
        txtSelectBranch.rightView = rightView;
        txtSelectBranch.rightViewMode = UITextFieldViewModeAlways;
    }
    
    txtComment = [[UITextView alloc] initWithFrame:CGRectMake(leftPadding, cellHeight, global_screen_size.width - 2 * leftPadding, global_screen_size.width / 3)];
    [txtComment setBackgroundColor:[UIColor whiteColor]];
    [txtComment setTextColor:global_nav_color];
    txtComment.layer.borderWidth = 1.f;
    txtComment.layer.borderColor = [UIColor grayColor].CGColor;
    txtComment.layer.masksToBounds = YES;
    txtComment.delegate = self;
    
    lblWorkingHoursStart = [[UILabel alloc] init];
    lblWorkingHoursEnd = [[UILabel alloc] init];
    lblBreakTimeHours = [[UILabel alloc] init];
    lblBreakTimeMinutes = [[UILabel alloc] init];
    lblOvertime50Hours = [[UILabel alloc] init];
    lblOvertime50Minutes = [[UILabel alloc] init];
    lblOvertime100Hours = [[UILabel alloc] init];
    lblOvertime100Minutes = [[UILabel alloc] init];
    lblTotalovertime50 = [[UILabel alloc] init];
    lblTotalovertime100 = [[UILabel alloc] init];
    lblTotalHours = [[UILabel alloc] init];
    lblKilometers = [[UILabel alloc] init];
    clockHeight = 22.f;
    
    [lblBreakTimeHours setText:[NSString stringWithFormat:@"00 %@", AMLocalizedString(@"Hrs", nil)]];
    [lblBreakTimeMinutes setText:[NSString stringWithFormat:@"00 %@", AMLocalizedString(@"Min", nil)]];
    [lblOvertime50Hours setText:[NSString stringWithFormat:@"00 %@", AMLocalizedString(@"Hrs", nil)]];
    [lblOvertime50Minutes setText:[NSString stringWithFormat:@"00 %@", AMLocalizedString(@"Min", nil)]];
    [lblOvertime100Hours setText:[NSString stringWithFormat:@"00 %@", AMLocalizedString(@"Hrs", nil)]];
    [lblOvertime100Minutes setText:[NSString stringWithFormat:@"00 %@", AMLocalizedString(@"Min", nil)]];
    [lblKilometers setText:@"00 Km"];
    [lblTotalovertime50 setText:[NSString stringWithFormat:@"00 %@ | 00 m", AMLocalizedString(@"h", nil)]];
    [lblTotalovertime100 setText:[NSString stringWithFormat:@"00 %@ | 00 m", AMLocalizedString(@"h", nil)]];
    [lblTotalHours setText:[NSString stringWithFormat:@"00 %@ | 00 m", AMLocalizedString(@"h", nil)]];
    if (global_screen_size.width < 330)
    {
        clockHeight = 18.f;
        [txtSelectProject setFont:[UIFont boldSystemFontOfSize:14.f]];
        [txtSelectBranch setFont:[UIFont boldSystemFontOfSize:14.f]];
        [lblWorkingHoursStart setFont:[UIFont boldSystemFontOfSize:13.f]];
        [lblWorkingHoursEnd setFont:[UIFont boldSystemFontOfSize:13.f]];
        [lblBreakTimeHours setFont:[UIFont boldSystemFontOfSize:13.f]];
        [lblBreakTimeMinutes setFont:[UIFont boldSystemFontOfSize:13.f]];
        [lblOvertime50Hours setFont:[UIFont boldSystemFontOfSize:13.f]];
        [lblOvertime50Minutes setFont:[UIFont boldSystemFontOfSize:13.f]];
        [lblOvertime100Hours setFont:[UIFont boldSystemFontOfSize:13.f]];
        [lblOvertime100Minutes setFont:[UIFont boldSystemFontOfSize:13.f]];
        [lblKilometers setFont:[UIFont boldSystemFontOfSize:13.f]];
        [lblTotalHours setFont:[UIFont boldSystemFontOfSize:13.f]];
        [lblTotalovertime50 setFont:[UIFont boldSystemFontOfSize:13.f]];
        [lblTotalovertime100 setFont:[UIFont boldSystemFontOfSize:13.f]];
        [txtComment setFont:[UIFont systemFontOfSize:14.f]];
    }
    else
    {
        [txtSelectProject setFont:[UIFont boldSystemFontOfSize:16.f]];
        [txtSelectBranch setFont:[UIFont boldSystemFontOfSize:16.f]];
        [lblWorkingHoursStart setFont:[UIFont boldSystemFontOfSize:15.f]];
        [lblWorkingHoursEnd setFont:[UIFont boldSystemFontOfSize:15.f]];
        [lblBreakTimeHours setFont:[UIFont boldSystemFontOfSize:15.f]];
        [lblBreakTimeMinutes setFont:[UIFont boldSystemFontOfSize:15.f]];
        [lblOvertime50Hours setFont:[UIFont boldSystemFontOfSize:15.f]];
        [lblOvertime50Minutes setFont:[UIFont boldSystemFontOfSize:15.f]];
        [lblOvertime100Hours setFont:[UIFont boldSystemFontOfSize:15.f]];
        [lblOvertime100Minutes setFont:[UIFont boldSystemFontOfSize:15.f]];
        [lblKilometers setFont:[UIFont boldSystemFontOfSize:15.f]];
        [lblTotalHours setFont:[UIFont boldSystemFontOfSize:15.f]];
        [lblTotalovertime50 setFont:[UIFont boldSystemFontOfSize:15.f]];
        [lblTotalovertime100 setFont:[UIFont boldSystemFontOfSize:15.f]];
        [txtComment setFont:[UIFont systemFontOfSize:16.f]];
    }
    
    mPickerStartDate = [[UIDatePicker alloc] init];
    [mPickerStartDate setTintColor:[UIColor clearColor]];
    mPickerStartDate.datePickerMode = UIDatePickerModeDate;
    txtStartDate = [[UITextField alloc] init];
    [txtStartDate setInputView:mPickerStartDate];
    txtStartDate.delegate = self;
    [viewTop addSubview:txtStartDate];
    
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
    [txtStartDate setInputAccessoryView:toolBar];
    
    mPickerStartWorking = [[UIDatePicker alloc] init];
    [mPickerStartWorking setTintColor:[UIColor clearColor]];
    mPickerStartWorking.datePickerMode = UIDatePickerModeTime;
    txtStartWorking = [[UITextField alloc] init];
    [txtStartWorking setInputView:mPickerStartWorking];
    txtStartWorking.delegate = self;
    [viewTop addSubview:txtStartWorking];
    [txtStartWorking setInputAccessoryView:toolBar];
    
    mPickerEndWorking = [[UIDatePicker alloc] init];
    [mPickerEndWorking setTintColor:[UIColor clearColor]];
    mPickerEndWorking.datePickerMode = UIDatePickerModeTime;
    txtEndWorking = [[UITextField alloc] init];
    [txtEndWorking setInputView:mPickerEndWorking];
    txtEndWorking.delegate = self;
    [viewTop addSubview:txtEndWorking];
    [txtEndWorking setInputAccessoryView:toolBar];
    
    mPickerBreakHours = [[UIPickerView alloc] init];
    [mPickerBreakHours setTintColor:[UIColor clearColor]];
    mPickerBreakHours.delegate = self;
    txtBreakHours = [[UITextField alloc] init];
    [txtBreakHours setInputView:mPickerBreakHours];
    txtBreakHours.delegate = self;
    [viewTop addSubview:txtBreakHours];
    [txtBreakHours setInputAccessoryView:toolBar];
    
    mPickerBreakMinutes = [[UIPickerView alloc] init];
    [mPickerBreakMinutes setTintColor:[UIColor clearColor]];
    mPickerBreakMinutes.delegate = self;
    txtBreakMinutes = [[UITextField alloc] init];
    [txtBreakMinutes setInputView:mPickerBreakMinutes];
    txtBreakMinutes.delegate = self;
    [viewTop addSubview:txtBreakMinutes];
    [txtBreakMinutes setInputAccessoryView:toolBar];
    
    mPicker50Hours = [[UIPickerView alloc] init];
    [mPicker50Hours setTintColor:[UIColor clearColor]];
    mPicker50Hours.delegate = self;
    txt50Hours = [[UITextField alloc] init];
    [txt50Hours setInputView:mPicker50Hours];
    txt50Hours.delegate = self;
    [viewTop addSubview:txt50Hours];
    [txt50Hours setInputAccessoryView:toolBar];
    
    mPicker100Hours = [[UIPickerView alloc] init];
    [mPicker100Hours setTintColor:[UIColor clearColor]];
    mPicker100Hours.delegate = self;
    txt100Hours = [[UITextField alloc] init];
    [txt100Hours setInputView:mPicker100Hours];
    txt100Hours.delegate = self;
    [viewTop addSubview:txt100Hours];
    [txt100Hours setInputAccessoryView:toolBar];
    
    mPicker50Minutes = [[UIPickerView alloc] init];
    [mPicker50Minutes setTintColor:[UIColor clearColor]];
    mPicker50Minutes.delegate = self;
    txt50Minutes = [[UITextField alloc] init];
    [txt50Minutes setInputView:mPicker50Minutes];
    txt50Minutes.delegate = self;
    [viewTop addSubview:txt50Minutes];
    [txt50Minutes setInputAccessoryView:toolBar];
    
    mPicker100Minutes = [[UIPickerView alloc] init];
    [mPicker100Minutes setTintColor:[UIColor clearColor]];
    mPicker100Minutes.delegate = self;
    txt100Minutes = [[UITextField alloc] init];
    [txt100Minutes setInputView:mPicker100Minutes];
    txt100Minutes.delegate = self;
    [viewTop addSubview:txt100Minutes];
    [txt100Minutes setInputAccessoryView:toolBar];
    
//    mPickerKm = [[UIPickerView alloc] init];
//    [mPickerKm setTintColor:[UIColor clearColor]];
//    mPickerKm.delegate = self;
    txtKm = [[UITextField alloc] init];
//    [txtKm setInputView:mPickerKm];
    txtKm.delegate = self;
    txtKm.keyboardType = UIKeyboardTypeNumberPad;
    [viewTop addSubview:txtKm];
    [txtKm setInputAccessoryView:toolBar];
    [lblWorkingHoursStart setText:@"7:00"];
    [lblWorkingHoursEnd setText:@"15:00"];
    valueStart = 420;
    valueEnd = 900;
    valueBreakTime = 30;
    value50 = 0;
    value100 = 0;
    [lblBreakTimeMinutes setText:[NSString stringWithFormat:@"30 %@", AMLocalizedString(@"Min", nil)]];
    [self setTotalWithout];
    
    btnPTOBank = [[UIButton alloc] initWithFrame:CGRectMake(leftPadding, topPadding, global_screen_size.width - 2 * leftPadding, hTextField)];
    [btnPTOBank setTitle:AMLocalizedString(@" Add Overtime to PTO Bank", nil) forState:UIControlStateNormal];
    [btnPTOBank setImage:[UIImage imageNamed:@"SelectionMarkOff"] forState:UIControlStateNormal];
    [btnPTOBank setImage:[UIImage imageNamed:@"SelectionMarkOn"] forState:UIControlStateSelected];
    [btnPTOBank addTarget:self action:@selector(onAddPTOBank:) forControlEvents:UIControlEventTouchUpInside];
    [btnPTOBank setTitleColor:global_nav_color forState:UIControlStateNormal];
    btnPTOBank.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btnPTOBank.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    if (global_screen_size.width < 330)
        [btnPTOBank.titleLabel setFont:[UIFont boldSystemFontOfSize:14.f]];
    else
        [btnPTOBank.titleLabel setFont:[UIFont boldSystemFontOfSize:16.f]];
}
-(void)onAddPTOBank:(UIButton*)btn{
    btn.selected = !btn.selected;
}
-(void)clearTextField:(UIButton*)sender
{
    txtSelectProject.text = @"";
    strFilter = @"";
    [self updateProjectsArray];

    [txtSelectProject becomeFirstResponder];
}

- (void) updateProjectsArray {
    mAryFilteredIndex = [[NSMutableArray alloc] init];
    mAryOrg = [[NSMutableArray alloc] init];
    mAryFilteredIndex = [[NSMutableArray alloc] init];
    mAryFilteredContent = [[NSMutableArray alloc] init];
    if (!g_dicProductMaster)
    {
        [self getMasterUpdated];
        return;
    }
    mArayProjects = [g_dicProductMaster valueForKey:global_key_project_details];
    if (!strFilter) strFilter = @"";
//    NSString * pref = strFilter;
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
    viewProject.contentSize = CGSizeMake(viewProject.frame.size.width, btnProjectHeight * mAryFilteredIndex.count);
    NSUInteger nMax = mAryFilteredIndex.count;
    if(nMax > 6)
        nMax = 6;
    [viewProject setFrame:CGRectMake(viewProject.frame.origin.x, viewProject.frame.origin.y, viewProject.frame.size.width, btnProjectHeight * nMax)];
    [viewProject.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    for (int i = 0; i < mAryFilteredIndex.count; i ++)
    {
        UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(leftPadding, i * btnProjectHeight - 1, viewProject.frame.size.width - leftPadding, btnProjectHeight)];
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


- (NSArray*) getHourMinute:(NSString *) strMinuteTotal
{
    int hour = strMinuteTotal.intValue / 60;
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
    int minute = strMinuteTotal.intValue - hour * 60;
    if (minute < 10)
    {
        strMinute = [NSString stringWithFormat:@"0%d", minute];
    }
    else
    {
        strMinute = [NSString stringWithFormat:@"%d", minute];
    }
    NSMutableArray * aryMut = [[NSMutableArray alloc] init];
    [aryMut addObject:strHour];
    [aryMut addObject:strMinute];
    return [NSArray arrayWithArray:aryMut];
}

- (int) getMinutesFromHour:(NSString *) strHour minute:(NSString *) strMinute
{
    return strHour.intValue * 60 + strMinute.intValue;
}

- (int) getMinutesFromHourMinute:(NSString *) strHourMinute
{
    NSArray * ary = [strHourMinute componentsSeparatedByString:@":"];
    NSString * strHour = [ary objectAtIndex:0];
    NSString * strMinute = [ary objectAtIndex:1];
    return strHour.intValue * 60 + strMinute.intValue;
}

- (void) setTotalWithout{
    int value = valueEnd - valueStart - value50 - value100 - valueBreakTime;
    if (value < 0)
    {
        value = 0;
    }
    NSArray * ary = [self getHourMinute:[NSString stringWithFormat:@"%d", value]];
    [lblTotalHours setText:[NSString stringWithFormat:@"%@ %@ | %@ m", [ary objectAtIndex:0], AMLocalizedString(@"h", nil), [ary objectAtIndex:1]]];
    
}

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (textField == txtSelectProject)
    {
        [viewProject setHidden:YES];
    }
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(textField == txtEmail || textField == txtSignature)
        return YES;
    if(textField == txtKm){
        NSString* str = [[textField text] stringByReplacingCharactersInRange:range withString:string];
        valueKm = [str intValue];
        lblKilometers.text = [NSString stringWithFormat:@"%d Km", valueKm];
        return YES;
    }
    if(textField == txtSelectProject)
        strFilter = [[textField text] stringByReplacingCharactersInRange:range withString:string];
    [self updateProjectsArray];
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == txtSelectProject) {
        btnClearTxtProject.hidden = YES;
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    [textField setReturnKeyType:UIReturnKeyDone];
    CGPoint point;
    if (textField == txtSelectProject)
    {
        btnClearTxtProject.hidden = NO;

        [viewProject setHidden:NO];
        [self updateProjectsArray];
    }
    if (textField == txtStartWorking)
    {
        point =  [lblWorkingHoursStart convertPoint:CGPointMake(0, 30) toView:nil];
    }
    else if (textField == txtEndWorking)
    {
        point =  [lblWorkingHoursEnd convertPoint:CGPointMake(0, 30) toView:nil];
    }
    else if (textField == txtBreakMinutes || textField == txtBreakHours)
    {
        point =  [lblBreakTimeHours convertPoint:CGPointMake(0, 30) toView:nil];
    }
    else if (textField == txt50Hours || textField == txt50Minutes)
    {
        point =  [lblOvertime50Hours convertPoint:CGPointMake(0, 30) toView:nil];
    }
    else if (textField == txt100Hours || textField == txt100Minutes)
    {
        point =  [lblOvertime100Hours convertPoint:CGPointMake(0, 30) toView:nil];
    }
    else if (textField == txtKm)
    {
        point =  [lblKilometers convertPoint:CGPointMake(0,0) toView:nil];
        txtKm.text = nil;
    }
    else
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
    [tblView setContentOffset:CGPointMake(tblView.contentOffset.x, tblView.contentOffset.y)];
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
    [txtSelectBranch resignFirstResponder];
    [txtSelectProject resignFirstResponder];
    [txtComment resignFirstResponder];
    [txtStartDate resignFirstResponder];
    [txtStartWorking resignFirstResponder];
    [txtEndWorking resignFirstResponder];
    [txtBreakHours resignFirstResponder];
    [txtBreakMinutes resignFirstResponder];
    [txtKm resignFirstResponder];
    [txt50Hours resignFirstResponder];
    [txt50Minutes resignFirstResponder];
    [txt100Hours resignFirstResponder];
    [txt100Minutes resignFirstResponder];
    [viewProject setHidden:YES];
}

#pragma mark - UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == mPickerBreakHours || pickerView == mPicker50Hours || pickerView == mPicker100Hours)
        return 24;
    if (pickerView == mPicker50Minutes || pickerView == mPicker100Minutes)
        return 60;
    if (pickerView == mPickerBreakMinutes)
        return 13;
    return 200;
}
//- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:  (NSInteger)component {
//    return [NSString stringWithFormat:@"%d",row];
//}
- (CGSize)rowSizeForComponent:(NSInteger)component{
    return CGSizeMake(global_screen_size.width, 44);
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    
    UILabel *label= [[UILabel alloc] initWithFrame:CGRectMake(0, 00, global_screen_size.width, 44.0)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor blackColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    if (global_screen_size.width < 330)
    {
        [label setFont:[UIFont systemFontOfSize:20.0]];
    }
    else
    {
        [label setFont:[UIFont systemFontOfSize:23.0]];
    }
    NSString * strValue;
    if (row < 10)
    {
        strValue = [NSString stringWithFormat:@"0%lu", (long)row];
    }
    else
        strValue = [NSString stringWithFormat:@"%lu", (long)row];
    
    if (pickerView == mPickerBreakHours || pickerView == mPicker50Hours || pickerView == mPicker100Hours)
    {
        [label setText:[NSString stringWithFormat:@"%@ %@", strValue, AMLocalizedString(@"Hrs", nil)]];
    }
    if (pickerView == mPickerBreakMinutes)
    {
        [label setText:[NSString stringWithFormat:@"%lu %@", row * 10, AMLocalizedString(@"Min", nil) ]];
    }
    if (pickerView == mPicker50Minutes || pickerView == mPicker100Minutes)
    {
        [label setText:[NSString stringWithFormat:@"%@ %@", strValue, AMLocalizedString(@"Min", nil)]];
    }
//    if (pickerView == mPickerKm)
//    {
//        [label setText:[NSString stringWithFormat:@"%@ Km", strValue]];
//    }
    return label;
}

#pragma mark - Notification Extra Save
- (void)notifyRefreshExtra:(NSNotification*) noti {
    NSDictionary * dicProgress = (NSDictionary*) noti.object;
    if (dicProgress == NULL || [dicProgress isEqual:[NSNull null]]) {
        return;
    }
    NSString * strIndex = [dicProgress valueForKey:global_key_index];
    if (strIndex.integerValue > mArayExtraWork.count)
    {
        [mArayExtraWork addObject:dicProgress];
    }
    else
    {
        [mArayExtraWork replaceObjectAtIndex:strIndex.integerValue withObject:dicProgress];
    }
    [tblView reloadData];
}
#pragma mark -Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        
        if ([UIImagePickerController isSourceTypeAvailable:
             UIImagePickerControllerSourceTypePhotoLibrary])
        {
            UIImagePickerController *imagePicker =
            [[UIImagePickerController alloc] init];
            
            imagePicker.delegate = self;
            
            imagePicker.sourceType =
            UIImagePickerControllerSourceTypePhotoLibrary;
            
//            imagePicker.allowsEditing = YES;
            [self presentViewController:imagePicker
                               animated:YES completion:nil];
        }
        else{
            [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Library not supported.", @"Library not supported") cancel:AMLocalizedString(@"Ok", @"Ok")];
        }
        
        
        
    }
    else if (buttonIndex == 0)
    {
        
        if ([UIImagePickerController isSourceTypeAvailable:
             UIImagePickerControllerSourceTypeCamera])
        {
            UIImagePickerController *imagePicker =
            [[UIImagePickerController alloc] init];
            
            imagePicker.delegate = self;
            
            imagePicker.sourceType =
            UIImagePickerControllerSourceTypeCamera;
            
//            imagePicker.allowsEditing = YES;
            [self presentViewController:imagePicker
                               animated:YES completion:nil];
        }
        else{
            [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Camera not supported.", @"Camera not supported.") cancel:AMLocalizedString(@"Ok", @"Ok")];
        }
    }
}
-(void)imagePickerController:
(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
//    imagePicked = [info valueForKey:UIImagePickerControllerEditedImage];
    imagePicked = [info valueForKey:UIImagePickerControllerOriginalImage];

    //    btnTemp.contentMode =  UIViewContentModeScaleAspectFit;
    //    [btnTemp setBackgroundImage:imagePicked forState:UIControlStateNormal];
    [mArayAttachment addObject:imagePicked];
    [tblView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)imagePickerControllerDidCancel:
(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (UIImage *)imageWithScaleSize:(UIImage *)image scaledToSize:(CGSize)newSize
{
    if( !image )
        return nil;
    
    UIImage * res = [image resizedImage:newSize interpolationQuality:kCGInterpolationDefault];
    
    if( res == nil ) {
        NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
        res = [[UIImage imageWithData:imageData] resizedImage:newSize interpolationQuality:kCGInterpolationDefault];
    }
    
    if( res == nil )
        res = [self imageWithImage:image scaledToSize:newSize];
    
    if( res == nil )
        res = image;
    
    return res;
}
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
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

@end
