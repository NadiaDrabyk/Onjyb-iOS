//
//  ExtraWorkVC.h
//  Onjyb
//
//  Created by Nadia Drabyk on 7/18/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface ExtraWorkVC : UIViewController < UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate > {
    
    IBOutlet UIButton * btnBack;
    IBOutlet UITableView * tblView;
}

- (IBAction)onBack:(id)sender;

@end
