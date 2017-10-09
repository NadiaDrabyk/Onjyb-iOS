//
//  ExtraWorkCreateVC.m
//  Onjyb
//
//  Created by Nadia Drabyk on 7/30/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import "ExtraWorkCreateVC.h"
#import "ImagePreviewVC.h"
@interface ExtraWorkCreateVC ()

@end

@implementation ExtraWorkCreateVC
@synthesize indexOfArray, dicInfo;

#define cell_Service                    0
#define cell_WorkingHours               1
#define cell_Attachment                 2
#define cell_EmployeeNote               3
#define cell_Save                       4

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:AMLocalizedString(@"Register Time", @"Register Time")];
    aryServices = [g_dicProductMaster objectForKey:global_key_service_details];
    leftPadding = 16.f;
    topPadding = 10.f;
    cellHeight = global_screen_size.height / 13;
    if (global_screen_size.width < 330)
    {
        leftPadding = 12.f;
        topPadding = 8.f;
        [lblTop setFont:[UIFont boldSystemFontOfSize:14.f]];
    }
    else
    {
        [lblTop setFont:[UIFont boldSystemFontOfSize:16.f]];
    }
    [lblTop setBackgroundColor:global_blue_color];
    [lblTop setText:AMLocalizedString(@"Extra Work", @"Extra Work")];
    mArayAttachment = [[NSMutableArray alloc] init];
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboards)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
    [self initviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    g_dicExtraInfo = nil;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Button Actions
- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) onSave {
    if (txtService.text.length == 0)
    {
        [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Please select service.", @"Please select service.") cancel:AMLocalizedString(@"Ok", @"Ok")];
        return;
    }
    if (txtComment.text.length == 0)
    {
        [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Please input employee note.", @"Please input employee note.") cancel:AMLocalizedString(@"Ok", @"Ok")];
        return;
    }
    NSString *strHrs = [NSString stringWithFormat:@"00 %@", AMLocalizedString(@"Hrs", nil)];
    NSString *strMin = [NSString stringWithFormat:@"00 %@", AMLocalizedString(@"Min", nil)];

    if ([lblWorkingHours.text isEqualToString:strHrs] && [lblWorkingMinutes.text isEqualToString:strMin])
    {
        [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Please select service time.", @"Please select service time.") cancel:AMLocalizedString(@"Ok", @"Ok")];
        return;
    }
    NSMutableDictionary * dicMut = [[NSMutableDictionary alloc] init];
    [dicMut setObject:[NSString stringWithFormat:@"%d", indexOfArray] forKey:global_key_index];
    NSRange rng;
    rng.location = 0;
    rng.length = 2;
    [dicMut setObject:[lblWorkingHours.text substringWithRange:rng] forKey:global_key_notify_work_hours];
    [dicMut setObject:[lblWorkingMinutes.text substringWithRange:rng] forKey:global_key_notify_work_minutes];
    [dicMut setObject:txtComment.text forKey:global_key_notify_comments];
    [dicMut setObject:txtService.text forKey:global_key_notify_service_name];
    [dicMut setObject:mArayAttachment forKey:global_key_notify_images];
    g_dicExtraInfo = [[NSMutableDictionary alloc] init];
    g_dicExtraInfo = [dicMut mutableCopy];
//    [[NSNotificationCenter defaultCenter] postNotificationName:global_notification_extra_save object:dicMut];

    [self.navigationController popViewControllerAnimated:YES];
}

- (void) onDatePickerDone
{
    if ([txtWorkingHours isFirstResponder])
    {
        NSUInteger hour = [mPickerWorkingHours selectedRowInComponent:0];
        NSString * strHour;
        if (hour < 10)
        {
            strHour = [NSString stringWithFormat:@"0%lu", (unsigned long)hour];
        }
        else
        {
            strHour = [NSString stringWithFormat:@"%lu", (unsigned long)hour];
        }
        [lblWorkingHours setText:[NSString stringWithFormat:@"%@ %@", strHour, AMLocalizedString(@"Hrs", nil)]];
    }
    if ([txtWorkingMinutes isFirstResponder])
    {
        NSUInteger minute = [mPickerWorkingMinutes selectedRowInComponent:0];
        NSString * strMinute;
        if (minute < 10)
        {
            strMinute = [NSString stringWithFormat:@"0%lu", (unsigned long)minute];
        }
        else
        {
            strMinute = [NSString stringWithFormat:@"%lu", (unsigned long)minute];
        }
        [lblWorkingMinutes setText:[NSString stringWithFormat:@"%@ %@", strMinute, AMLocalizedString(@"Min", nil)]];
    }

    [self dismissKeyboards];
}
- (void) onWorkingHour
{
    [self dismissKeyboards];
    [txtWorkingHours becomeFirstResponder];
}
- (void) onWorkingMinute {
    [self dismissKeyboards];
    [txtWorkingMinutes becomeFirstResponder];
}

- (void) onAttachPlus
{
    [self dismissKeyboards];
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:AMLocalizedString(@"Profile Image", @"Profile Image") delegate:self cancelButtonTitle:AMLocalizedString(@"Close", @"Close") destructiveButtonTitle:nil otherButtonTitles:
                            AMLocalizedString(@"Take Photo", @"Take Photo") , AMLocalizedString(@"Choose from photos", @"Choose from photos")
                            ,
                            nil];
    [popup showInView:self.view];
}
- (void) onAttachRemove:(UIButton *) btn
{
    [self dismissKeyboards];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Are you sure to remove?", @"Are you sure to remove?") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:AMLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                    {
                                        
                                    }];
    [alert addAction:defaultAction];
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:AMLocalizedString(@"Ok", @"Ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                    {
                                        [mArayAttachment removeObjectAtIndex:btn.tag];
                                        [tblView reloadData];
                                    }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}
- (void) onAttachPreview:(UIButton *) btn
{
    [self dismissKeyboards];
    UIImage * imgPreview = btn.currentBackgroundImage;
    if (!imgPreview) return;
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    ImagePreviewVC * vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"ImagePreviewVC"];
    vc.imgContent = imgPreview;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - TableView Delegate
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == tblServices)
        return aryServices.count;
    return 5;
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == tblServices)
        return 44;
    
    if (indexPath.row == cell_Service)
    {
        return cellHeight * 2 - topPadding;
    }
    if (indexPath.row == cell_WorkingHours)
    {
        return cellHeight * 2.5 - topPadding * 3;
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
    if (indexPath.row == cell_EmployeeNote)
    {
        return cellHeight + txtComment.frame.size.height + topPadding;
    }
    if (indexPath.row == cell_Save)
    {
        return cellHeight;
    }
    return cellHeight;
}
- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == tblServices){
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
        
        NSDictionary * dicService = [aryServices objectAtIndex:indexPath.row];
        NSString * strCell = [dicService objectForKey:global_key_service_name];
        UILabel * lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, cell.frame.size.width - 20, cellHeight)];
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
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"registerTimeDetailCell"];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"registerTimeDetailCell"];
    }
    [cell.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    cell.backgroundColor = [UIColor clearColor];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (indexPath.row == cell_Service)
    {
        UILabel * lbl = [[UILabel alloc] initWithFrame:CGRectMake(leftPadding, topPadding * 2, 200, cellHeight - 2 * topPadding)];
        [lbl setText:AMLocalizedString(@"Service", @"Service")];
        [lbl setTextColor:global_nav_color];
        if (global_screen_size.width < 330)
        {
            [lbl setFont:[UIFont boldSystemFontOfSize:14.f]];
        }
        else
        {
            [lbl setFont:[UIFont boldSystemFontOfSize:16.f]];
        }
        [cell addSubview:lbl];
        [txtService setFrame:CGRectMake(leftPadding, lbl.frame.origin.y + lbl.frame.size.height, global_screen_size.width - 2 * leftPadding, lbl.frame.size.height)];
        [cell addSubview:txtService];
        
//        NSUInteger nServiceNum = aryServices.count;
//        [tblServices setFrame:CGRectMake(leftPadding, CGRectGetMaxY(txtService.frame), global_screen_size.width - 2 * leftPadding, nServiceNum * 44)];
//        [cell addSubview:tblServices];

    }
    if (indexPath.row == cell_WorkingHours)
    {
        UIView * viewContainer = [[UIView alloc] initWithFrame:CGRectMake(leftPadding, topPadding, global_screen_size.width - 2 * leftPadding, cellHeight * 2.5 - 5 * topPadding)];
        viewContainer.layer.cornerRadius = 4.f;
        viewContainer.layer.borderColor = global_darkgray_color.CGColor;
        viewContainer.layer.borderWidth = 1.f;
        [cell addSubview:viewContainer];
        UIView * viewTitleOver = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewContainer.frame.size.width, cellHeight - 2 * topPadding)];
        [viewTitleOver setBackgroundColor:global_gray_color];
        UILabel * lblTitleOver = [[UILabel alloc] initWithFrame:CGRectMake(leftPadding, 0, 300, viewTitleOver.frame.size.height)];
        UIBezierPath *maskPathNF = [UIBezierPath bezierPathWithRoundedRect:viewTitleOver.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(4.0, 4.0)];
        CAShapeLayer *maskLayerNF = [[CAShapeLayer alloc] init];
        maskLayerNF.frame = self.view.bounds;
        maskLayerNF.path  = maskPathNF.CGPath;
        viewTitleOver.layer.mask = maskLayerNF;
        [lblTitleOver setText:AMLocalizedString(@"Select Working Hours", @"Select Working Hours")];
        [lblTitleOver setTextColor:global_nav_color];
        [viewTitleOver addSubview:lblTitleOver];
        [viewContainer addSubview:viewTitleOver];
        
        UIView * viewSub = [[UIView alloc] initWithFrame:CGRectMake(0, lblTitleOver.frame.size.height, viewContainer.frame.size.width, lblTitleOver.frame.size.height * 1.5)];
        viewSub.layer.borderWidth = 1.f;
        viewSub.layer.borderColor = global_darkgray_color.CGColor;
        [viewContainer addSubview:viewSub];
        [lblWorkingHours setFrame:CGRectMake(leftPadding, 0, 200, (cellHeight - 2 * topPadding) * 1.5)];
        [lblWorkingHours setTextColor:[UIColor grayColor]];
        [viewSub addSubview:lblWorkingHours];
        UIView * viewSep = [[UIView alloc] initWithFrame:CGRectMake(viewSub.frame.size.width / 2 - 0.5, lblWorkingHours.frame.origin.y + lblWorkingHours.frame.size.height / 5, 1, lblWorkingHours.frame.size.height * 3 / 5)];
        [viewSep setBackgroundColor:global_darkgray_color];
        [viewSub addSubview:viewSep];
        
        UIImageView * imgHour = [[UIImageView alloc] initWithFrame:CGRectMake(viewSep.frame.origin.x - 8 - clockHeight, lblWorkingHours.frame.origin.y + lblWorkingHours.frame.size.height / 2 - clockHeight / 2, clockHeight, clockHeight)];
        [imgHour setImage:[UIImage imageNamed:@"clock"]];
        [viewSub addSubview:imgHour];
        
        UIButton *btnHour = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, viewSub.frame.size.width / 2, viewSub.frame.size.height)];
        [btnHour addTarget:self action:@selector(onWorkingHour) forControlEvents:UIControlEventTouchUpInside];
        [viewSub addSubview:btnHour];
        
        
        [lblWorkingMinutes setFrame:CGRectMake(leftPadding + viewSub.frame.size.width / 2, 0, 200, lblWorkingHours.frame.size.height)];
        [lblWorkingMinutes setTextColor:[UIColor grayColor]];
        [viewSub addSubview:lblWorkingMinutes];
        
        UIImageView * imgminute = [[UIImageView alloc] initWithFrame:CGRectMake(viewSep.frame.origin.x - 8 - clockHeight + viewSub.frame.size.width / 2, lblWorkingHours.frame.origin.y + lblWorkingHours.frame.size.height / 2 - clockHeight / 2, clockHeight, clockHeight)];
        [imgminute setImage:[UIImage imageNamed:@"clock"]];
        [viewSub addSubview:imgminute];
        
        UIButton *btnMinute = [[UIButton alloc] initWithFrame:CGRectMake(viewSub.frame.size.width / 2, 0, viewSub.frame.size.width / 2, viewSub.frame.size.height)];
        [btnMinute addTarget:self action:@selector(onWorkingMinute) forControlEvents:UIControlEventTouchUpInside];
        [viewSub addSubview:btnMinute];
        
        if (global_screen_size.width < 330)
        {
            [lblTitleOver setFont:[UIFont boldSystemFontOfSize:14.f]];
        }
        else
        {
            [lblTitleOver setFont:[UIFont boldSystemFontOfSize:16.f]];
        }

    }
    if (indexPath.row == cell_Attachment)
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

//                NSDictionary * dicOne = [mArayAttachment objectAtIndex:i];
//                [GlobalUtils setButtonImgForUrlAndSize:img ID:[dicOne valueForKey:global_key_attachment_name] url:[NSString stringWithFormat:@"%@%@", global_url_photo, [dicOne valueForKey:global_key_attachment_name]] size:CGSizeMake(global_screen_size.width, global_screen_size.width) placeImage:@"" storeDir:global_dir_attachment];
                [img setBackgroundImage:[mArayAttachment objectAtIndex:i] forState:UIControlStateNormal];
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
    if (indexPath.row == cell_EmployeeNote)
    {
        UILabel * lblComments = [[UILabel alloc] initWithFrame:CGRectMake(leftPadding, 0, global_screen_size.width - 2 * leftPadding, cellHeight)];
        [lblComments setText:AMLocalizedString(@"Employee Note", @"Employee Note")];
        [lblComments setTextColor:global_nav_color];
        [lblComments setBackgroundColor:[UIColor clearColor]];
        [cell addSubview:lblComments];
        [cell addSubview:txtComment];
    }
    if (indexPath.row == cell_Save)
    {
        UIButton * btnSave = [[UIButton alloc] initWithFrame:CGRectMake(leftPadding, topPadding, global_screen_size.width - 2 * leftPadding, cellHeight - 2 * topPadding)];
        [btnSave setBackgroundColor:global_nav_color];
        [btnSave setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnSave setTitle:AMLocalizedString(@"Save", @"Save") forState:UIControlStateNormal];
        btnSave.layer.cornerRadius = 4.f;
        btnSave.layer.masksToBounds = YES;
        [btnSave addTarget:self action:@selector(onSave) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:btnSave];
    }

    return cell;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == tblServices){
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        NSDictionary * dicService = [aryServices objectAtIndex:indexPath.row];
        NSString * strCell = [dicService objectForKey:global_key_service_name];
        txtService.text = strCell;
        tblServices.hidden = YES;
//        tapGesture.delegate = self;
        [self.view addGestureRecognizer:tapGesture];

    }

}

#pragma mark - Utils

- (void) initviews {
    CGFloat hTextField = cellHeight - 2 * topPadding;
    txtService = [[UITextField alloc] initWithFrame:CGRectMake(leftPadding, topPadding, global_screen_size.width - 2 * leftPadding, hTextField)];
    [txtService setBackgroundColor:[UIColor clearColor]];
    txtService.layer.cornerRadius = 4.f;
    txtService.layer.borderColor = global_darkgray_color.CGColor;
    txtService.layer.borderWidth = 1.f;
    txtService.placeholder = AMLocalizedString(@"Select Service", @"Select Service");
    [txtService setReturnKeyType:UIReturnKeyDone];
    txtService.delegate = self;
    UIView *padView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, txtService.frame.size.height)];
    txtService.leftView = padView;
    txtService.leftViewMode = UITextFieldViewModeAlways;
    [txtService setTextColor:[UIColor grayColor]];
    {
        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, hTextField)];
        btnClearTxtService = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnClearTxtService setFrame:CGRectMake(0, (hTextField - 14)/2, 14, 14)];
        [btnClearTxtService setImage:[UIImage imageNamed:@"circle_close"] forState:UIControlStateNormal];
        [btnClearTxtService addTarget:self action:@selector(clearTextField:) forControlEvents:UIControlEventTouchUpInside];
        [rightView addSubview:btnClearTxtService];
        btnClearTxtService.hidden = YES;
        
        UIButton *btnArrow = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnArrow setFrame:CGRectMake(18, (hTextField - 24)/2, 24, 24)];
        [btnArrow setImage:[UIImage imageNamed:@"gray_down_arrow"] forState:UIControlStateNormal];
//        [btnArrow addTarget:self action:@selector(arrowTextField:) forControlEvents:UIControlEventTouchUpInside];
        [rightView addSubview:btnArrow];
        txtService.rightView = rightView;
        txtService.rightViewMode = UITextFieldViewModeAlways;

    }

    tblServices = [[UITableView alloc] initWithFrame:CGRectZero];
    tblServices.delegate = self;
    tblServices.dataSource = self;
    tblServices.layer.cornerRadius = 3.f;
    tblServices.layer.borderColor = global_darkgray_color.CGColor;
    tblServices.layer.borderWidth = 1.f;
    tblServices.layer.masksToBounds = YES;
    [tblServices setBackgroundColor:[UIColor whiteColor]];
    [tblServices setHidden:YES];
    [self.view bringSubviewToFront:tblServices];
    NSUInteger nServiceNum = aryServices.count;
    
    CGFloat y = topPadding * 2 + (cellHeight - 2 * topPadding) * 2;
    [tblServices setFrame:CGRectMake(leftPadding, y + tblView.frame.origin.y + 2, global_screen_size.width - 2 * leftPadding, nServiceNum * 44)];
    [self.view addSubview:tblServices];

    
    txtComment = [[UITextView alloc] initWithFrame:CGRectMake(leftPadding, cellHeight, global_screen_size.width - 2 * leftPadding, global_screen_size.width / 3)];
    [txtComment setBackgroundColor:[UIColor whiteColor]];
    [txtComment setTextColor:global_nav_color];
    txtComment.layer.borderWidth = 1.f;
    txtComment.layer.borderColor = [UIColor grayColor].CGColor;
    txtComment.layer.masksToBounds = YES;
    txtComment.delegate = self;
    
    lblWorkingHours = [[UILabel alloc] init];
    lblWorkingMinutes = [[UILabel alloc] init];
    clockHeight = 22.f;
    
    [lblWorkingHours setText:[NSString stringWithFormat:@"00 %@", AMLocalizedString(@"Hrs", nil)]];
    [lblWorkingMinutes setText:[NSString stringWithFormat:@"00 %@", AMLocalizedString(@"Min", nil)]];

    if (global_screen_size.width < 330)
    {
        clockHeight = 18.f;
        [lblWorkingHours setFont:[UIFont boldSystemFontOfSize:13.f]];
        [lblWorkingMinutes setFont:[UIFont boldSystemFontOfSize:13.f]];
        [txtComment setFont:[UIFont systemFontOfSize:14.f]];
        [txtService setFont:[UIFont boldSystemFontOfSize:14.f]];
    }
    else
    {
        [lblWorkingHours setFont:[UIFont boldSystemFontOfSize:15.f]];
        [lblWorkingMinutes setFont:[UIFont boldSystemFontOfSize:15.f]];
        [txtComment setFont:[UIFont systemFontOfSize:16.f]];
        [txtService setFont:[UIFont boldSystemFontOfSize:16.f]];
    }
    
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
    
    mPickerWorkingHours = [[UIPickerView alloc] init];
    [mPickerWorkingHours setTintColor:[UIColor clearColor]];
    mPickerWorkingHours.delegate = self;
    txtWorkingHours = [[UITextField alloc] init];
    [txtWorkingHours setInputView:mPickerWorkingHours];
    txtWorkingHours.delegate = self;
    [self.view addSubview:txtWorkingHours];
    [txtWorkingHours setInputAccessoryView:toolBar];
    
    mPickerWorkingMinutes = [[UIPickerView alloc] init];
    [mPickerWorkingMinutes setTintColor:[UIColor clearColor]];
    mPickerWorkingMinutes.delegate = self;
    txtWorkingMinutes = [[UITextField alloc] init];
    [txtWorkingMinutes setInputView:mPickerWorkingMinutes];
    txtWorkingMinutes.delegate = self;
    [self.view addSubview:txtWorkingMinutes];
    [txtWorkingMinutes setInputAccessoryView:toolBar];
    if (dicInfo)
    {
        NSString * strIndex = [dicInfo valueForKey:global_key_index];
        if (strIndex)
        {
            NSArray * ary = [dicInfo valueForKey:global_key_notify_images];
            mArayAttachment = [ary mutableCopy];
            [txtService setText:[dicInfo valueForKey:global_key_notify_service_name]];
            [lblWorkingHours setText:[NSString stringWithFormat:@"%@ %@",[dicInfo valueForKey:global_key_notify_work_hours], AMLocalizedString(@"Hrs", nil)]];
            [lblWorkingMinutes setText:[NSString stringWithFormat:@"%@ %@",[dicInfo valueForKey:global_key_notify_work_minutes], AMLocalizedString(@"Min", nil)]];
            [txtComment setText:[dicInfo valueForKey:global_key_notify_comments]];
            [tblView reloadData];
        }
    }

}
-(void)clearTextField:(UIButton*)sender
{
    txtService.text = @"";
    strFilter = @"";

    [self updateTableServices];
    [self.view bringSubviewToFront:tblServices];
    tblServices.hidden = NO;
    [txtService becomeFirstResponder];
}
#pragma mark - TapGesture
- (void) dismissKeyboards {
    [txtService resignFirstResponder];
    [txtComment resignFirstResponder];
    [txtWorkingMinutes resignFirstResponder];
    [txtWorkingHours resignFirstResponder];
}
#pragma mark - TextField Delegate
- (void)updateTableServices{
    if(!strFilter || strFilter.length == 0)
        aryServices = [g_dicProductMaster objectForKey:global_key_service_details];
    else{
        NSArray* ary = [g_dicProductMaster objectForKey:global_key_service_details];
        aryServices = [[NSMutableArray alloc] init];
        for(NSDictionary *dic in ary){
            NSString *str = [dic objectForKey:global_key_service_name];
            str = [str lowercaseString];
            if([str containsString:[strFilter lowercaseString]]){
                [aryServices addObject:dic];
            }
        }
    }

    NSUInteger nServiceNum = aryServices.count;
    if(nServiceNum > 6)
        nServiceNum = 6;
    CGFloat y = topPadding * 2 + (cellHeight - 2 * topPadding) * 2;
    [tblServices setFrame:CGRectMake(leftPadding, y + tblView.frame.origin.y + 2, global_screen_size.width - 2 * leftPadding, nServiceNum * 44)];
    
    [tblServices reloadData];

}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    strFilter = [[textField text] stringByReplacingCharactersInRange:range withString:string];
    [self updateTableServices];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    tblServices.hidden = YES;
    if (textField == txtService) {
        btnClearTxtService.hidden = YES;
    }
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    [textField setReturnKeyType:UIReturnKeyDone];
    CGPoint point;
    if (textField == txtService){
//        tapGesture.delegate = nil;
        tblServices.hidden = NO;
        strFilter = textField.text;
        [self updateTableServices];
        btnClearTxtService.hidden = NO;

        [self.view removeGestureRecognizer:tapGesture];
        return YES;
    }
    
    if (textField == txtWorkingHours)
    {
        point =  [lblWorkingHours convertPoint:CGPointMake(0, 30) toView:nil];
    }
    else if (textField == txtWorkingMinutes)
    {
        point =  [txtWorkingMinutes convertPoint:CGPointMake(0, 30) toView:nil];
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
    [tblView setContentOffset:CGPointMake(0, 0)];
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
}

#pragma mark - UITextView Delegate
- (BOOL) textViewShouldBeginEditing:(UITextView *)textView {
    
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

#pragma mark - UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == mPickerWorkingHours)
        return 24;
    if (pickerView == mPickerWorkingMinutes)
        return 60;
    return 0;
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
    
    if (pickerView == mPickerWorkingHours)
    {
        [label setText:[NSString stringWithFormat:@"%@ %@", strValue, AMLocalizedString(@"Hrs", nil)]];
    }
    if (pickerView == mPickerWorkingMinutes)
    {
        [label setText:[NSString stringWithFormat:@"%@ %@", strValue, AMLocalizedString(@"Min", nil)]];
    }
    return label;
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
    imagePicked = [info valueForKey:UIImagePickerControllerOriginalImage];
    btnTemp.contentMode =  UIViewContentModeScaleAspectFit;
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


@end
