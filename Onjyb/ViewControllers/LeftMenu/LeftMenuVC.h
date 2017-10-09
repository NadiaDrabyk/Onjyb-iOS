//
//  LeftMenuVC.h
//  Onjyb
//
//  Created by Nadia Drabyk on 7/16/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface LeftMenuVC : UIViewController < UITableViewDelegate, UITableViewDataSource > {
    
    IBOutlet UIButton * btnEdit;
    IBOutlet UIButton * btnLogout;
    IBOutlet UILabel * lblVersion;
    

    UILabel * lblName;
    UILabel * lblPhone;
    IBOutlet UIView * viewTop;
    IBOutlet UIView * viewBottom;
    CGFloat cellHeight;
}

- (IBAction)onLogout:(id)sender;
- (IBAction)onEdit:(id)sender;

- (void) refreshProfiles;
- (void) refreshTables;

@property (nonatomic, strong) IBOutlet UITableView *tblView;
@property (nonatomic, assign) BOOL slideOutAnimationEnabled;
@property (nonatomic, strong) UIImageView * imgProfile;
@property (nonatomic, strong) UIImageView * imgCompany;

@end
