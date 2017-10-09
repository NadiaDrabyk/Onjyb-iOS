//
//  LoginVC.h
//  Onjyb
//
//  Created by Nadia Drabyk on 7/15/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"


@interface LoginVC : UIViewController < UITextFieldDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate >{
    
    IBOutlet UITextField * txtEmail;
    IBOutlet UITextField * txtPassword;
    IBOutlet UIButton * btnLogin;
    IBOutlet UIButton * btnForgot;
    
    BOOL flagKeyboardAnimate;
    CGFloat offsetAnimation;
    IBOutlet UIScrollView * mScroll;
}

- (IBAction)onLogin:(id)sender;
- (IBAction)onForgot:(id)sender;

@end
