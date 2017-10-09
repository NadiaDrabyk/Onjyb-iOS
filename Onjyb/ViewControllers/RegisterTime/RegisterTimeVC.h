//
//  RegisterTimeVC.h
//  Onjyb
//
//  Created by Nadia Drabyk on 7/18/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "JCDrawView.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface RegisterTimeVC : UIViewController < SlideNavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationBarDelegate, UIActionSheetDelegate, UIScrollViewDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate >
{
    IBOutlet UIButton * btnMenu;
    UIView * dimView;
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
//    UIPickerView * mPickerKm;
    UIImage * imagePicked;
    NSMutableDictionary * mDicInfo;
    NSString * strDateSave;
    UIScrollView * viewProject;
    
    NSMutableArray * mArayProjects;
    int selectedProjectIndex;
    NSMutableArray * mAryFilteredContent;
    NSMutableArray * mAryFilteredIndex;
    NSMutableArray * mAryOrg;
    NSString * strFilter;
    CGFloat btnProjectHeight;
    
    IBOutlet UIView * viewSignatureDim;
    IBOutlet UIView * viewSignature;
    IBOutlet JCDrawView * drawSignatureView;
    IBOutlet UITextField * txtSignature;
    IBOutlet UITextField * txtEmail;
    IBOutlet UILabel * lblName;
    IBOutlet UILabel * lblEmail;
    IBOutlet UILabel * lblContactName;
    IBOutlet UILabel * lblContactEmail;
    IBOutlet UITextField * txtContactName;
    IBOutlet UITextField * txtContactEmail;

    IBOutlet UILabel * lblIP;
    IBOutlet UILabel * lblSignature;
    IBOutlet UIButton * btnNull;
    IBOutlet UIButton * btnSignCancel;
    IBOutlet UIButton * btnSignSave;

    BOOL isSelectOvertimeArrowButton;
    
    UIButton *btnClearTxtProject;
    
    BOOL isworkovertimeautomatic;
    NSArray *aryRulesList;

}

- (IBAction)onMenu:(id)sender;
- (IBAction)onDateTop:(id)sender;

@property(nonatomic, strong) NSMutableDictionary * dicInfo;

@end
