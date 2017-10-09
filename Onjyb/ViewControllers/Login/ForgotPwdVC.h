//
//  ForgotPwdVC.h
//  Onjyb
//
//  Created by Nadia Drabyk on 7/15/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface ForgotPwdVC : UIViewController < UITextFieldDelegate, UIGestureRecognizerDelegate> {
    IBOutlet UIButton * btnBack;
    IBOutlet UIButton * btnSubmit;
    IBOutlet UITextField * txtEmail;
}

- (IBAction)onBack:(id)sender;
- (IBAction)onSubmit:(id)sender;
@end
