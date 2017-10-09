//
//  ExtraWorkDetailsVC.m
//  Onjyb
//
//  Created by Nadia Drabyk on 7/27/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import "ExtraWorkDetailsVC.h"
#import "ImagePreviewVC.h"

@interface ExtraWorkDetailsVC ()

@end

@implementation ExtraWorkDetailsVC

@synthesize dicInfo;

#define cell_Service                    0
#define cell_WorkingTime                1
#define cell_EmployeeNote               2
#define cell_Attachment                 3

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:AMLocalizedString(@"Extra Work", @"Extra Work")];
    
    cellHeight = global_screen_size.height / 15;
    mArrImage = [[NSMutableArray alloc] init];
    NSArray * ary = [dicInfo valueForKey:global_key_extra_images];
    if (ary && ary.count)
        mArrImage = [ary mutableCopy];
    padding = 10.f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Actions
-(IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)onPreview:(UIButton *) img {
    UIImage * imgPreview = img.currentBackgroundImage;
    if (!imgPreview) return;
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    ImagePreviewVC * vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"ImagePreviewVC"];
    vc.imgContent = imgPreview;
    [self presentViewController:vc animated:YES completion:nil];
}


#pragma mark - Table View Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
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
        NSString * strNote = [dicInfo valueForKey:global_key_service_comment];
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
    
    CGFloat widthOne = (global_screen_size.width - 2 * padding) / 5 - 8;
    if (indexPath.row == cell_Attachment)
    {
        int num;
        if (mArrImage.count % 5 == 0) num = (int) (mArrImage.count / 5);
        else num = (int) (mArrImage.count / 5) + 1;
        if (mArrImage && mArrImage.count) {
            return cellHeight * 2 + (widthOne + 8) * num;
        }
        return cellHeight * 3.2;
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
    
    if (indexPah.row == cell_Service)
    {
        [lblTitle setText:AMLocalizedString(@"Service", @"Service")];
        [lblValue setText:[dicInfo valueForKey:global_key_service_name]];
        [cell addSubview:lblTitle];
        [cell addSubview:lblValue];
        [cell addSubview:viewSep];
    }
    if (indexPah.row == cell_WorkingTime)
    {
        [lblTitle setText:AMLocalizedString(@"Working Time", @"Working Time")];
        NSString * sTime = [dicInfo valueForKey:global_key_service_time];
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
        
        [lblValue setText:[NSString stringWithFormat:@"%@:%@ %@", strHour, strMinute, AMLocalizedString(@"Hrs", nil)]];

        [cell addSubview:lblTitle];
        [cell addSubview:lblValue];
        [cell addSubview:viewSep];
    }
    if (indexPah.row == cell_EmployeeNote)
    {
        [lblTitle setText:AMLocalizedString(@"Employee Note", @"Employee Note")];
        [lblValue setText:[NSString stringWithFormat:@"%@", [dicInfo valueForKey:global_key_service_comment]]];
        [lblValue setFrame:CGRectMake(lblTitle.frame.origin.x, lblTitle.frame.size.height, global_screen_size.width - 2 * padding, commentLabelHeight)];
        [lblValue setTextAlignment:NSTextAlignmentLeft];
        [lblValue setNumberOfLines:100];
        [viewSep setFrame:CGRectMake(0, cellHeight + commentLabelHeight - 1, global_screen_size.width, 1)];
        [cell addSubview:lblTitle];
        [cell addSubview:lblValue];
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
        }
        else
        {
            [lblValue setText:AMLocalizedString(@"Images Not Added", @"Images Not Added")];
            [lblValue setFrame:CGRectMake(lblTitle.frame.origin.x, lblTitle.frame.size.height, lblTitle.frame.size.width, lblTitle.frame.size.height)];
            [lblValue setTextAlignment:NSTextAlignmentLeft];
            [cell addSubview:lblValue];
        }
        [cell addSubview:lblTitle];
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


@end
