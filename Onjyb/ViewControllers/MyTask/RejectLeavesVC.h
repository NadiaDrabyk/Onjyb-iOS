//
//  RejectLeavesVC.h
//  Onjyb
//
//  Created by bold on 9/11/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface RejectLeavesVC : UIViewController < UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UITextViewDelegate > {
    IBOutlet UITableView * tblView;
    IBOutlet UILabel * lblTop;
    CGFloat cellHeight;
    CGFloat padding;
    CGFloat commentEmployeeLabelHeight, commentManagerLabelHeight;
    
    UITextView* tvManagerNote;
    UIButton *btnApprove;
    UIButton *btnReject;
}

- (IBAction)onBack:(id)sender;
@property(nonatomic, strong) NSMutableDictionary * dicInfo;


@end
