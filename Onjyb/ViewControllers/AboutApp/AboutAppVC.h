//
//  AboutAppVC.h
//  Onjyb
//
//  Created by Nadia Drabyk on 7/19/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface AboutAppVC : UIViewController < SlideNavigationControllerDelegate >
{
    UIView * dimView;
    IBOutlet UILabel * lblDescription;
    IBOutlet UILabel * lblMore;
    IBOutlet UIButton * btnUrl;
    IBOutlet UIButton * btnMail;
}

- (IBAction)onMenu:(id)sender;
- (IBAction)onUrl:(id)sender;
- (IBAction)onMail:(id)sender;

@end
