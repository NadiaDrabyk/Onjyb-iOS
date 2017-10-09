//
//  HomeVC.h
//  Onjyb
//
//  Created by Nadia Drabyk on 7/16/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface HomeVC : UIViewController < SlideNavigationControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, SimpleBarChartDataSource, SimpleBarChartDelegate, UITableViewDelegate, UITableViewDataSource > {
    
    IBOutlet UIButton * btnMenu;
    IBOutlet UIButton * btnRegister;
    
    IBOutlet UILabel * lblSelectProject;
    IBOutlet UILabel * lblLatestActivity;
    IBOutlet UIScrollView * mScroll;
    IBOutlet UITextField * txtProject;
    UIButton *btnClearTxtProject;
    
    IBOutlet UIImageView * imgGraph;
    IBOutlet UIView * viewHeader;
    UIView * dimView;
    NSMutableArray * mAryTaskList;
//    NSArray * mAryProjectDetails;
    
    
    //Bar Chart
    NSMutableArray *_barValues;
    NSMutableArray *_barLabels;
    SimpleBarChart *_barChartViews;
    IBOutlet UIScrollView * chartScroll;
    NSMutableArray *_barColors;
    
    UITableView * tblProject;
    NSMutableArray * mArayProjects;
    CGFloat cellHeight;
    int selectedProjectIndex;
    NSMutableArray * mAryFilteredContent;
    NSMutableArray * mAryFilteredIndex;
    NSMutableArray * mAryOrg;
    NSString * strFilter;
}

- (IBAction)onMenu:(id)sender;
- (IBAction)onRegister:(id)sender;

@end
