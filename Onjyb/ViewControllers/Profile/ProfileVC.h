//
//  ProfileVC.h
//  Onjyb
//
//  Created by Nadia Drabyk on 7/20/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface ProfileVC : UIViewController < SlideNavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationBarDelegate, UIActionSheetDelegate, UINavigationControllerDelegate > {
    UIView * dimView;
    IBOutlet UITableView * tblView;
    UIImageView * imgProfile;
    BOOL profileChange;
    User * user;
    
    UITextField * txtMobileContent;
    UITextField * txtAddress;
    CGFloat cellHeight;
    
    UITextField * txtOldPwd;
    UITextField * txtNewPwd;
    UITextField * txtConfirmPwd;
    UITextField * txtName;
    
    BOOL flagKeyboardAnimate;
    CGFloat offsetAnimation;
    
    UIImage * imagePicked;
    BOOL flagImageChaged;
}

- (IBAction)onMenu:(id)sender;

@end
