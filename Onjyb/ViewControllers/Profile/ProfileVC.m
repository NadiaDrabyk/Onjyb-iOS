//
//  ProfileVC.m
//  Onjyb
//
//  Created by Nadia Drabyk on 7/20/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import "ProfileVC.h"

@interface ProfileVC ()

@end

@implementation ProfileVC

#define cell_photo_name     0
#define cell_name           1
#define cell_email          2
#define cell_mobile         3
#define cell_address        4
#define cell_update         5
#define cell_password       6

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:AMLocalizedString(@"Profile", @"Profile")];
    
    [tblView setBackgroundColor:global_nav_color];
    
    dimView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, global_screen_size.width, global_screen_size.height)];
    [dimView setBackgroundColor:[UIColor blackColor]];
    [dimView setAlpha:0.6];
    [self.view addSubview:dimView];
    
    cellHeight = global_screen_size.height / 14;
    
    user = [GlobalUtils loadUserObjectWithKey:global_user_info_save];
    
    [self initViews];
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboards)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
    [self getProfile];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    
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
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
}

- (void)onUpdate {
    
    [self dismissKeyboards];
    
    if (txtName.text.length == 0)
    {
        [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Please input name.", @"Please input name.") cancel:AMLocalizedString(@"Ok", @"Ok")];
        return;
    }
    if (txtMobileContent.text.length == 0)
    {
        [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Please input mobile.", @"Please input mobile.") cancel:AMLocalizedString(@"Ok", @"Ok")];
        return;
    }
    NSLog(@"%@", txtAddress.text);
    if (txtAddress.text.length == 0)
    {
        [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Please input address.", @"Please input address.") cancel:AMLocalizedString(@"Ok", @"Ok")];
        return;
    }
    
    NSArray * splitName = [txtName.text componentsSeparatedByString:@" "];
    if (splitName.count < 2)
    {
        [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Please input valid name.", @"Please input valid name.") cancel:AMLocalizedString(@"Ok", @"Ok")];
        return;
    }
    
    AppDelegate * app = (AppDelegate*) [UIApplication sharedApplication].delegate;
//    [app showHUD];
    
    //Edit Profile API
    
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setObject:user.strUserID forKey:global_key_user_id];
    [param setObject:txtMobileContent.text forKey:global_key_mobile_number];
    [param setObject:[splitName objectAtIndex:0] forKey:global_key_first_name];

    
    [param setObject:[splitName objectAtIndex:1] forKey:global_key_last_name];
    [param setObject:txtAddress.text forKey:global_key_address];
    NSString * strDateUnix = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
    NSArray * aryUnix = [strDateUnix componentsSeparatedByString:@"."];
    NSString * strNamePhoto = [NSString stringWithFormat:@"%@_%@%d.jpg", [aryUnix objectAtIndex:0], [aryUnix objectAtIndex:1], (int)(arc4random() % 100)];
    //////////
    [MyRequest POST:global_api_editProfile parameters:param imagePicked:imgProfile.image strParamPhoto:global_key_user_photo strNamePhoto:strNamePhoto  completed:^(id result)
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
                     NSArray * ary = [dicResult valueForKey:global_key_res_object];
                     if (ary)
                     {
                         NSDictionary * dicOne = [ary objectAtIndex:0];
                         if ([dicOne valueForKey:global_key_profile_image]) {
                             user.strURLProfile = [dicOne valueForKey:global_key_profile_image];
                         }
                         if ([dicOne valueForKey:global_key_profile_image]) {
                             user.strURLProfile = [dicOne valueForKey:global_key_profile_image];
                         }
                         if ([dicOne valueForKey:global_key_first_name]) {
                             user.strFirstName = [dicOne valueForKey:global_key_first_name];
                         }
                         if ([dicOne valueForKey:global_key_last_name]) {
                             user.strLastName = [dicOne valueForKey:global_key_last_name];
                         }
                         if ([dicOne valueForKey:global_key_email]) {
                             user.strEmail = [dicOne valueForKey:global_key_email];
                         }
                         if ([dicOne valueForKey:global_key_mobile]) {
                             user.strMobile = [dicOne valueForKey:global_key_mobile];
                         }
                         if ([dicOne valueForKey:global_key_address]) {
                             user.strAddress = [dicOne valueForKey:global_key_address];
                         }
                         [GlobalUtils saveUserObject:user key:global_user_info_save];
                         [tblView reloadData];
                         [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Information is updated!", nil) cancel:AMLocalizedString(@"Ok", @"Ok")];

                         return;

                     }
                     [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Unknown Error", @"Unknown Error") cancel:AMLocalizedString(@"Ok", @"Ok")];
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

- (void)onChangePassword {
    [self dismissKeyboards];
    if (txtOldPwd.text.length == 0)
    {
        [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Please input old password.", @"Please input old password.") cancel:AMLocalizedString(@"Ok", @"Ok")];
        return;
    }
    if (txtNewPwd.text.length == 0)
    {
        [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Please input new password.", @"Please input new password.") cancel:AMLocalizedString(@"Ok", @"Ok")];
        return;
    }
    if (![txtNewPwd.text isEqualToString:txtConfirmPwd.text])
    {
        [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"New password doesn't match.", @"New password doesn't match.") cancel:AMLocalizedString(@"Ok", @"Ok")];
        return;
    }
    
    AppDelegate * app = (AppDelegate*) [UIApplication sharedApplication].delegate;
    [app showHUD];
    
    //Change Password API
    
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setObject:user.strUserID forKey:global_key_user_id];
    [param setObject:txtOldPwd.text forKey:global_key_old_password];
    [param setObject:txtNewPwd.text forKey:global_key_new_password];
    [param setObject:txtConfirmPwd.text forKey:global_key_confirm_password];
    
    //////////
    [MyRequest POST:global_api_changePassword parameters:param completed:^(id result)
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
                     NSDictionary * dicResObject = [dicResult valueForKey:global_key_res_object];
                     if (dicResObject)
                     {
                         NSString * msg = [NSString stringWithFormat:@"%@", [dicResult valueForKey:global_key_res_message]];
                         [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:msg cancel:AMLocalizedString(@"Ok", @"Ok")];
                         return;
                     }
                     [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Unknown Error", @"Unknown Error") cancel:AMLocalizedString(@"Ok", @"Ok")];
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

- (void)onProfile {
    [self dismissKeyboards];
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:AMLocalizedString(@"Profile Image", @"Profile Image") delegate:self cancelButtonTitle:AMLocalizedString(@"Close", @"Close") destructiveButtonTitle:nil otherButtonTitles:
                            AMLocalizedString(@"Take Photo", @"Take Photo") , AMLocalizedString(@"Choose from photos", @"Choose from photos")
                            ,
                            nil];
    [popup showInView:self.view];
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
    return 7;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == cell_photo_name)
    {
        return global_screen_size.width / 2 - 20 - cellHeight;
    }
    if (indexPath.row == cell_password)
    {
        return global_screen_size.width / 2 + 30;
    }
    return cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPah
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"leftMenuCell"];
    
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"leftMenuCell"];
    }
    [cell.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    if (indexPah.row == cell_photo_name)
    {

        UIButton * btnProfile = [[UIButton alloc] initWithFrame:imgProfile.frame];
        [btnProfile setBackgroundColor:[UIColor clearColor]];
        btnProfile.layer.cornerRadius = btnProfile.frame.size.width / 2;
        btnProfile.layer.masksToBounds = YES;
        [btnProfile addTarget:self action:@selector(onProfile) forControlEvents:UIControlEventTouchUpInside];
        
        [cell addSubview:imgProfile];
        [cell addSubview:btnProfile];
    }
    if (indexPah.row == cell_name) {
        UILabel * lblEmail = [[UILabel alloc] initWithFrame:CGRectMake(22, 0, 80, cellHeight)];
        [lblEmail setTextAlignment:NSTextAlignmentLeft];
        [lblEmail setText:[NSString stringWithFormat:@"%@:",AMLocalizedString(@"Name", @"Name")]];
        [lblEmail setTextColor:[UIColor whiteColor]];
        
        [cell addSubview:lblEmail];
        
        if (global_screen_size.width < 330)
            [txtName setFont:[UIFont boldSystemFontOfSize:14.f]];
        else
            [txtName setFont:[UIFont boldSystemFontOfSize:16.f]];
        [cell addSubview:txtName];

        UIView * viewSep = [[UIView alloc] initWithFrame:CGRectMake(22, cellHeight - 1, global_screen_size.width - 34, 1)];
        [viewSep setBackgroundColor:[UIColor colorWithRed:244/255.f green:244/255.f blue:244/255.f alpha:1.f]];
        [cell addSubview:viewSep];
    }
    if (indexPah.row == cell_email) {
        UILabel * lblEmail = [[UILabel alloc] initWithFrame:CGRectMake(22, 0, 80, cellHeight)];
        [lblEmail setTextAlignment:NSTextAlignmentLeft];
        [lblEmail setText:[NSString stringWithFormat:@"%@:",AMLocalizedString(@"E-mail", @"E-mail")]];
        [lblEmail setTextColor:[UIColor whiteColor]];
        
        [cell addSubview:lblEmail];
        
        UILabel * lblEmailContent = [[UILabel alloc] initWithFrame:CGRectMake(lblEmail.frame.origin.x + lblEmail.frame.size.width + 10, 0, global_screen_size.width - lblEmail.frame.size.width - lblEmail.frame.origin.x - 10 - 22, lblEmail.frame.size.height)];
        [lblEmailContent setTextColor:[UIColor whiteColor]];
        [lblEmailContent setText:user.strEmail];
        [lblEmailContent setTextAlignment:NSTextAlignmentRight];
        [cell addSubview:lblEmailContent];
        
        if (global_screen_size.width < 330)
        {
            [lblEmailContent setFont:[UIFont boldSystemFontOfSize:14.f]];
            [lblEmail setFont:[UIFont boldSystemFontOfSize:14.f]];
        }
        else
        {
            [lblEmailContent setFont:[UIFont boldSystemFontOfSize:16.f]];
            [lblEmail setFont:[UIFont boldSystemFontOfSize:16.f]];
        }
        UIView * viewSep = [[UIView alloc] initWithFrame:CGRectMake(22, cellHeight - 1, global_screen_size.width - 34, 1)];
        [viewSep setBackgroundColor:[UIColor colorWithRed:244/255.f green:244/255.f blue:244/255.f alpha:1.f]];
        [cell addSubview:viewSep];
    }
    if (indexPah.row == cell_mobile) {
        UILabel * lblMobile = [[UILabel alloc] initWithFrame:CGRectMake(22, 0, 80, cellHeight)];
        [lblMobile setTextAlignment:NSTextAlignmentLeft];
        [lblMobile setText:[NSString stringWithFormat:@"%@:",AMLocalizedString(@"Mobile", @"Mobile")]];
        [lblMobile setTextColor:[UIColor whiteColor]];
        
        [cell addSubview:lblMobile];
        

        [cell addSubview:txtMobileContent];
        
        if (global_screen_size.width < 330)
        {
            [txtMobileContent setFont:[UIFont boldSystemFontOfSize:14.f]];
            [lblMobile setFont:[UIFont boldSystemFontOfSize:14.f]];
        }
        else
        {
            [txtMobileContent setFont:[UIFont boldSystemFontOfSize:16.f]];
            [lblMobile setFont:[UIFont boldSystemFontOfSize:16.f]];
        }
        UIView * viewSep = [[UIView alloc] initWithFrame:CGRectMake(22, cellHeight - 1, global_screen_size.width - 34, 1)];
        [viewSep setBackgroundColor:[UIColor colorWithRed:244/255.f green:244/255.f blue:244/255.f alpha:1.f]];
        [cell addSubview:viewSep];
    }
    
    if (indexPah.row == cell_address) {
        UILabel * lblAddress = [[UILabel alloc] initWithFrame:CGRectMake(22, 0, 80, cellHeight)];
        [lblAddress setTextAlignment:NSTextAlignmentLeft];
        [lblAddress setText:[NSString stringWithFormat:@"%@:",AMLocalizedString(@"Address", @"Address")]];
        [lblAddress setTextColor:[UIColor whiteColor]];
        
        [cell addSubview:lblAddress];
        [cell addSubview:txtAddress];
        
        if (global_screen_size.width < 330)
        {
            [txtAddress setFont:[UIFont boldSystemFontOfSize:14.f]];
            [lblAddress setFont:[UIFont boldSystemFontOfSize:14.f]];
        }
        else
        {
            [txtAddress setFont:[UIFont boldSystemFontOfSize:16.f]];
            [lblAddress setFont:[UIFont boldSystemFontOfSize:16.f]];
        }
        UIView * viewSep = [[UIView alloc] initWithFrame:CGRectMake(22, cellHeight - 1, global_screen_size.width - 34, 1)];
        [viewSep setBackgroundColor:[UIColor colorWithRed:244/255.f green:244/255.f blue:244/255.f alpha:1.f]];
        [cell addSubview:viewSep];
    }
    if (indexPah.row == cell_update) {
        UIButton * btnUpdate = [[UIButton alloc] initWithFrame:CGRectMake(22, 7, global_screen_size.width - 44, cellHeight - 14)];
        [btnUpdate.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [btnUpdate setTitle:AMLocalizedString(@"Update details", @"Update details") forState:UIControlStateNormal];
        [btnUpdate setTitleColor:global_nav_color forState:UIControlStateNormal];
        btnUpdate.layer.cornerRadius = 4.f;
        btnUpdate.layer.masksToBounds = YES;
        [btnUpdate addTarget:self action:@selector(onUpdate) forControlEvents:UIControlEventTouchUpInside];
        [btnUpdate setBackgroundColor:[UIColor whiteColor]];
        [cell addSubview:btnUpdate];
        
        
        
        if (global_screen_size.width < 330)
        {
            [btnUpdate.titleLabel setFont:[UIFont boldSystemFontOfSize:14.f]];
        }
        else
        {
            [btnUpdate.titleLabel setFont:[UIFont boldSystemFontOfSize:16.f]];
        }
    }
    
    if (indexPah.row == cell_password) {
        UIView * viewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, global_screen_size.width, 1000)];
        [viewContainer setBackgroundColor:[UIColor whiteColor]];
        [cell addSubview:viewContainer];
        
        [viewContainer addSubview:txtOldPwd];
        [viewContainer addSubview:txtNewPwd];
        [viewContainer addSubview:txtConfirmPwd];
        
        UIButton * btnChange = [[UIButton alloc] initWithFrame:CGRectMake(22, txtConfirmPwd.frame.origin.y + txtConfirmPwd.frame.size.height + 22, global_screen_size.width - 44, cellHeight - 14)];
        [btnChange.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [btnChange setTitle:AMLocalizedString(@"Change password", @"Change password") forState:UIControlStateNormal];
        [btnChange setBackgroundColor:global_nav_color];
        [btnChange setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnChange.layer.cornerRadius = 4.f;
        btnChange.layer.masksToBounds = YES;
        [btnChange addTarget:self action:@selector(onChangePassword) forControlEvents:UIControlEventTouchUpInside];
        
        [cell addSubview:btnChange];
        
        
        
        if (global_screen_size.width < 330)
        {
            [btnChange.titleLabel setFont:[UIFont boldSystemFontOfSize:14.f]];
        }
        else
        {
            [btnChange.titleLabel setFont:[UIFont boldSystemFontOfSize:16.f]];
        }
        
    }
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    [textField setReturnKeyType:UIReturnKeyDone];
    CGPoint point =  [textField convertPoint:CGPointMake(0,0) toView:nil];
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
        [tblView setContentOffset:CGPointMake(0, tblView.contentOffset.y + offsetAnimation)];
        //self.view.frame = CGRectMake(0, -offsetAnimation, self.view.frame.size.width, self.view.frame.size.height);
        [UIView commitAnimations];
    }
    
}
- (void) onKeyboardHide:(id)sender {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [tblView setContentOffset:CGPointMake(0, 0)];
    //self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
    
}

#pragma mark - TapGesture

- (void) dismissKeyboards {
    [txtConfirmPwd resignFirstResponder];
    [txtNewPwd resignFirstResponder];
    [txtOldPwd resignFirstResponder];
    [txtMobileContent resignFirstResponder];
    [txtAddress resignFirstResponder];
    [txtName resignFirstResponder];
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
            
            imagePicker.allowsEditing = YES;
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
            
            imagePicker.allowsEditing = YES;
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
    // Code here to work with media
    //    UIImage *imagePicked = [self scaleAndRotateImage:[info valueForKey:UIImagePickerControllerOriginalImage]];
    imagePicked = [info valueForKey:UIImagePickerControllerEditedImage];
    CGSize ss =  imagePicked.size;
    
    imgProfile.contentMode =  UIViewContentModeScaleAspectFit;
    ss = imgProfile.frame.size;
    imagePicked = [self imageWithScaleSize:imagePicked scaledToSize:imgProfile.frame.size];
    
    ss =  imagePicked.size;
    
    ss =  imgProfile.frame.size;
    flagImageChaged = YES;
    
    [imgProfile setImage:imagePicked];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)imagePickerControllerDidCancel:
(UIImagePickerController *)picker
{
    flagImageChaged=NO;
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

#pragma mark - Utils
- (void) getProfile {
    AppDelegate * app = (AppDelegate*) [UIApplication sharedApplication].delegate;
    [app showHUD];
    
    //Get Profile API
    
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setObject:user.strUserID forKey:global_key_user_id];
    //////////
    [MyRequest POST:global_api_getProfile parameters:param completed:^(id result)
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
                     NSDictionary * dicResObject = [dicResult valueForKey:global_key_res_object];
                     if (dicResObject)
                     {
                         NSArray * ary = [dicResObject valueForKey:global_key_profile_details];
                         NSDictionary * dicOne = [ary objectAtIndex:0];
                         if ([dicOne valueForKey:global_key_profile_image]) {
                             user.strURLProfile = [dicOne valueForKey:global_key_profile_image];
                         }
                         if ([dicOne valueForKey:global_key_profile_image]) {
                             user.strURLProfile = [dicOne valueForKey:global_key_profile_image];
                         }
                         if ([dicOne valueForKey:global_key_first_name]) {
                             user.strFirstName = [dicOne valueForKey:global_key_first_name];
                         }
                         if ([dicOne valueForKey:global_key_last_name]) {
                             user.strLastName = [dicOne valueForKey:global_key_last_name];
                         }
                         if ([dicOne valueForKey:global_key_email]) {
                             user.strEmail = [dicOne valueForKey:global_key_email];
                         }
                         if ([dicOne valueForKey:global_key_mobile]) {
                             user.strMobile = [dicOne valueForKey:global_key_mobile];
                         }
                         if ([dicOne valueForKey:global_key_address]) {
                             user.strAddress = [dicOne valueForKey:global_key_address];
                         }
                         [GlobalUtils saveUserObject:user key:global_user_info_save];
                         [self refreshViews];
                         return;
                         
                         
                     }
                     [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Unknown Error", @"Unknown Error") cancel:AMLocalizedString(@"Ok", @"Ok")];
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
- (void) initViews {
    
    txtMobileContent = [[UITextField alloc] initWithFrame:CGRectMake(22 + 90 + 10, 0, global_screen_size.width - 90 - 22 - 10 - 22, cellHeight)];
    [txtMobileContent setTextColor:[UIColor whiteColor]];
    [txtMobileContent setText:user.strMobile];
    [txtMobileContent setTextAlignment:NSTextAlignmentRight];
    
    txtAddress = [[UITextField alloc] initWithFrame:txtMobileContent.frame];
    [txtAddress setTextColor:[UIColor whiteColor]];
    [txtAddress setText:user.strAddress];
    [txtAddress setTextAlignment:NSTextAlignmentRight];
    
    imgProfile = [[UIImageView alloc] initWithFrame:CGRectMake(global_screen_size.width / 2 - global_screen_size.width / 8, 20, global_screen_size.width / 4, global_screen_size.width / 4)];
    
    [GlobalUtils setImageForUrlAndSize:imgProfile ID:user.strURLProfile url:[NSString stringWithFormat:@"%@%@", global_url_photo, user.strURLProfile] size:imgProfile.frame.size placeImage:@"avatar" storeDir:global_dir_profile];
    imgProfile.layer.cornerRadius = imgProfile.frame.size.height / 2;
    imgProfile.layer.borderColor = [UIColor whiteColor].CGColor;
    imgProfile.layer.borderWidth = 1.f;
    imgProfile.layer.masksToBounds = YES;
    
    txtOldPwd = [[UITextField alloc] initWithFrame:CGRectMake(22, 22, global_screen_size.width - 44, (global_screen_size.width - 44) / 10)];
    txtOldPwd.placeholder = AMLocalizedString(@"Please input old password.", @"Please input old password.");
    
    UIView *paddingViewOld = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, txtOldPwd.frame.size.height)];
    txtOldPwd.leftView = paddingViewOld;
    txtOldPwd.leftViewMode = UITextFieldViewModeAlways;
    
    txtNewPwd = [[UITextField alloc] initWithFrame:CGRectMake(22, txtOldPwd.frame.origin.y + txtOldPwd.frame.size.height + 22, global_screen_size.width - 44, (global_screen_size.width - 44) / 10)];
    txtNewPwd.placeholder = AMLocalizedString(@"Please input new password.", @"Please input new password.");
    
    UIView *paddingViewNew = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, txtOldPwd.frame.size.height)];
    txtNewPwd.leftView = paddingViewNew;
    txtNewPwd.leftViewMode = UITextFieldViewModeAlways;
    
    txtConfirmPwd = [[UITextField alloc] initWithFrame:CGRectMake(22, txtNewPwd.frame.origin.y + txtNewPwd.frame.size.height + 22, global_screen_size.width - 44, (global_screen_size.width - 44) / 10)];
    txtConfirmPwd.placeholder = AMLocalizedString(@"Please re-enter new password", @"Please re-enter new password");
    
    UIView *paddingViewConfirm = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, txtOldPwd.frame.size.height)];
    txtConfirmPwd.leftView = paddingViewConfirm;
    txtConfirmPwd.leftViewMode = UITextFieldViewModeAlways;
    
    txtOldPwd.delegate = self;
    txtNewPwd.delegate = self;
    txtConfirmPwd.delegate = self;
    txtAddress.delegate = self;
    txtMobileContent.delegate = self;
    
    
    txtOldPwd.layer.borderColor = [UIColor lightGrayColor].CGColor;
    txtOldPwd.layer.borderWidth = 2.f;
    
    txtNewPwd.layer.borderColor = [UIColor lightGrayColor].CGColor;
    txtNewPwd.layer.borderWidth = 2.f;
    
    txtConfirmPwd.layer.borderColor = [UIColor lightGrayColor].CGColor;
    txtConfirmPwd.layer.borderWidth = 2.f;
    
    txtOldPwd.layer.cornerRadius = 3.f;
    txtNewPwd.layer.cornerRadius = 3.f;
    txtConfirmPwd.layer.cornerRadius = 3.f;
    
    [txtOldPwd setSecureTextEntry:YES];
    [txtNewPwd setSecureTextEntry:YES];
    [txtConfirmPwd setSecureTextEntry:YES];
    
    txtName = [[UITextField alloc] initWithFrame:txtMobileContent.frame];
    [txtName setTextAlignment:NSTextAlignmentRight];
    [txtName setTextColor:[UIColor whiteColor]];
    [txtName setBackgroundColor:[UIColor clearColor]];
    [txtName setText:[NSString stringWithFormat:@"%@ %@", user.strFirstName, user.strLastName]];
    txtName.delegate = self;
    
    if (global_screen_size.width < 330)
    {
        [txtOldPwd setFont:[UIFont boldSystemFontOfSize:14.f]];
        [txtNewPwd setFont:[UIFont boldSystemFontOfSize:14.f]];
        [txtConfirmPwd setFont:[UIFont boldSystemFontOfSize:14.f]];
        [txtAddress setFont:[UIFont boldSystemFontOfSize:14.f]];
        [txtMobileContent setFont:[UIFont boldSystemFontOfSize:14.f]];
        [txtName setFont:[UIFont boldSystemFontOfSize:14.f]];
        
    }
    else
    {
        [txtOldPwd setFont:[UIFont boldSystemFontOfSize:16.f]];
        [txtNewPwd setFont:[UIFont boldSystemFontOfSize:16.f]];
        [txtConfirmPwd setFont:[UIFont boldSystemFontOfSize:16.f]];
        [txtAddress setFont:[UIFont boldSystemFontOfSize:16.f]];
        [txtMobileContent setFont:[UIFont boldSystemFontOfSize:16.f]];
        [txtName setFont:[UIFont boldSystemFontOfSize:16.f]];
    }
    [tblView reloadData];
}

- (void) refreshViews {
    [GlobalUtils setImageForUrlAndSize:imgProfile ID:user.strURLProfile url:[NSString stringWithFormat:@"%@%@", global_url_photo, user.strURLProfile] size:imgProfile.frame.size placeImage:@"avatar" storeDir:global_dir_profile];
    [txtMobileContent setText:user.strMobile];
    [txtAddress setText:user.strAddress];
    [txtName setText:[NSString stringWithFormat:@"%@ %@", user.strFirstName, user.strLastName]];
}
@end
