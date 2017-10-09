//
//  LoginVC.m
//  Onjyb
//
//  Created by Nadia Drabyk on 7/15/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import "LoginVC.h"
#import "LeftMenuVC.h"
#import "HomeVC.h"

@interface LoginVC ()

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:AMLocalizedString(@"Login", @"Login")];
    
    [btnLogin setBackgroundColor:global_nav_color];
    [btnForgot setTitleColor:global_nav_color forState:UIControlStateNormal];
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboards)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
    
    if (global_screen_size.width < 330)
    {
        [txtEmail setFont:[UIFont systemFontOfSize:global_font_text_iphone5]];
        [txtPassword setFont:[UIFont systemFontOfSize:global_font_text_iphone5]];
        [btnLogin.titleLabel setFont:[UIFont systemFontOfSize:global_font_button_normal_iphone5]];
        [btnForgot.titleLabel setFont:[UIFont systemFontOfSize:global_font_button_small_iphone5]];
    }
    
    [btnForgot setTitle:AMLocalizedString(@"Forgot Password?", @"Forgot Password?") forState:UIControlStateNormal];
    [btnLogin setTitle:AMLocalizedString(@"Login", @"Login") forState:UIControlStateNormal];
    txtEmail.placeholder = AMLocalizedString(@"Email", @"Email");
    txtPassword.placeholder = AMLocalizedString(@"Password", @"Password");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    
    UIView *paddingViewEmail = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, txtEmail.frame.size.height)];
    txtEmail.leftView = paddingViewEmail;
    txtEmail.leftViewMode = UITextFieldViewModeAlways;

    UIView *paddingViewPwd = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, txtPassword.frame.size.height)];
    txtPassword.leftView = paddingViewPwd;
    txtPassword.leftViewMode = UITextFieldViewModeAlways;
    
    txtEmail.layer.borderColor = [UIColor grayColor].CGColor;
    txtEmail.layer.borderWidth = 1.f;
    txtEmail.layer.masksToBounds = YES;
    
    txtPassword.layer.borderColor = [UIColor grayColor].CGColor;
    txtPassword.layer.borderWidth = 1.f;
    txtPassword.layer.masksToBounds = YES;
}

- (void) viewWillDisappear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Button Actions
- (IBAction)onLogin:(id)sender {
    
    if (txtEmail.text.length == 0)
    {
        [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Please Enter Email Address", @"Please Enter Email Address") cancel:AMLocalizedString(@"Ok", @"Ok")];
        
        return;
    }
    if (txtPassword.text.length == 0)
    {
        [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Please Enter Password", @"Please Enter Password") cancel:AMLocalizedString(@"Ok", @"Ok")];
        return;
    }
    if (![GlobalUtils validateEmailWithString:txtEmail.text])
    {
        [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Please Enter Valid Email", @"Please Enter Valid Email") cancel:AMLocalizedString(@"Ok", @"Ok")];
        return;
    }
    
    AppDelegate * app = (AppDelegate*) [UIApplication sharedApplication].delegate;
    [app showHUD];
    
    //Login API
    
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setObject:txtEmail.text forKey:global_key_txt_email];
    [param setObject:txtPassword.text forKey:global_key_txt_password];

    //////////
    [MyRequest POST:global_api_login parameters:param completed:^(id result)
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
                        NSDictionary * dicUserDetail = [dicResObject valueForKey:global_key_user_detail];
                        if (dicUserDetail)
                        {
                            User * userLogged = [[User sharedInstance] getUser:dicUserDetail];
                            [GlobalUtils saveUserObject:userLogged key:global_user_info_save];
                            
                            
                            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:global_key_is_logged_in];
                            
                            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                            HomeVC * vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"HomeVC"];
                            
                            [self.navigationController pushViewController:vc animated:YES];
                            return;
                        }
                    }
                    [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Unknown Error", @"Unknown Error") cancel:AMLocalizedString(@"Ok", @"Ok")];
                }
                else {
                    NSString * errorString = AMLocalizedString(@"Login Failed", @"Login Failed");
                    if ([dicResult valueForKey:global_key_res_message])
                    {
                        errorString = [NSString stringWithFormat:@"%@", [dicResult valueForKey:global_key_res_message]];
                    }
                    [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:errorString cancel:AMLocalizedString(@"Ok", @"Ok")];
                }
                return;
            }
        }
        NSString * errorString = AMLocalizedString(@"Login Failed", @"Login Failed");
        [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:errorString cancel:AMLocalizedString(@"Ok", @"Ok")];
    }];
    
}
- (IBAction)onForgot:(id)sender {
    
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
        [mScroll setContentOffset:CGPointMake(mScroll.contentOffset.x, mScroll.contentOffset.y + offsetAnimation)];
//        self.view.frame = CGRectMake(0, -offsetAnimation, global_screen_size.width, global_screen_size.height);
        [UIView commitAnimations];
    }
    
}
- (void) onKeyboardHide:(id)sender {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [mScroll setContentOffset:CGPointMake(0, 0)];
//        self.view.frame = CGRectMake(0, 0, global_screen_size.width, global_screen_size.height);
    [UIView commitAnimations];
}

#pragma mark - TapGesture

- (void) dismissKeyboards {
    [txtPassword resignFirstResponder];
    [txtEmail resignFirstResponder];
}
@end
