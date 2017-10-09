//
//  ExtraWorkCreateVC.h
//  Onjyb
//
//  Created by Nadia Drabyk on 7/30/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface ExtraWorkCreateVC : UIViewController < UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UITextViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate  >
{
    IBOutlet UITableView * tblView;
    IBOutlet UILabel * lblTop;
    
    NSMutableArray * mArayAttachment;
    CGFloat cellHeight;
    CGFloat leftPadding;
    CGFloat topPadding;
    UITextView * txtComment;
    UILabel * lblWorkingHours;
    UILabel * lblWorkingMinutes;
    UITextField * txtWorkingHours;
    UITextField * txtWorkingMinutes;
    UITextField * txtService;
    UITableView * tblServices;
    NSMutableArray * aryServices;
    
    CGFloat clockHeight;
    UIPickerView * mPickerWorkingHours;
    UIPickerView * mPickerWorkingMinutes;
    CGFloat offsetAnimation;
    BOOL flagKeyboardAnimate;
    UIImage * imagePicked;
    UIButton * btnTemp;
    
    UITapGestureRecognizer* tapGesture;
    
    UIButton *btnClearTxtService;
    NSString *strFilter;
}

- (IBAction)onBack:(id)sender;

@property (nonatomic, readwrite) int indexOfArray;
@property (nonatomic, strong) NSMutableDictionary * dicInfo;

@end
