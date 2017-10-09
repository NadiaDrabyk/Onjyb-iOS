//
//  LeaveDetailsVC.h
//  Onjyb
//
//  Created by Nadia Drabyk on 7/19/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface LeaveDetailsVC : UIViewController < UITableViewDelegate, UITableViewDataSource > {
    IBOutlet UITableView * tblView;
    IBOutlet UILabel * lblTop;
    CGFloat cellHeight;
    CGFloat padding;
    CGFloat commentEmployeeLabelHeight, commentManagerLabelHeight;
}

- (IBAction)onBack:(id)sender;
@property(nonatomic, strong) NSMutableDictionary * dicInfo;


@end
