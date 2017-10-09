//
//  ForgotPwdVC.m
//  Onjyb
//
//  Created by Nadia Drabyk on 7/15/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import "ForgotPwdVC.h"

@interface ForgotPwdVC ()

@end

@implementation ForgotPwdVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:AMLocalizedString(@"Forgot Password?", @"Forgot Password?")];
    
    [btnSubmit setBackgroundColor:global_nav_color];
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboards)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
    
    if (global_screen_size.width < 330) {
        [txtEmail setFont:[UIFont systemFontOfSize:global_font_text_iphone5]];
        [btnSubmit.titleLabel setFont:[UIFont systemFontOfSize:global_font_button_normal_iphone5]];
    }

    [btnSubmit setTitle:AMLocalizedString(@"Submit", @"Submit") forState:UIControlStateNormal];
    txtEmail.placeholder = AMLocalizedString(@"Email", @"Email");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {

    UIView *paddingViewEmail = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, txtEmail.frame.size.height)];
    txtEmail.leftView = paddingViewEmail;
    txtEmail.leftViewMode = UITextFieldViewModeAlways;
    
    txtEmail.layer.borderColor = [UIColor grayColor].CGColor;
    txtEmail.layer.borderWidth = 1.f;
    txtEmail.layer.masksToBounds = YES;
}

- (void) viewWillDisappear:(BOOL)animated {
    
}

#pragma mark - Button Actions
- (IBAction)onSubmit:(id)sender {
    
    if (txtEmail.text.length == 0)
    {
        
        [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Please Enter Email Address", @"Please Enter Email Address") cancel:AMLocalizedString(@"Ok", @"Ok")];
    }
    if (![GlobalUtils validateEmailWithString:txtEmail.text])
    {
        [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Please Enter Valid Email", @"Please Enter Valid Email") cancel:AMLocalizedString(@"Ok", @"Ok")];
    }
    AppDelegate * app = (AppDelegate*) [UIApplication sharedApplication].delegate;
    [app showHUD];
    
    //Forgot Password API
    
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setObject:txtEmail.text forKey:global_key_txt_email];
    //////////
    [MyRequest POST:global_api_forgot_password parameters:param completed:^(id result)
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
                     UIAlertController *alert = [UIAlertController alertControllerWithTitle:AMLocalizedString(@"Onjyb", @"Onjyb") message:[dicResult valueForKey:global_key_res_message] preferredStyle:UIAlertControllerStyleAlert];
                     UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:AMLocalizedString(@"Ok", @"Ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                                     {
                                                         [self.navigationController popViewControllerAnimated:YES];
                                                     }];
                     
                     [alert addAction:defaultAction];
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
         }
         NSString * errorString = AMLocalizedString(@"Error occured.", @"Error occured.");
         [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:errorString cancel:AMLocalizedString(@"Ok", @"Ok")];

     }
     ];
    
    
}

- (IBAction)onBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    [textField setReturnKeyType:UIReturnKeyDone];
    return YES;
}

#pragma mark - TapGesture

- (void) dismissKeyboards {
    [txtEmail resignFirstResponder];
}


@end
