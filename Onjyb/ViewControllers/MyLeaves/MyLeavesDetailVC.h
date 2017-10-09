//
//  MyLeavesDetailVC.h
//  Onjyb
//
//  Created by Nadia Drabyk on 7/19/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface MyLeavesDetailVC : UIViewController < UITableViewDelegate, UITableViewDataSource > {
    IBOutlet UITableView * tblView;
    IBOutlet UILabel * lblTop;
}

- (IBAction)onBack:(id)sender;


@end
