//
//  RejectVC.m
//  Onjyb
//
//  Created by Nadia Drabyk on 8/5/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import "RejectVC.h"
#import "ImagePreviewVC.h"
#import "ExtraWorkDetailsVC.h"

@interface RejectVC ()

@end

@implementation RejectVC

@synthesize dicInfo;

#define cell_Project                    0
#define cell_Branch                     1
#define cell_Approvaldate               2
#define cell_WorkingTime                3
#define cell_OverTime                   4
#define cell_BreakTime                  5
#define cell_TotalHours                 6
#define cell_Kilometers                 7
#define cell_EmployeeNote               8
#define cell_ExtraWork                  9
#define cell_Attachment                 10
#define cell_RejectComment              11

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:AMLocalizedString(@"My Task", @"My Task")];
    [lblTop setTextColor:global_green_color];
    [lblTopDate setTextColor:global_nav_color];
    if (global_screen_size.width < 330)
    {
        [lblTopDate setFont:[UIFont boldSystemFontOfSize:14.f]];
        [lblTop setFont:[UIFont boldSystemFontOfSize:14.f]];
    }
    else
    {
        [lblTopDate setFont:[UIFont boldSystemFontOfSize:16.f]];
        [lblTop setFont:[UIFont boldSystemFontOfSize:16.f]];
    }
    [lblTop setText:AMLocalizedString(@"Completed Tasks", @"Completed Tasks")];
    [lblTopDate setText:@""];
    cellHeight = global_screen_size.height / 15;
    padding = 10;
    flagRefresh = 1;
    
    NSString * strDateTmp = [dicInfo valueForKey:global_key_work_date];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate * date = [formatter dateFromString:strDateTmp];
    [formatter setDateFormat:@"dd MMM yy"];
    NSString * strDate = [formatter stringFromDate:date];
    [lblTopDate setText:strDate];
    
    txtRejectComment = [[UITextView alloc] initWithFrame:CGRectMake(padding, cellHeight, global_screen_size.width - 2 * padding, global_screen_size.width / 4)];
    [txtRejectComment setBackgroundColor:[UIColor whiteColor]];
    [txtRejectComment setTextColor:global_nav_color];
    txtRejectComment.layer.cornerRadius = 4.f;
    txtRejectComment.layer.borderColor = [UIColor grayColor].CGColor;
    txtRejectComment.layer.borderWidth = 1.f;
    txtRejectComment.layer.masksToBounds = YES;
    txtRejectComment.delegate = self;
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboards)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
    [self getTaskDetails];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
}
- (void) viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Button Actions
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) onReject {
    AppDelegate * app = (AppDelegate*) [UIApplication sharedApplication].delegate;
    [app showHUD];
    
    NSString * strWorkID = [dicInfo valueForKey:global_key_id];
    User * user = [GlobalUtils loadUserObjectWithKey:global_user_info_save];
    NSString * strReason = txtRejectComment.text;
    if (!strReason) strReason = @"";
    
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setObject:strWorkID forKey:global_key_work_id];
    [param setObject:user.strUserID forKey:global_key_user_id];
    [param setObject:strReason forKey:global_key_reason];
    [param setObject:global_value_reject forKey:global_key_approve_status];
    [param setObject:@"ios" forKey:global_key_os];
    //////////
    [MyRequest POST:global_api_rejectTask parameters:param completed:^(id result)
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
                     NSString * errorString;
                     errorString = [NSString stringWithFormat:@"%@", [dicResult valueForKey:global_key_res_message]];
                     UIAlertController *alert = [UIAlertController alertControllerWithTitle:AMLocalizedString(@"Onjyb", @"Onjyb") message:errorString preferredStyle:UIAlertControllerStyleAlert];
                     UIAlertAction* okAction = [UIAlertAction actionWithTitle:AMLocalizedString(@"Ok", @"Ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                                {
                                                    [self.navigationController popViewControllerAnimated:YES];
                                                }];
                     [alert addAction:okAction];
                     [self presentViewController:alert animated:YES completion:nil];
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

             return;
         }
     }];

}

- (void)onPreview:(UIButton *) img {
    UIImage * imgPreview = img.currentBackgroundImage;
    if (!imgPreview) return;
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    ImagePreviewVC * vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"ImagePreviewVC"];
    vc.imgContent = imgPreview;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)onExtraDetail:(UIButton *) btn {
    NSLog(@"Extra:   %lu\n", (long)btn.tag);
    NSDictionary * dicOne = [mAryExtraWork objectAtIndex:btn.tag];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    ExtraWorkDetailsVC * vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"ExtraWorkDetailsVC"];
    vc.dicInfo = [dicOne mutableCopy];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - Table View Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (flagRefresh == 1)
        return 0;
    return 12;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == cell_OverTime)
        return cellHeight * 2.4;
    if (indexPath.row == cell_EmployeeNote)
    {
        UIFont * font;
        if (global_screen_size.width < 330)
        {
            font = [UIFont boldSystemFontOfSize:14.f];
        }
        else
        {
            font = [UIFont boldSystemFontOfSize:16.f];
        }
        int maxWidth = global_screen_size.width - 2 * padding;
        CGSize size;
        CGRect labelFrame;
        
        UILabel * lbl = [[UILabel alloc] initWithFrame:CGRectMake(100, 17, 1, 1)];
        NSString * strNote = [mDicWorkSheet valueForKey:global_key_comments];
        [lbl setText:strNote];
        [lbl setTextColor:[UIColor darkGrayColor]];
        [lbl setFont:font];
        lbl.numberOfLines = 0;
        
        size = [lbl.text sizeWithFont:lbl.font
                    constrainedToSize:CGSizeMake(maxWidth, MAXFLOAT)
                        lineBreakMode:NSLineBreakByWordWrapping];
        
        labelFrame = lbl.frame;
        labelFrame.size.height = size.height;
        labelFrame.size.width = size.width;
        lbl.frame = labelFrame;
        commentLabelHeight = size.height + 10;
        return commentLabelHeight + cellHeight;
    }
    
    if (indexPath.row == cell_ExtraWork)
    {
        if (mAryExtraWork && mAryExtraWork.count)
            return (1.5 * mAryExtraWork.count + 1) * cellHeight;
        return cellHeight * 2.5;
    }
    
    CGFloat widthOne = (global_screen_size.width - 2 * padding) / 5 - 8;
    if (indexPath.row == cell_Attachment)
    {
        int num;
        if (mArrImage.count % 5 == 0) num = (int) (mArrImage.count / 5);
        else num = (int) (mArrImage.count / 5) + 1;
        if (mArrImage && mArrImage.count) {
            return cellHeight + (widthOne + 8) * num;
        }
        return cellHeight * 2;
    }
    if (indexPath.row == cell_RejectComment)
    {
        return txtRejectComment.frame.size.height + cellHeight * 2 + cellHeight * 2 / 3;
    }
    
    return cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPah
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"completedTaskDetailCell"];
    
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"completedTaskDetailCell"];
    }
    [cell.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    
    UIView * viewSep = [[UIView alloc] initWithFrame:CGRectMake(0, cellHeight - 1, global_screen_size.width, 1)];
    [viewSep setBackgroundColor:global_gray_color];
    cell.backgroundColor = [UIColor clearColor];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(padding, 0, 300, cellHeight)];
    [lblTitle setTextColor:global_nav_color];
    
    UILabel * lblValue = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, global_screen_size.width - padding, cellHeight)];
    [lblValue setTextColor:[UIColor grayColor]];
    [lblValue setTextAlignment:NSTextAlignmentRight];
    
    if (indexPah.row == cell_Project)
    {
        [lblTitle setText:AMLocalizedString(@"Project", @"Project")];
        [lblValue setText:[NSString stringWithFormat:@"%@ | %@", [dicInfo valueForKey:global_key_project_number], [dicInfo valueForKey:global_key_project_name]]];
        [cell addSubview:lblTitle];
        [cell addSubview:lblValue];
        [cell addSubview:viewSep];
    }
    if (indexPah.row == cell_Branch)
    {
        [lblTitle setText:AMLocalizedString(@"Branch", @"Branch")];
        [lblValue setText:AMLocalizedString(@"Not avaliable", @"Not avaliable")];
        [cell addSubview:lblTitle];
        [cell addSubview:lblValue];
        [cell addSubview:viewSep];
    }
    if (indexPah.row == cell_Branch)
    {
        [lblTitle setText:AMLocalizedString(@"Branch", @"Branch")];
        [lblValue setText:AMLocalizedString(@"Not avaliable", @"Not avaliable")];
        [cell addSubview:lblTitle];
        [cell addSubview:lblValue];
        [cell addSubview:viewSep];
    }
    if (indexPah.row == cell_Approvaldate)
    {
        [lblTitle setText:AMLocalizedString(@"Approval date", @"Approval date")];
        
        NSString * strDateApp = [mDicWorkSheet valueForKey:global_key_update_date];
        NSRange rng;
        rng.length = 10;
        rng.location = 0;
        NSString * strDateTmp = [NSString stringWithString:strDateApp];
        if (strDateApp.length >= 10)
            strDateTmp = [strDateApp substringWithRange:rng];
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSDate * date = [formatter dateFromString:strDateTmp];
        [formatter setDateFormat:@"dd MMM yy"];
        NSString * strDate = [formatter stringFromDate:date];
        [lblValue setText:strDate];
        [cell addSubview:lblTitle];
        [cell addSubview:lblValue];
        [cell addSubview:viewSep];
    }
    if (indexPah.row == cell_WorkingTime)
    {
        [lblTitle setText:AMLocalizedString(@"Working Time", @"Working Time")];
        NSString * strStartTime = [mDicWorkSheet valueForKey:global_key_work_start_time];
        NSString * strEndTime = [mDicWorkSheet valueForKey:global_key_work_end_time];
        NSRange rng;
        rng.length = 5; rng.location = 0;
        [lblValue setText:[NSString stringWithFormat:@"%@ - %@ %@", [strStartTime substringWithRange:rng], [strEndTime substringWithRange:rng], AMLocalizedString(@"Hrs", nil)]];
        [cell addSubview:lblTitle];
        [cell addSubview:lblValue];
        [cell addSubview:viewSep];
    }
    if (indexPah.row == cell_OverTime)
    {
        [lblTitle setText:AMLocalizedString(@"Over time", @"Over time")];
        UILabel * lbl50 = [[UILabel alloc] initWithFrame:CGRectMake(lblTitle.frame.origin.x * 2, lblTitle.frame.size.height, 100, lblTitle.frame.size.height * 0.7)];
        [lbl50 setText:@"50 %"];
        [lbl50 setTextColor:global_nav_color];
        UILabel * lbl50Value = [[UILabel alloc] initWithFrame:CGRectMake(0, lbl50.frame.origin.y, global_screen_size.width - padding, lbl50.frame.size.height)];
        [lbl50Value setTextColor:[UIColor grayColor]];
        NSString * strValueWorkTime = [mDicWorkSheet valueForKey:global_key_work_overtime2];
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
        
        [lbl50Value setText:[NSString stringWithFormat:@"%@ h | %@ m", strHour, strMinute]];
        
        strValueWorkTime = [mDicWorkSheet valueForKey:global_key_work_overtime1];
        hour = strValueWorkTime.intValue / 60;
        if (hour < 10)
        {
            strHour = [NSString stringWithFormat:@"0%d", hour];
        }
        else
        {
            strHour = [NSString stringWithFormat:@"%d", hour];
        }
        minute = strValueWorkTime.intValue - hour * 60;
        if (minute < 10)
        {
            strMinute = [NSString stringWithFormat:@"0%d", minute];
        }
        else
        {
            strMinute = [NSString stringWithFormat:@"%d", minute];
        }
        UILabel * lbl100 = [[UILabel alloc] initWithFrame:CGRectMake(lbl50.frame.origin.x, lbl50.frame.origin.y + lbl50.frame.size.height, lbl50.frame.size.width, lbl50.frame.size.height)];
        [lbl100 setText:@"100 %"];
        [lbl100 setTextColor:global_nav_color];
        
        UILabel * lbl100Value = [[UILabel alloc] initWithFrame:CGRectMake(lbl50Value.frame.origin.x, lbl50Value.frame.origin.y + lbl50Value.frame.size.height, lbl50Value.frame.size.width, lbl50Value.frame.size.height)];
        [lbl100Value setTextColor:[UIColor grayColor]];
        [lbl100Value setText:[NSString stringWithFormat:@"%@ h | %@ m", strHour, strMinute]];
        
        [cell addSubview:lblTitle];
        [cell addSubview:lbl50];
        [cell addSubview:lbl50Value];
        [cell addSubview:lbl100];
        [cell addSubview:lbl100Value];
        [lbl50Value setTextAlignment:NSTextAlignmentRight];
        [lbl100Value setTextAlignment:NSTextAlignmentRight];
        if (global_screen_size.width < 330)
        {
            [lbl50 setFont:[UIFont boldSystemFontOfSize:14.f]];
            [lbl50Value setFont:[UIFont boldSystemFontOfSize:14.f]];
            [lbl100 setFont:[UIFont boldSystemFontOfSize:14.f]];
            [lbl100Value setFont:[UIFont boldSystemFontOfSize:14.f]];
        }
        else
        {
            [lbl50 setFont:[UIFont boldSystemFontOfSize:16.f]];
            [lbl50Value setFont:[UIFont boldSystemFontOfSize:16.f]];
            [lbl100 setFont:[UIFont boldSystemFontOfSize:16.f]];
            [lbl100Value setFont:[UIFont boldSystemFontOfSize:16.f]];
        }
        [viewSep setFrame:CGRectMake(0, cellHeight * 2.4 - 1, global_screen_size.width, 1)];
        [cell addSubview:viewSep];
    }
    if (indexPah.row == cell_BreakTime)
    {
        [lblTitle setText:AMLocalizedString(@"Break Time", @"Break Time")];
        [lblValue setText:[NSString stringWithFormat:@"%@ %@", [mDicWorkSheet valueForKey:global_key_break_time], AMLocalizedString(@"Min", nil)]];
        [cell addSubview:lblTitle];
        [cell addSubview:lblValue];
        [cell addSubview:viewSep];
    }
    if (indexPah.row == cell_TotalHours)
    {
        [lblTitle setText:AMLocalizedString(@"Total Hours", @"Total Hours")];
        NSString * strValueWorkTime = [mDicWorkSheet valueForKey:global_key_total_work_time];
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
        
        [lblValue setText:[NSString stringWithFormat:@"%@ %@ %@ %@", strHour, AMLocalizedString(@"Hrs", nil), strMinute, AMLocalizedString(@"Min", nil)]];
        [cell addSubview:lblTitle];
        [cell addSubview:lblValue];
        [cell addSubview:viewSep];
    }
    if (indexPah.row == cell_Kilometers)
    {
        [lblTitle setText:AMLocalizedString(@"Kilometers", @"Kilometers")];
        [lblValue setText:[NSString stringWithFormat:@"%@ Km", [mDicWorkSheet valueForKey:global_key_km_drive]]];
        [cell addSubview:lblTitle];
        [cell addSubview:lblValue];
        [cell addSubview:viewSep];
    }
    if (indexPah.row == cell_EmployeeNote)
    {
        [lblTitle setText:AMLocalizedString(@"Employee Note", @"Employee Note")];
        [lblValue setText:[NSString stringWithFormat:@"%@", [mDicWorkSheet valueForKey:global_key_comments]]];
        [lblValue setFrame:CGRectMake(lblTitle.frame.origin.x, lblTitle.frame.size.height, global_screen_size.width - 2 * padding, commentLabelHeight)];
        [lblValue setTextAlignment:NSTextAlignmentLeft];
        [lblValue setNumberOfLines:100];
        [viewSep setFrame:CGRectMake(0, cellHeight + commentLabelHeight - 1, global_screen_size.width, 1)];
        [cell addSubview:lblTitle];
        [cell addSubview:lblValue];
        [cell addSubview:viewSep];
    }
    if (indexPah.row == cell_ExtraWork)
    {
        [lblTitle setText:AMLocalizedString(@"Extra Work", @"Extra Work")];
        if (mAryExtraWork && mAryExtraWork.count) {
            CGFloat yCoor = lblTitle.frame.size.height;
            for (int i = 0; i < mAryExtraWork.count; i ++)
            {
                NSDictionary * dicOne = [mAryExtraWork objectAtIndex:i];
                UIView * viewContainer = [[UIView alloc] initWithFrame:CGRectMake(lblTitle.frame.origin.x, yCoor, global_screen_size.width - lblTitle.frame.origin.x * 2, lblTitle.frame.size.height * 1.3)];
                [viewContainer setBackgroundColor:[UIColor whiteColor]];
                viewContainer.layer.cornerRadius = 3.f;
                viewContainer.layer.borderColor = [UIColor grayColor].CGColor;
                viewContainer.layer.borderWidth = 1.f;
                viewContainer.layer.masksToBounds = YES;
                
                UILabel * lblExTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, viewContainer.frame.size.width - 30, viewContainer.frame.size.height / 2)];
                [lblExTitle setTextColor:global_nav_color];
                [lblExTitle setText:[dicOne valueForKey:global_key_service_name]];
                
                UILabel * lblExHour = [[UILabel alloc] initWithFrame:CGRectMake(lblExTitle.frame.origin.x, lblExTitle.frame.size.height, lblExTitle.frame.size.width - 100, lblExTitle.frame.size.height)];
                [lblExHour setTextColor:[UIColor grayColor]];
                
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
                
                
                [lblExHour setText:[NSString stringWithFormat:@"%@ h | %@ m", strHour, strMinute]];
                
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
                [btnEx addTarget:self action:@selector(onExtraDetail:) forControlEvents:UIControlEventTouchUpInside];
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
            }
            [viewSep setFrame:CGRectMake(0, (mAryExtraWork.count * 1.5 + 1) * cellHeight - 1, global_screen_size.width, 1)];
        }
        else
        {
            UIView * viewContainer = [[UIView alloc] initWithFrame:CGRectMake(lblTitle.frame.origin.x, lblTitle.frame.size.height, global_screen_size.width - lblTitle.frame.origin.x * 2, lblTitle.frame.size.height * 1.3)];
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
            [viewSep setFrame:CGRectMake(0, cellHeight * 2.5 - 1, global_screen_size.width, 1)];
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
        [cell addSubview:lblTitle];
        [cell addSubview:viewSep];
    }
    if (indexPah.row == cell_Attachment)
    {
        [lblTitle setText:AMLocalizedString(@"Attachment", @"Attachment")];
        if (mArrImage && mArrImage.count)
        {
            CGFloat widthOne = (global_screen_size.width - 2 * lblTitle.frame.origin.x) / 5 - 8;
            CGFloat coorX = lblTitle.frame.origin.x + 4;
            CGFloat coorY = lblTitle.frame.size.height;
            
            for (int i = 0; i < mArrImage.count; i ++)
            {
                coorX = lblTitle.frame.origin.x + 4 + (i % 5) * (widthOne + 8);
                coorY = (i / 5) * (widthOne + 8) + lblTitle.frame.size.height;
                NSDictionary * dicOne = [mArrImage objectAtIndex:i];
                UIButton * img = [[UIButton alloc] initWithFrame:CGRectMake(coorX, coorY, widthOne, widthOne)];
                [GlobalUtils setButtonImgForUrlAndSize:img ID:[dicOne valueForKey:global_key_attachment_name] url:[NSString stringWithFormat:@"%@%@", global_url_photo, [dicOne valueForKey:global_key_attachment_name]] size:CGSizeMake(global_screen_size.width, global_screen_size.width) placeImage:@"" storeDir:global_dir_attachment];
                img.tag = i;
                [img addTarget:self action:@selector(onPreview:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:img];
            }
            int num;
            if (mArrImage.count % 5 == 0) num = (int) (mArrImage.count / 5);
            else num = (int) (mArrImage.count / 5) + 1;
            [viewSep setFrame:CGRectMake(0, cellHeight + (widthOne + 8) * num, global_screen_size.width, 1)];
            [cell addSubview:viewSep];
        }
        else
        {
            [lblValue setText:AMLocalizedString(@"Images Not Added", @"Images Not Added")];
            [lblValue setFrame:CGRectMake(lblTitle.frame.origin.x, lblTitle.frame.size.height, lblTitle.frame.size.width, lblTitle.frame.size.height)];
            [lblValue setTextAlignment:NSTextAlignmentLeft];
            [viewSep setFrame:CGRectMake(0, cellHeight * 2 - 1, global_screen_size.width, 1)];
            [cell addSubview:viewSep];
            [cell addSubview:lblValue];
        }
        [cell addSubview:lblTitle];
    }
    
    if (indexPah.row == cell_RejectComment)
    {
        [lblTitle setText:AMLocalizedString(@"Reject Comments", @"Reject Comments")];
        UIButton * btnReject = [[UIButton alloc] initWithFrame:CGRectMake(padding, txtRejectComment.frame.origin.y + txtRejectComment.frame.size.height + cellHeight / 2, global_screen_size.width - 2 * padding, cellHeight * 2 / 3)];
        
        [btnReject addTarget:self action:@selector(onReject) forControlEvents:UIControlEventTouchUpInside];
        [btnReject setBackgroundColor:global_nav_color];
        [btnReject setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnReject setTitle:AMLocalizedString(@"Reject", @"Reject") forState:UIControlStateNormal];
        btnReject.layer.cornerRadius = 4.f;
        btnReject.layer.masksToBounds = YES;
        [cell addSubview:lblTitle];
        [cell addSubview:txtRejectComment];
        [cell addSubview:btnReject];
        if (global_screen_size.width < 330)
        {
            [txtRejectComment setFont:[UIFont boldSystemFontOfSize:14.f]];
            [btnReject.titleLabel setFont:[UIFont boldSystemFontOfSize:14.f]];
        }
        else
        {
            [txtRejectComment setFont:[UIFont boldSystemFontOfSize:16.f]];
            [btnReject.titleLabel setFont:[UIFont boldSystemFontOfSize:16.f]];
        }
    }
    
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
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Utils
- (void) getTaskDetails{
    
    mDicWorkSheet = [[NSMutableDictionary alloc] init];
    mArrImage = [[NSMutableArray alloc] init];
    mAryExtraWork = [[NSMutableArray alloc] init];
    
    AppDelegate * app = (AppDelegate*) [UIApplication sharedApplication].delegate;
    [app showHUD];
    
    NSString * strWorkID = [dicInfo valueForKey:global_key_id];
    
    
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setObject:strWorkID forKey:global_key_work_id];
    [param setObject:@"" forKey:global_key_last_date];
    
    //////////
    [MyRequest POST:global_api_getMyTaskDetails parameters:param completed:^(id result)
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
                         
                         NSArray * ary = [dicResObject valueForKey:global_key_worksheet_details];
                         if (ary && ary.count)
                         {
                             flagRefresh = 0;
                             NSDictionary * dicOne = [ary objectAtIndex:0];
                             mDicWorkSheet = [dicOne mutableCopy];
                             [tblView reloadData];
                         }
                         NSArray * aryImage = [dicResObject valueForKey:global_key_workimage_details];
                         if (aryImage && aryImage.count)
                         {
                             mArrImage = [aryImage mutableCopy];
                         }
                         NSArray * aryExtra = [dicResObject valueForKey:global_key_extraservice_details];
                         if (aryExtra && aryExtra.count)
                         {
                             mAryExtraWork = [aryExtra mutableCopy];
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

#pragma mark -TapGesture
- (void) dismissKeyboards
{
    [txtRejectComment resignFirstResponder];
}

#pragma mark - TextViewDelegate
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
    if (tblView.contentOffset.y - offsetAnimation > 0)
    {
        [tblView setContentOffset:CGPointMake(tblView.contentOffset.x, tblView.contentOffset.y - offsetAnimation)];
    }
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
}


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


@end
