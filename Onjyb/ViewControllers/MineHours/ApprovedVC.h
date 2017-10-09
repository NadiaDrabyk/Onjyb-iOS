//
//  ApprovedVC.h
//  Onjyb
//
//  Created by Nadia Drabyk on 7/19/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface ApprovedVC : UIViewController < UITableViewDelegate, UITableViewDataSource, SlideNavigationControllerDelegate >
{
    IBOutlet UILabel * lblTop;
    CGFloat cellHeight;
    NSMutableArray * mAryTaskList;
    IBOutlet UITableView * tblView;
    CGFloat leftPad;
    
    NSString * strStartDateApply;
    NSString * strEndDateApply;
    NSString * strProjectIDApply;
    NSString * strEmployeeIDApply;
}
@property(nonatomic, strong)NSMutableArray * mAryTaskList;

- (IBAction)onBack:(id)sender;
- (IBAction)onMore:(id)sender;

@end
