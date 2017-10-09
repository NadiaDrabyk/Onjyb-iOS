//
//  PastLeaveVC.h
//  Onjyb
//
//  Created by Nadia Drabyk on 7/19/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface PastLeaveVC : UIViewController < UITableViewDelegate, UITableViewDataSource, SlideNavigationControllerDelegate > {
    IBOutlet UITableView * tblView;
    CGFloat leftPad;
    CGFloat cellHeight;
    NSMutableArray * mAryTaskList;
    NSString * strStartDateApply;
    NSString * strEndDateApply;
    NSString * strProjectIDApply;
    NSString * strEmployeeIDApply;
}

- (IBAction)onBack:(id)sender;
- (IBAction)onMore:(id)sender;

@end
