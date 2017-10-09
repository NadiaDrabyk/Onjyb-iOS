//
//  RightMenuVC.h
//  Onjyb
//
//  Created by Nadia Drabyk on 7/19/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface RightMenuVC : UIViewController < UIGestureRecognizerDelegate, UITextFieldDelegate > {
    
    UIView * viewTop;
    UIButton * btnClear;
    UIButton * btnApply;
    UIButton * btnStart;
    UIButton * btnEnd;
    UIButton * btnCalendarStart;
    UIButton * btnCalendarEnd;
    UITextField * txtProject;
    UIScrollView * viewProject;
    UITextField * txtBranch;
    UITextField * txtEmployee;
    UIScrollView * viewEmployee;
    UITextField * txtStart;
    UITextField * txtEnd;
    UIDatePicker * mPickerStart;
    UIDatePicker * mPickerEnd;
    CGFloat leftPadding;
    CGFloat topPadding;
    
    NSMutableArray * mArayProjects;
    int selectedProjectIndex;
    NSMutableArray * mAryFilteredContentProjects;
    NSMutableArray * mAryFilteredIndexProjects;
    NSString * strFilterProjects;

    NSMutableArray * mArayEmployee;
    int selectedEmployeeIndex;
    NSMutableArray * mAryFilteredContentEmployee;
    NSMutableArray * mAryFilteredIndexEmployee;
    NSString * strFilterEmployee;

    CGFloat btnProjectHeight;
    UIButton *btnClearTxtProject;
    UIButton *btnClearTxtEmployee;


}

@property (nonatomic, assign) BOOL slideOutAnimationEnabled;
@end
