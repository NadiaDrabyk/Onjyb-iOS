//
//  GroupChatVC.h
//  Onjyb
//
//  Created by Nadia Drabyk on 7/19/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "EGORefreshTableHeaderView.h"

@interface GroupChatVC : UIViewController < SlideNavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, EGORefreshTableHeaderDelegate, UITextViewDelegate, UIGestureRecognizerDelegate > {
    UIView * dimView;
    UITableView * tblView;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    UIView * viewInput;
    UITextView * txtMessage;
    UIButton * btnSend;
    CGFloat bubbleHeight;
    CGFloat inputViewHeight;
    CGFloat leftPadding;
    int currentPageNumber;
    NSString * lastDate;
    NSString * strMessageSave;
    CGFloat keyboardHeight;
    CGFloat topPadding;
    
    NSMutableArray * aryMessages;
    NSMutableArray * aryUserIDs;
    User * user;
    
    NSTimer * messageTimer;
    
    BOOL scrolledToBottom;
}

- (IBAction)onMenu:(id)sender;
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
