//
//  RejectVC.h
//  Onjyb
//
//  Created by Nadia Drabyk on 8/5/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface RejectVC : UIViewController < UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UITextViewDelegate > {
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
    UITextView * txtRejectComment;
    BOOL flagKeyboardAnimate;
    CGFloat offsetAnimation;
}

- (IBAction)onBack:(id)sender;
@property(nonatomic, strong) NSMutableDictionary * dicInfo;

@end
