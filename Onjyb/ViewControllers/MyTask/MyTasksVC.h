//
//  MyTasksVC.h
//  Onjyb
//
//  Created by Nadia Drabyk on 7/18/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface MyTasksVC : UIViewController < SlideNavigationControllerDelegate > {
    
    IBOutlet UIButton * btnMenu;
    UILabel * lblBadgeApproveJob;
    UILabel * lblBadgeCompleteTask;
    UIView * dimView;
}

- (IBAction)onMenu:(id)sender;


@end
