//
//  StatisticsVC.h
//  Onjyb
//
//  Created by Nadia Drabyk on 7/19/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface StatisticsVC : UIViewController < SlideNavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate > {
    UIView * dimView;
    UITableView * tblView;
    
    UIView * viewTop;
    UIView * viewMid;
    UIView * viewTitle;
    UIView * viewProject;
    UITextField * txtProject;
    UILabel * lblTotalHours;
    UILabel * lblOvertime;
    UILabel * lblKilometers;
    UITextField * txtDateFrom;
    UITextField * txtDateTo;
    UIDatePicker * mPickerFrom;
    UIDatePicker * mPickerTo;
    CGFloat cellHeight;
    CGFloat leftPadding;
    UILabel * lblDateFrom;
    UILabel * lblDateTo;
    
    NSString * strDateSaveStart;
    NSString * strDateSaveEnd;
    NSMutableArray * mArayProjects;
    int selectedProjectIndex;
    NSMutableArray * mAryFilteredContent;
    NSMutableArray * mAryFilteredIndex;
    NSMutableArray * mAryOrg;
    NSString * strFilter;
    CGFloat btnProjectHeight;
    NSMutableArray * mAryTaskList;
    
    NSArray * aryOvertimeData;
    UIView * popupDimView;
    UIView * popup;

}

- (IBAction)onMenu:(id)sender;

@end
