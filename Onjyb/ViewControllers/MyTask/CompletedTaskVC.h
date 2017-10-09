//
//  CompletedTaskVC.h
//  Onjyb
//
//  Created by Nadia Drabyk on 7/19/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface CompletedTaskVC : UIViewController < UITableViewDelegate, UITableViewDataSource, SlideNavigationControllerDelegate > {
    IBOutlet UITableView * tblView;
    IBOutlet UILabel * lblTop;
    NSMutableArray * mAryTaskList;
    CGFloat cellHeight;
    CGFloat leftPad;
    NSString * strStartDateApply;
    NSString * strEndDateApply;
    NSString * strProjectIDApply;
    NSString * strEmployeeIDApply;
}

- (IBAction)onBack:(id)sender;
- (IBAction)onMore:(id)sender;


@end
