//
//  CompletedTasksDetailVC.h
//  Onjyb
//
//  Created by Nadia Drabyk on 7/19/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface CompletedTasksDetailVC : UIViewController < UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate > {
    IBOutlet UITableView * tblView;
    IBOutlet UILabel * lblTop;
    IBOutlet UILabel * lblTopDate;
    CGFloat cellHeight;
    CGFloat commentLabelHeight;
    CGFloat padding;
    NSMutableArray * mAryExtraWork;
    NSMutableDictionary * mDicWorkSheet;
    int flagRefresh;
    NSMutableArray * mArrImage;
}

- (IBAction)onBack:(id)sender;
@property(nonatomic, strong) NSMutableDictionary * dicInfo;


@end
