//
//  MineHoursVC.h
//  Onjyb
//
//  Created by Nadia Drabyk on 7/19/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface MineHoursVC : UIViewController < SlideNavigationControllerDelegate > {
    UIView * dimView;
    UILabel * lblBadgeApproved;
    UILabel * lblBadgePending;
    UILabel * lblBadgeNotApproved;

//    int m_nApproved;
//    int m_nPending;
//    int m_nNotApproved;
//
//    NSMutableArray * mAryApproved;
//    NSMutableArray * mAryPending;
//    NSMutableArray * mAryNotApproved;

}

- (IBAction)onMenu:(id)sender;
- (void) onPending;
- (void) onApproved;

@end
