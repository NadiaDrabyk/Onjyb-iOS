//
//  RequestLeaveVC.h
//  Onjyb
//
//  Created by Nadia Drabyk on 7/19/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface RequestLeaveVC : UIViewController < SlideNavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate,UIPickerViewDelegate, UIPickerViewDataSource > {
    UIView * dimView;
    IBOutlet UITableView * tblView;
    IBOutlet UILabel * lblTop;
    IBOutlet UIView * viewTop;
    
    CGFloat cellHeight;
    CGFloat padding;
    UITextView * txtNote;
    UITextField * txtProject;
    UITextField * txtLeaveType;
    UITextField * txtFromDate;
    UITextField * txtToDate;
    UIDatePicker * mPickerFrom;
    UIDatePicker * mPickerTo;
    NSString * strFromDateSave;
    NSString * strToDateSave;
    UIScrollView * viewProject;
    UIView * viewLeaveType;
    
    NSMutableArray * mArayProjects;
    int selectedProjectIndex;
    NSMutableArray * mAryFilteredContent;
    NSMutableArray * mAryFilteredIndex;
    NSMutableArray * mAryOrg;
    NSMutableArray * mAryLeaveType;
    NSString * strFilterProject;
    NSString * strFilterLeave;
    int selectedLeaveIndex;
    CGFloat btnProjectHeight;
    NSMutableArray * mAryFilteredContentLeave;
    NSMutableArray * mAryFilteredIndexLeave;
    BOOL flagKeyboardAnimate;
    CGFloat offsetAnimation;
    
    UIButton *btnClearTxtProject;
    UIButton *btnClearTxtLeaveType;

    UILabel * lblUsedVacation;
    UILabel * lblPlanedVacation;
    UILabel * lblLeftVacation;
    
    UIView* PTOView;
    UIPickerView * mPickerHours;
    UIPickerView * mPickerMinutes;
    UITextField * txtPTOHours;
    UITextField * txtPTOMinutes;
    int nPTOValue;

    NSString* strLeaveMasterType;
}

- (IBAction)onMenu:(id)sender;



@end
