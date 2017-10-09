//
//  LeaveDetailsVC.m
//  Onjyb
//
//  Created by Nadia Drabyk on 7/19/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import "LeaveDetailsVC.h"

@interface LeaveDetailsVC ()

@end

@implementation LeaveDetailsVC
@synthesize dicInfo;


#define cell_RequestedDate                  0
#define cell_LeaveType                      1
#define cell_FromDate                       2
#define cell_ToDate                         3
#define cell_Duration                       4
#define cell_PTOHours                       5
#define cell_EmployeeNote                   6
#define cell_ManagerNote                    7

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:AMLocalizedString(@"My Task", @"My Task")];
    cellHeight = global_screen_size.height / 15;
    padding = 10;
    [lblTop setTextColor:global_green_color];
    
    NSString *strApproveStatus = [dicInfo valueForKey:global_key_approve_status];
    if ([strApproveStatus isEqualToString:global_value_approve])
    {
        [lblTop setText:AMLocalizedString(@"Approved Leave", @"Approved Leave")];
    }
    else if ([strApproveStatus isEqualToString:global_value_reject])
    {
        [lblTop setText:AMLocalizedString(@"Rejected Leave", @"Rejected Leave")];
        
    }
    else if ([strApproveStatus isEqualToString:global_value_pendding])
    {
        [lblTop setText:AMLocalizedString(@"Pendding Leave", @"Pendding Leave")];
    }
    else
    {
        [lblTop setText:AMLocalizedString(@"Cancelled Leave", @"Cancelled Leave")];
    }

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
    return 8;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* masterType = [self.dicInfo objectForKey:@"leave_master_type"];
    if(![masterType isEqualToString:@"ptobank"] && indexPath.row == cell_PTOHours)
        return 0;
    
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
        NSString * strNote = [dicInfo valueForKey:global_key_note];
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
        commentManagerLabelHeight = size.height + 10;
        return commentManagerLabelHeight + cellHeight;
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
    if (indexPah.row == cell_PTOHours)
    {
        [lblTitle setText:AMLocalizedString(@"Total Hours", nil)];
        
//        NSString * total_hours = [dicInfo valueForKey:@"total_hours"];//120
        NSString * time_hours = [dicInfo valueForKey:@"time_hours"];//02:00
        [lblValue setText:time_hours];
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
        NSString * str = [dicInfo valueForKey:global_key_note];
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
        [lblValue setFrame:CGRectMake(lblTitle.frame.origin.x, lblTitle.frame.size.height, global_screen_size.width - 2 * padding, commentManagerLabelHeight)];
        [lblValue setTextAlignment:NSTextAlignmentLeft];
        [lblValue setNumberOfLines:100];
        [viewSep setFrame:CGRectMake(0, cellHeight + commentManagerLabelHeight - 1, global_screen_size.width, 1)];
        [cell addSubview:lblTitle];
        [cell addSubview:lblValue];
        [cell addSubview:viewSep];
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
