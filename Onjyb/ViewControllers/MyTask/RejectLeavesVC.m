//
//  RejectLeavesVC.m
//  Onjyb
//
//  Created by bold on 9/11/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import "RejectLeavesVC.h"

@interface RejectLeavesVC ()

@end

@implementation RejectLeavesVC
@synthesize dicInfo;


#define cell_RequestedDate                  0
#define cell_LeaveType                      1
#define cell_FromDate                       2
#define cell_ToDate                         3
#define cell_Duration                       4
#define cell_EmployeeNote                   5
#define cell_ManagerNote                    6


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:AMLocalizedString(@"My Task", @"My Task")];
    cellHeight = global_screen_size.height / 15;
    padding = 10;
    [lblTop setTextColor:global_green_color];
    [lblTop setText:AMLocalizedString(@"Absent and Vacation", @"Absent and Vacation")];
    
    tvManagerNote = [[UITextView alloc] initWithFrame:CGRectMake(padding, cellHeight, global_screen_size.width-padding*2, 100)];
    tvManagerNote.layer.cornerRadius = 5;
    tvManagerNote.layer.borderColor = [UIColor grayColor].CGColor;
    tvManagerNote.layer.borderWidth = 1;
    tvManagerNote.layer.masksToBounds = YES;
    tvManagerNote.font = [UIFont systemFontOfSize:14];
    
    CGFloat btnW = (global_screen_size.width - padding * 3) / 2;
    CGFloat btnY = CGRectGetMaxY(tvManagerNote.frame) + padding;
    btnApprove = [[UIButton alloc] initWithFrame:CGRectMake(padding, btnY, btnW, 34)];
    btnApprove.backgroundColor = global_nav_color;
    btnApprove.layer.cornerRadius = 5;
    [btnApprove setTitle:AMLocalizedString(@"Approve", nil) forState:UIControlStateNormal];
    [btnApprove setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnApprove addTarget:self action:@selector(onApprove:) forControlEvents:UIControlEventTouchUpInside];
    
    btnReject = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(btnApprove.frame) + padding, btnY, btnW, 34)];
    btnReject.backgroundColor = global_nav_color;
    btnReject.layer.cornerRadius = 5;
    [btnReject setTitle:AMLocalizedString(@"Reject", nil) forState:UIControlStateNormal];
    [btnReject setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnReject addTarget:self action:@selector(onReject:) forControlEvents:UIControlEventTouchUpInside];

    
    
    
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboards)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
    
    tblView.contentInset = UIEdgeInsetsMake(0, 0, 300, 0);

}
- (void)onApprove:(id)sender{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Are you sure, you want to approve this leave?", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:AMLocalizedString(@"NO", @"NO") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                   {
                                       
                                   }];
    [alert addAction:cancelAction];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:AMLocalizedString(@"YES", @"YES") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                    {
                                        [self onApproveAction:@"approve"];
                                    }];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];

}
- (void)onReject:(id)sender{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Want to reject holiday and absence?", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:AMLocalizedString(@"NO", @"NO") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                   {
                                       
                                   }];
    [alert addAction:cancelAction];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:AMLocalizedString(@"YES", @"YES") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                    {
                                        [self onApproveAction:@"reject"];
                                    }];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];

}
- (void)onApproveAction:(NSString*)state{
    User * user = [GlobalUtils loadUserObjectWithKey:global_user_info_save];
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setObject:user.strUserID forKey:global_key_user_id];
    [param setObject:state forKey:global_key_approve_status];
    NSString* leaveid = [self.dicInfo objectForKey:@"leave_id"];
    [param setObject:leaveid forKey:global_key_leave_id];
    NSString* strNote = tvManagerNote.text;
    if(!strNote)
        [param setObject:@"" forKey:global_key_note];
    else
        [param setObject:strNote forKey:global_key_note];

    
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
                     if([state isEqualToString:@"approve"])
                         [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Leave is approved!", @"Leave is approved!") cancel:AMLocalizedString(@"Ok", @"Ok")];
                     if([state isEqualToString:@"reject"])
                         [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Leave is rejected!", @"Leave is rejected!") cancel:AMLocalizedString(@"Ok", @"Ok")];
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

- (void)dismissKeyboards {
    [tvManagerNote resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Actions
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table View Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
        NSString * strNote = [dicInfo valueForKey:global_key_leave_description];
        if (!strNote || strNote.length == 0)
        {
            strNote = AMLocalizedString(@"No entry found!", @"No entry found!");
        }
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
        commentEmployeeLabelHeight = size.height + 10;
        return commentEmployeeLabelHeight + cellHeight;
    }
    if (indexPath.row == cell_ManagerNote)
    {
//        UIFont * font;
//        if (global_screen_size.width < 330)
//        {
//            font = [UIFont boldSystemFontOfSize:14.f];
//        }
//        else
//        {
//            font = [UIFont boldSystemFontOfSize:16.f];
//        }
//        int maxWidth = global_screen_size.width - 2 * padding;
//        CGSize size;
//        CGRect labelFrame;
//        
//        UILabel * lbl = [[UILabel alloc] initWithFrame:CGRectMake(100, 17, 1, 1)];
//        NSString * strNote = [dicInfo valueForKey:global_key_note];
//        if (!strNote || strNote.length == 0)
//        {
//            strNote = AMLocalizedString(@"No entry found!", @"No entry found!");
//        }
//        [lbl setText:strNote];
//        [lbl setTextColor:[UIColor darkGrayColor]];
//        [lbl setFont:font];
//        lbl.numberOfLines = 0;
//        
//        size = [lbl.text sizeWithFont:lbl.font
//                    constrainedToSize:CGSizeMake(maxWidth, MAXFLOAT)
//                        lineBreakMode:NSLineBreakByWordWrapping];
//        
//        labelFrame = lbl.frame;
//        labelFrame.size.height = size.height;
//        labelFrame.size.width = size.width;
//        lbl.frame = labelFrame;
//        commentManagerLabelHeight = size.height + 10;
//        return commentManagerLabelHeight + cellHeight;
        return CGRectGetMaxY(btnApprove.frame) + padding;
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
    
    if (indexPah.row == cell_RequestedDate)
    {
        [lblTitle setText:AMLocalizedString(@"Requested Date", @"Requested Date")];
        NSString * strDate = [dicInfo valueForKey:global_key_update_date];
        NSString * strDateFormat = strDate;
        if (strDate.length >= 10)
        {
            NSRange rng;
            rng.length = 10; rng.location = 0;
            strDateFormat = [strDate substringWithRange:rng];
        }
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSDate * date = [formatter dateFromString:strDateFormat];
        [formatter setDateFormat:@"dd MMM yy"];
        NSString * str = [formatter stringFromDate:date];
        [lblValue setText:str];
        [cell addSubview:lblTitle];
        [cell addSubview:lblValue];
        [cell addSubview:viewSep];
    }
    if (indexPah.row == cell_LeaveType)
    {
        [lblTitle setText:AMLocalizedString(@"Leave Type", @"Leave Type")];
        [lblValue setText:[dicInfo valueForKey:global_key_leave_type]];
        [cell addSubview:lblTitle];
        [cell addSubview:lblValue];
        [cell addSubview:viewSep];
    }
    if (indexPah.row == cell_FromDate)
    {
        [lblTitle setText:AMLocalizedString(@"From Date", @"From Date")];
        NSString * strDate = [dicInfo valueForKey:global_key_start_date];
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSDate * date = [formatter dateFromString:strDate];
        [formatter setDateFormat:@"dd MMM yy"];
        NSString * str = [formatter stringFromDate:date];
        [lblValue setText:str];
        [cell addSubview:lblTitle];
        [cell addSubview:lblValue];
        [cell addSubview:viewSep];
    }
    if (indexPah.row == cell_ToDate)
    {
        [lblTitle setText:AMLocalizedString(@"To Date", @"To Date")];
        NSString * strDate = [dicInfo valueForKey:global_key_end_date];
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSDate * date = [formatter dateFromString:strDate];
        [formatter setDateFormat:@"dd MMM yy"];
        NSString * str = [formatter stringFromDate:date];
        [lblValue setText:str];
        [cell addSubview:lblTitle];
        [cell addSubview:lblValue];
        [cell addSubview:viewSep];
    }
    if (indexPah.row == cell_Duration)
    {
        [lblTitle setText:AMLocalizedString(@"Duration", @"Duration")];
        
        NSString * strDateStart = [dicInfo valueForKey:global_key_start_date];
        NSString * strDateEnd = [dicInfo valueForKey:global_key_end_date];
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSDate * dateStart = [formatter dateFromString:strDateStart];
        NSDate * dateEnd = [formatter dateFromString:strDateEnd];
        int numberOfDays = [self getWorkDaysFromDate:dateStart toDate:dateEnd];
        [lblValue setText:[NSString stringWithFormat:@"%d %@", numberOfDays, AMLocalizedString(@"Days", @"Days")]];
        [cell addSubview:lblTitle];
        [cell addSubview:lblValue];
        [cell addSubview:viewSep];
    }
    if (indexPah.row == cell_EmployeeNote)
    {
        [lblTitle setText:AMLocalizedString(@"Employee Note", @"Employee Note")];
        NSString * str = [dicInfo valueForKey:global_key_leave_description];
        [lblValue setText:[NSString stringWithFormat:@"%@", str]];
        if (!str || str.length == 0)
        {
            str = AMLocalizedString(@"No entry found!", @"No entry found!");
            if (global_screen_size.width < 330)
            {
                [lblValue setFont:[UIFont italicSystemFontOfSize:14.f]];
            }
            else
            {
                [lblValue setFont:[UIFont italicSystemFontOfSize:16.f]];
            }
            [lblValue setTextColor:global_darkgray_color];
        }
        [lblValue setText:str];
        [lblValue setFrame:CGRectMake(lblTitle.frame.origin.x, lblTitle.frame.size.height, global_screen_size.width - 2 * padding, commentEmployeeLabelHeight)];
        [lblValue setTextAlignment:NSTextAlignmentLeft];
        [lblValue setNumberOfLines:100];
        [viewSep setFrame:CGRectMake(0, cellHeight + commentEmployeeLabelHeight - 1, global_screen_size.width, 1)];
        [cell addSubview:lblTitle];
        [cell addSubview:lblValue];
        [cell addSubview:viewSep];
    }
    if (indexPah.row == cell_ManagerNote)
    {
        [lblTitle setText:AMLocalizedString(@"Manager Note", @"Manager Note")];
//        NSString * str = [dicInfo valueForKey:global_key_note];
//        [lblValue setText:[NSString stringWithFormat:@"%@", str]];
//        if (!str || str.length == 0)
//        {
//            str = AMLocalizedString(@"No entry found!", @"No entry found!");
//            if (global_screen_size.width < 330)
//            {
//                [lblValue setFont:[UIFont italicSystemFontOfSize:14.f]];
//            }
//            else
//            {
//                [lblValue setFont:[UIFont italicSystemFontOfSize:16.f]];
//            }
//            [lblValue setTextColor:global_darkgray_color];
//        }
//        [lblValue setText:str];
//        [lblValue setFrame:CGRectMake(lblTitle.frame.origin.x, lblTitle.frame.size.height, global_screen_size.width - 2 * padding, commentManagerLabelHeight)];
//        [lblValue setTextAlignment:NSTextAlignmentLeft];
//        [lblValue setNumberOfLines:100];
//        [viewSep setFrame:CGRectMake(0, cellHeight + commentManagerLabelHeight - 1, global_screen_size.width, 1)];
        [viewSep setFrame:CGRectMake(0, CGRectGetMaxY(btnApprove.frame) + padding - 1, global_screen_size.width, 1)];
        [cell addSubview:lblTitle];
//        [cell addSubview:lblValue];
        [cell addSubview:viewSep];
        
        [cell addSubview:tvManagerNote];
        [cell addSubview:btnApprove];
        [cell addSubview:btnReject];

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

@end
