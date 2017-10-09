//
//  RegisterTimeDetailsVC.h
//  Onjyb
//
//  Created by Nadia Drabyk on 7/27/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "JCDrawView.h"

@interface RegisterTimeDetailsVC : UIViewController < UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate  >
{
    IBOutlet UITableView * tblView;
    IBOutlet UIButton * btnTopDate;
    IBOutlet UILabel * lblTopDate;
    IBOutlet UIView * viewTop;
    CGFloat cellHeight;
    CGFloat leftPadding;
    CGFloat topPadding;
    
    UITextField * txtSelectProject;
    UITextField * txtSelectBranch;
    UILabel * lblWorkingHoursStart;
    UILabel * lblWorkingHoursEnd;
    UILabel * lblBreakTimeHours;
    UILabel * lblBreakTimeMinutes;
    UILabel * lblOvertime50Hours;
    UILabel * lblOvertime50Minutes;
    UILabel * lblOvertime100Hours;
    UILabel * lblOvertime100Minutes;
    UILabel * lblKilometers;
    NSMutableArray * mArayExtraWork;
    NSMutableArray * mArayAttachment;
    UITextView * txtComment;
    UILabel * lblTotalovertime50;
    UILabel * lblTotalovertime100;
    UILabel * lblTotalHours;
    
    UIButton * btnPTOBank;

    CGFloat clockHeight;
    BOOL flagKeyboardAnimate;
    CGFloat offsetAnimation;
    
    int valueBreakTime;
    int valueStart;
    int valueEnd;
    int value50;
    int value100;
    int valueKm;
    
    UITextField * txtStartDate;
    UITextField * txtStartWorking;
    UITextField * txtEndWorking;
    UITextField * txtBreakHours;
    UITextField * txtBreakMinutes;
    UITextField * txt50Hours;
    UITextField * txt50Minutes;
    UITextField * txt100Hours;
    UITextField * txt100Minutes;
    UITextField * txtKm;
    
    UIDatePicker * mPickerStartDate;
    UIDatePicker * mPickerStartWorking;
    UIDatePicker * mPickerEndWorking;
    UIPickerView * mPickerBreakHours;
    UIPickerView * mPickerBreakMinutes;
    UIPickerView * mPicker50Hours;
    UIPickerView * mPicker50Minutes;
    UIPickerView * mPicker100Hours;
    UIPickerView * mPicker100Minutes;
    UIPickerView * mPickerKm;
    UIImage * imagePicked;
    NSMutableDictionary * mDicInfo;
    NSString * strDateSave;
    
    IBOutlet UIView * viewSignatureDim;
    IBOutlet UIView * viewSignature;
    IBOutlet JCDrawView * drawSignatureView;
    IBOutlet UITextField * txtSignature;

    BOOL isSelectOvertimeArrowButton;

}

- (IBAction)onBack:(id)sender;
- (IBAction)onDateTop:(id)sender;

@property(nonatomic, strong) NSMutableDictionary * dicInfo;
@property(nonatomic, readwrite) int valueMode;

@end
