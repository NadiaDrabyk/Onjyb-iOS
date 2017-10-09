//
//  ExtraWorkDetailsVC.h
//  Onjyb
//
//  Created by Nadia Drabyk on 7/27/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface ExtraWorkDetailsVC : UIViewController < UITableViewDelegate, UITableViewDataSource >
{
    IBOutlet UITableView * tblView;
    CGFloat cellHeight;
    CGFloat padding;
    CGFloat commentLabelHeight;
    NSMutableArray * mArrImage;
}

- (IBAction)onBack:(id)sender;
@property (nonatomic, strong) NSMutableDictionary * dicInfo;

@end
