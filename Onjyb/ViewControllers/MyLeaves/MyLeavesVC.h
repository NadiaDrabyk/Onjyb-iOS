//
//  MyLeavesVC.h
//  Onjyb
//
//  Created by Nadia Drabyk on 7/19/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface MyLeavesVC : UIViewController < SlideNavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource > {
    UIView * dimView;
    IBOutlet UITableView * tblView;
    CGFloat leftPad;
    CGFloat cellHeight;
    NSMutableArray * mAryTaskList;
}

- (IBAction)onMenu:(id)sender;
- (IBAction)onMore:(id)sender;

@end
