//
//  GroupChatVC.m
//  Onjyb
//
//  Created by Nadia Drabyk on 7/19/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import "GroupChatVC.h"

@interface GroupChatVC ()

@end

@implementation GroupChatVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:AMLocalizedString(@"Group Chat", @"Group Chat")];
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboards)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
    user = [GlobalUtils loadUserObjectWithKey:global_user_info_save];
    [self initViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) viewWillAppear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openMenu:) name:global_notification_slide_open object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(revealMenu:) name:global_notification_slide_reveal object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeMenu:) name:global_notification_slide_close object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    [dimView setHidden:YES];
    
    scrolledToBottom = NO;
    messageTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                     target:self
                                                   selector:@selector(getMessages)
                                                   userInfo:nil
                                                    repeats:YES];

}

- (void) viewWillDisappear:(BOOL)animated {
    if(messageTimer){
        [messageTimer invalidate];
        messageTimer = nil;
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self name:global_notification_slide_close object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:global_notification_slide_open object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:global_notification_slide_reveal object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Button Actions
- (IBAction)onMenu:(id)sender
{
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
}

- (void) onSend {
    [self dismissKeyboards];
    
    NSString* msg = txtMessage.text;
    if (msg.length == 0)
    {
        [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Please input message.", @"Please input message.") cancel:AMLocalizedString(@"Ok", @"Ok")];
        
        return;
    }
    AppDelegate * app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [app showHUD];
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setObject:user.strUserID forKey:global_key_user_id];
    [param setObject:user.strCompanyID forKey:global_key_company_id];
    [param setObject:@"ios" forKey:global_key_os];
    [param setObject:msg forKey:global_key_message];
    
    txtMessage.text = @"";
    //////////
    [MyRequest POST:global_api_sendMessages parameters:param completed:^(id result)
     {
         NSDictionary * dicResult = (NSDictionary*) result;
         if (dicResult == NULL || [dicResult isEqual:[NSNull null]])
         {
             [app hideHUD];
             [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Could not connect with server. Please try again later!", @"Could not connect with server. Please try again later!") cancel:AMLocalizedString(@"Ok", @"Ok")];
             return;
         }
         else
         {
             NSNumber * numRes = [dicResult valueForKey:global_key_res_code];
             if (numRes)
             {
                 if (numRes.intValue == global_result_success)
                 {
                     currentPageNumber = 0;
                     aryMessages = [[NSMutableArray alloc] init];
                     aryUserIDs = [[NSMutableArray alloc] init];
                     [self getMessages];
                     return;

                 }
                 NSString * errorString = AMLocalizedString(@"Error occured.", @"Error occured.");
                 if ([dicResult valueForKey:global_key_res_message])
                 {
                     errorString = [NSString stringWithFormat:@"%@", [dicResult valueForKey:global_key_res_message]];
                 }
                 [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:errorString cancel:AMLocalizedString(@"Ok", @"Ok")];
                 return;
             }
             [app hideHUD];
             NSString * errorString = AMLocalizedString(@"Error occured.", @"Error occured.");
             [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:errorString cancel:AMLocalizedString(@"Ok", @"Ok")];
             return;
         }

     }];
  
}

#pragma mark - SlideNavigationController Methods -

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

#pragma mark -Notification

- (void)openMenu:(NSNotification*) noti {
    [dimView setAlpha:0.6];
    [dimView setHidden:NO];
}
- (void)closeMenu:(NSNotification*) noti {
    
    [dimView setAlpha:0.0];
    [dimView setHidden:YES];
}
- (void)revealMenu:(NSNotification*) noti {
    NSDictionary * dicProgress = (NSDictionary*) noti.object;
    if (dicProgress == NULL || [dicProgress isEqual:[NSNull null]]) {
        return;
    }
    NSString * strProgress = [dicProgress valueForKey:global_key_slide_progress];
    if (strProgress && strProgress.length > 0) {
        [dimView setAlpha:strProgress.floatValue/2+ 0.1];
        [dimView setHidden:NO];
    }
}

#pragma mark - Table View Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!aryMessages) aryMessages = [[NSMutableArray alloc] init];
    return aryMessages.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!aryMessages || aryMessages.count == 0) return 0;
    UIFont * font;
    if (global_screen_size.width < 330)
    {
        font = [UIFont boldSystemFontOfSize:13.f];
    }
    else
    {
        font = [UIFont boldSystemFontOfSize:15.f];
    }
    int maxWidth = global_screen_size.width - leftPadding * 6 - bubbleHeight;
    CGSize size;
    
    UILabel * lbl = [[UILabel alloc] initWithFrame:CGRectMake(100, 17, 1, 1)];
    NSDictionary * dicCell = [aryMessages objectAtIndex:indexPath.row];
    NSString * strID = [dicCell valueForKey:global_key_ref_user_id];
    
    NSString * strMessage;
    if (![strID isEqualToString:user.strUserID])
    {
        strMessage =[NSString stringWithFormat:@"%@ %@\n%@", [dicCell valueForKey:global_key_first_name], [dicCell valueForKey:global_key_last_name], [dicCell valueForKey:global_key_message]];
    }
    else
    {
        strMessage = [dicCell valueForKey:global_key_message];
    }
    [lbl setText:strMessage];
    [lbl setTextColor:[UIColor darkGrayColor]];
    [lbl setFont:font];
    lbl.numberOfLines = 0;
    
    size = [lbl.text sizeWithFont:lbl.font
                constrainedToSize:CGSizeMake(maxWidth, MAXFLOAT)
                    lineBreakMode:NSLineBreakByWordWrapping];
    if (bubbleHeight > size.height + 2 * topPadding)
        return bubbleHeight * 1.5 + topPadding;
    return bubbleHeight / 2 + topPadding + size.height + 2 * topPadding;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatCell"];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"chatCell"];
    }
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [cell.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    cell.backgroundColor = [UIColor clearColor];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    NSDictionary * dicCell = [aryMessages objectAtIndex:indexPath.row];
    NSString * strUserID = [dicCell valueForKey:global_key_ref_user_id];
    BOOL flagImage = NO;
    BOOL flagMe = NO;
    if (indexPath.row == 0)
    {
        flagImage = YES;
    }
    else
    {
        NSString * strIDPrev = [aryUserIDs objectAtIndex:indexPath.row - 1];
        if (![strUserID isEqualToString:strIDPrev])
        {
            flagImage = YES;
        }
    }
    if ([strUserID isEqualToString:user.strUserID])
    {
        flagMe = YES;
    }
    
    UIFont * font;
    if (global_screen_size.width < 330)
    {
        font = [UIFont boldSystemFontOfSize:13.f];
    }
    else
    {
        font = [UIFont boldSystemFontOfSize:15.f];
    }
    int maxWidth = global_screen_size.width - leftPadding * 6 - bubbleHeight;
    CGSize size;
    
    UILabel * lbl = [[UILabel alloc] initWithFrame:CGRectMake(100, 17, 1, 1)];
    NSString * strID = [dicCell valueForKey:global_key_ref_user_id];
    NSString * strMessage;
    if (![strID isEqualToString:user.strUserID])
    {
        strMessage =[NSString stringWithFormat:@"%@ %@\n%@", [dicCell valueForKey:global_key_first_name], [dicCell valueForKey:global_key_last_name], [dicCell valueForKey:global_key_message]];
    }
    else
    {
        strMessage = [dicCell valueForKey:global_key_message];
    }
    [lbl setText:strMessage];
    [lbl setTextColor:[UIColor darkGrayColor]];
    [lbl setFont:font];
    lbl.numberOfLines = 0;
    
    size = [lbl.text sizeWithFont:lbl.font
                constrainedToSize:CGSizeMake(maxWidth, MAXFLOAT)
                    lineBreakMode:NSLineBreakByWordWrapping];
    
    int style = 1;
    if (bubbleHeight > size.height + 2 * topPadding)
        style = 2;
    UIImageView * imgBubble;
    UILabel * lblMessage;
    UILabel * lblDate;
    UIImageView * imgProfile;
    if (flagMe)
    {
        if (style == 1)
            imgBubble= [[UIImageView alloc] initWithFrame:CGRectMake(leftPadding, topPadding, global_screen_size.width - bubbleHeight - leftPadding * 3, size.height + 2 * topPadding)];
        else
            imgBubble= [[UIImageView alloc] initWithFrame:CGRectMake(leftPadding, topPadding, global_screen_size.width - bubbleHeight - leftPadding * 3, bubbleHeight)];
        [imgBubble setBackgroundColor:[UIColor colorWithRed:177/255.f green:244/255.f blue:235/255.f alpha:1.f]];
        lblMessage = [[UILabel alloc] initWithFrame:CGRectMake(leftPadding + imgBubble.frame.origin.x, imgBubble.frame.origin.y + topPadding, imgBubble.frame.size.width - 2 * leftPadding, imgBubble.frame.size.height - 2 * topPadding)];
        lblDate = [[UILabel alloc] initWithFrame:CGRectMake(imgBubble.frame.origin.x, imgBubble.frame.origin.y + imgBubble.frame.size.height, 200, bubbleHeight / 2)];
        if (flagImage)
        {
            imgProfile = [[UIImageView alloc] initWithFrame:CGRectMake(imgBubble.frame.origin.x + imgBubble.frame.size.width + leftPadding, imgBubble.frame.origin.y + imgBubble.frame.size.height - bubbleHeight, bubbleHeight, bubbleHeight)];
            imgProfile.layer.cornerRadius = imgProfile.frame.size.height / 2;
            imgProfile.layer.borderColor = global_nav_color.CGColor;
            imgProfile.layer.borderWidth = 1.f;
            imgProfile.layer.masksToBounds = YES;
        }
        [lblMessage setText:strMessage];
    }
    else
    {
        if (style == 1)
            imgBubble= [[UIImageView alloc] initWithFrame:CGRectMake(leftPadding * 2 + bubbleHeight, topPadding, global_screen_size.width - bubbleHeight - leftPadding * 3, size.height + 2 * topPadding)];
        else
            imgBubble= [[UIImageView alloc] initWithFrame:CGRectMake(leftPadding * 2 + bubbleHeight, topPadding, global_screen_size.width - bubbleHeight - leftPadding * 3, bubbleHeight)];
        [imgBubble setBackgroundColor:[UIColor colorWithRed:255/255.f green:233/255.f blue:207/255.f alpha:1.f]];
        lblMessage = [[UILabel alloc] initWithFrame:CGRectMake(imgBubble.frame.origin.x + leftPadding, imgBubble.frame.origin.y + topPadding, imgBubble.frame.size.width - 2 * leftPadding, imgBubble.frame.size.height - 2 * topPadding)];
        lblDate = [[UILabel alloc] initWithFrame:CGRectMake(imgBubble.frame.origin.x, imgBubble.frame.origin.y + imgBubble.frame.size.height, imgBubble.frame.size.width, bubbleHeight / 2)];
        [lblDate setTextAlignment:NSTextAlignmentRight];
        if (flagImage)
        {
            imgProfile = [[UIImageView alloc] initWithFrame:CGRectMake(leftPadding, imgBubble.frame.origin.y + imgBubble.frame.size.height - bubbleHeight, bubbleHeight, bubbleHeight)];
            imgProfile.layer.cornerRadius = imgProfile.frame.size.height / 2;
            imgProfile.layer.borderColor = global_nav_color.CGColor;
            imgProfile.layer.borderWidth = 1.f;
            imgProfile.layer.masksToBounds = YES;
        }
        NSString * strFirstName = [dicCell valueForKey:global_key_first_name];
        NSString * strLastName = [dicCell valueForKey:global_key_last_name];
        NSMutableAttributedString *attriText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@\n%@", strFirstName, strLastName, [dicCell valueForKey:global_key_message]]];
        [attriText addAttribute: NSForegroundColorAttributeName value: [UIColor redColor] range: NSMakeRange(0, strFirstName.length + 1 + strLastName.length)];
        [attriText addAttribute: NSForegroundColorAttributeName value: global_nav_color range: NSMakeRange(strFirstName.length + 1 + strLastName.length, attriText.length - strFirstName.length - 1 - strLastName.length)];
        [lblMessage setAttributedText: attriText];
    }
    
    imgBubble.layer.cornerRadius = 8.f;
    imgBubble.layer.masksToBounds = YES;

    [lblMessage setTextColor:global_nav_color];
    [lblMessage setNumberOfLines:100];
    
    [lblDate setTextColor:global_darkgray_color];
    NSString * strDateOrg = [dicCell valueForKey:global_key_create_date];
    if (strDateOrg.length >= 16)
    {
        NSRange rng;
        rng.length = 10; rng.location = 0;
        NSString * str10 = [strDateOrg substringWithRange:rng];
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSDate * date = [formatter dateFromString:str10];
        [formatter setDateFormat:@"dd MMM yy"];
        rng.location = 10;
        rng.length = 6;
        NSString * strEnd = [strDateOrg substringWithRange:rng];
        NSString * strDate = [NSString stringWithFormat:@"%@%@", [formatter stringFromDate:date], strEnd];
        [lblDate setText:strDate];
    }
    else
    {
        [lblDate setText:strDateOrg];
    }

    [GlobalUtils setImageForUrlAndSize:imgProfile ID:[dicCell valueForKey:global_key_profile_image] url:[NSString stringWithFormat:@"%@%@", global_url_photo, [dicCell valueForKey:global_key_profile_image]] size:CGSizeMake(imgProfile.frame.size.width, imgProfile.frame.size.width) placeImage:@"avatar" storeDir:global_dir_message];
    
    if (global_screen_size.width < 330)
    {
        [lblMessage setFont:[UIFont boldSystemFontOfSize:13.f]];
        [lblDate setFont:[UIFont systemFontOfSize:13.f]];
    }
    else
    {
        [lblMessage setFont:[UIFont boldSystemFontOfSize:15.f]];
        [lblDate setFont:[UIFont systemFontOfSize:15.f]];
    }
    
    [cell addSubview:imgBubble];
    [cell addSubview:lblMessage];
    [cell addSubview:lblDate];
    [cell addSubview:imgProfile];
    return cell;
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    
    //  should be calling your tableviews data source model to reload
    //  put here just for demo
    _reloading = YES;
    
}

- (void)doneLoadingTableViewData{
    
    //  model should call this when its done loading
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:tblView];
    
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    
    [self reloadTableViewDataSource];
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:1.0];
    currentPageNumber += 1;//20170910
    [self getMessages];
    NSLog(@"OK");
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    
    return _reloading; // should return if data source model is reloading
    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
    return [NSDate date]; // should return date data source was last changed
    
}

#pragma mark - Utils

- (void) initViews{
    keyboardHeight = 260;
    bubbleHeight = global_screen_size.height / 14;
    inputViewHeight = global_screen_size.height / 13.5;
    topPadding = 4.f;
    viewInput = [[UIView alloc] initWithFrame:CGRectMake(0, global_screen_size.height - inputViewHeight - 64, global_screen_size.width, inputViewHeight)];
    [viewInput setBackgroundColor:[UIColor colorWithRed:242/255.f green:242/255.f blue:242/255.f alpha:1.f]];
    [self.view addSubview:viewInput];
    leftPadding = 9.f;
    if (global_screen_size.width < 330)
    {
        leftPadding = 7.f;
    }
    
    txtMessage = [[UITextView alloc] initWithFrame:CGRectMake(leftPadding, leftPadding, viewInput.frame.size.width - inputViewHeight - leftPadding, viewInput.frame.size.height - 2 * leftPadding)];
    txtMessage.layer.borderColor = [UIColor grayColor].CGColor;
    txtMessage.layer.borderWidth = 1.f;
    txtMessage.delegate = self;
    [txtMessage setTextColor:[UIColor colorWithRed:15/255.f green:15/255.f blue:15/255.f alpha:1.f]];
    [viewInput addSubview:txtMessage];
    
    btnSend = [[UIButton alloc] initWithFrame:CGRectMake(viewInput.frame.size.width - inputViewHeight + leftPadding, viewInput.frame.size.height - leftPadding - (inputViewHeight - 2 * leftPadding), (inputViewHeight - 2 * leftPadding), (inputViewHeight - 2 * leftPadding))];
    [btnSend setBackgroundImage:[UIImage imageNamed:@"send"] forState:UIControlStateNormal];
    [btnSend addTarget:self action:@selector(onSend) forControlEvents:UIControlEventTouchUpInside];
    [viewInput addSubview:btnSend];
    
    tblView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, global_screen_size.width, global_screen_size.height - viewInput.frame.size.height - 64)];
    tblView.delegate = self;
    tblView.dataSource = self;
    [tblView setBackgroundColor:[UIColor clearColor]];
    tblView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tblView];

    if (_refreshHeaderView == nil) {
        
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - tblView.bounds.size.height, global_screen_size.width, tblView.bounds.size.height)];
        view.delegate = self;
        [tblView addSubview:view];
        _refreshHeaderView = view;
        
    }
    
    //  update the last update date
    [_refreshHeaderView refreshLastUpdatedDate];
    if (global_screen_size.width < 330)
    {
        [txtMessage setFont:[UIFont boldSystemFontOfSize:14.f]];
    }
    else
    {
        [txtMessage setFont:[UIFont boldSystemFontOfSize:16.f]];
    }
    dimView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, global_screen_size.width, global_screen_size.height)];
    [dimView setBackgroundColor:[UIColor blackColor]];
    [dimView setAlpha:0.6];
    [self.view bringSubviewToFront:viewInput];
    [self.view addSubview:dimView];
    [self getMessages];
}

- (void) getMessages {
    
    AppDelegate * app = (AppDelegate *) [UIApplication sharedApplication].delegate;
    
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setObject:user.strUserID forKey:global_key_user_id];
    [param setObject:user.strCompanyID forKey:global_key_company_id];
    [param setObject:@"" forKey:global_key_approve_status];
    [param setObject:[NSString stringWithFormat:@"%d", currentPageNumber + 1] forKey:global_key_page_number];
    [param setObject:@"ios" forKey:global_key_os];
    [param setObject:@"" forKey:global_key_last_date];
    
    //////////
    [MyRequest POST:global_api_getMessages parameters:param completed:^(id result)
     {
         [app hideHUD];
         NSDictionary * dicResult = (NSDictionary*) result;
         if (dicResult == NULL || [dicResult isEqual:[NSNull null]])
         {
             [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:AMLocalizedString(@"Could not connect with server. Please try again later!", @"Could not connect with server. Please try again later!") cancel:AMLocalizedString(@"Ok", @"Ok")];
             return;
         }
         else
         {
             NSNumber * numRes = [dicResult valueForKey:global_key_res_code];
             if (numRes)
             {
                 if (numRes.intValue == global_result_success)
                 {
                     NSDictionary * dicResObject = [dicResult valueForKey:global_key_res_object];
                     if (dicResObject)
                     {
                         if (!aryMessages)
                             aryMessages = [[NSMutableArray alloc] init];
                         if (!aryUserIDs)
                             aryUserIDs = [[NSMutableArray alloc] init];
                         NSArray * ary = [dicResObject valueForKey:global_key_message_details];
                         
                         if (ary && ary.count)
                         {
                             if (aryMessages.count)
                             {
                                 NSDictionary * dicOne = [aryMessages objectAtIndex:0];
                                 NSString * strID = [dicOne valueForKey:global_key_id];
                                 int i;
                                 for (i = (int)ary.count - 1; i >= 0; i --)
                                 {
                                     NSDictionary * dicEle = [ary objectAtIndex:i];
                                     NSString * strIDEle = [dicEle valueForKey:global_key_id];
                                     if ([strIDEle isEqualToString:strID])
                                     {
                                         break;
                                     }
                                 }
                                 if (i == -1)
                                 {
                                     for (int j = (int)ary.count - 1; j >= 0 ; j --)
                                     {
                                         [aryMessages insertObject:[ary objectAtIndex:j] atIndex:0];
                                     }
                                 }
                                 else
                                 {
                                     for (int j = i - 1; j >= 0; j --)
                                     {
                                         [aryMessages insertObject:[ary objectAtIndex:j] atIndex:0];
                                     }
                                 }
                                 if (i == 0)
                                 {
                                     
                                 }
                                 else
                                 {
                                     aryUserIDs = [[NSMutableArray alloc] init];
                                     NSArray * aryIDs = [aryMessages valueForKey:global_key_ref_user_id];
//                                     currentPageNumber += 1;
                                     aryUserIDs = [aryIDs mutableCopy];
                                     [tblView reloadData];
                                 }
                             }
                             else
                             {
                                 aryMessages = [ary mutableCopy];
                                 NSArray * aryIDs = [aryMessages valueForKey:global_key_ref_user_id];
//                                 currentPageNumber += 1;
                                 aryUserIDs = [aryIDs mutableCopy];
                                 [tblView reloadData];
                             }
                         }
                     }
                 }
                 if(!scrolledToBottom){
                     scrolledToBottom = YES;
                     NSUInteger count = aryMessages.count;
                     if(count>0){
                         NSIndexPath* ipath = [NSIndexPath indexPathForRow:count-1 inSection: 0];
                         [tblView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: NO];

                     }
                         

                 }
                 return;
             }
             NSString * errorString = AMLocalizedString(@"Error occured.", @"Error occured.");
             if ([dicResult valueForKey:global_key_res_message])
             {
                 errorString = [NSString stringWithFormat:@"%@", [dicResult valueForKey:global_key_res_message]];
             }
             [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:errorString cancel:AMLocalizedString(@"Ok", @"Ok")];
             return;
         }
         NSString * errorString = AMLocalizedString(@"Error occured.", @"Error occured.");
         [GlobalUtils showAlertController:self title:AMLocalizedString(@"Onjyb", @"Onjyb") message:errorString cancel:AMLocalizedString(@"Ok", @"Ok")];
     }];

}
- (void) sendMessages {
    
}
#pragma mark - TextViewDelegate

- (void) dismissKeyboards
{
    [txtMessage resignFirstResponder];
}

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    strMessageSave = [[textView text] stringByReplacingCharactersInRange:range withString:text];
    int maxWidth = txtMessage.frame.size.width;
    CGSize size;
    
    UILabel * lbl = [[UILabel alloc] initWithFrame:CGRectMake(100, 17, 1, 1)];
    [lbl setText:strMessageSave];
    [lbl setTextColor:[UIColor darkGrayColor]];
    [lbl setFont:txtMessage.font];
    lbl.numberOfLines = 0;
    
    size = [lbl.text sizeWithFont:txtMessage.font
                constrainedToSize:CGSizeMake(maxWidth, MAXFLOAT)
                    lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat heightAdding = ((int)(ceil(size.height / txtMessage.font.lineHeight))  - 1)* txtMessage.font.lineHeight;
    if ((int)(ceil(size.height / txtMessage.font.lineHeight))  - 1 >= 4) {
        heightAdding = 3 * txtMessage.font.lineHeight;
    }
    
    [viewInput setFrame:CGRectMake(viewInput.frame.origin.x, global_screen_size.height - 64 - inputViewHeight - heightAdding - keyboardHeight, viewInput.frame.size.width, inputViewHeight + heightAdding)];
    
    [txtMessage setFrame:CGRectMake(leftPadding, leftPadding, viewInput.frame.size.width - inputViewHeight - leftPadding, viewInput.frame.size.height - 2 * leftPadding)];
    [btnSend setFrame:CGRectMake(btnSend.frame.origin.x, viewInput.frame.size.height - leftPadding - btnSend.frame.size.height, btnSend.frame.size.width, btnSend.frame.size.height)];
    [tblView setFrame:CGRectMake(0, 0, global_screen_size.width, viewInput.frame.origin.y)];
    
    return YES;
}
- (BOOL) textViewShouldEndEditing:(UITextView *)textView
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.15];
    [viewInput setFrame:CGRectMake(viewInput.frame.origin.x, global_screen_size.height - 64 - viewInput.frame.size.height, viewInput.frame.size.width, viewInput.frame.size.height)];
    [tblView setFrame:CGRectMake(tblView.frame.origin.x, tblView.frame.origin.y, tblView.frame.size.width, global_screen_size.height - viewInput.frame.size.height - 64)];
    [UIView commitAnimations];
    return YES;
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.15];
//    [viewInput setFrame:CGRectMake(viewInput.frame.origin.x, viewInput.frame.origin.y - keyboardHeight, viewInput.frame.size.width, viewInput.frame.size.height)];
//    [tblView setFrame:CGRectMake(tblView.frame.origin.x, tblView.frame.origin.y, tblView.frame.size.width, viewInput.frame.origin.y)];
//    [UIView commitAnimations];
    return YES;
}
- (void) onKeyboardShow:(id)sender {
    CGSize keyboardSize = [[[sender userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    //Given size may not account for screen rotation
    int height = MIN(keyboardSize.height,keyboardSize.width);
    keyboardHeight = height;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [viewInput setFrame:CGRectMake(viewInput.frame.origin.x, viewInput.frame.origin.y - height, viewInput.frame.size.width, viewInput.frame.size.height)];
    [tblView setFrame:CGRectMake(tblView.frame.origin.x, tblView.frame.origin.y, tblView.frame.size.width, viewInput.frame.origin.y)];
    if (tblView.contentSize.height > tblView.frame.size.height) {
        [tblView setContentOffset:CGPointMake(tblView.contentOffset.x, tblView.contentSize.height - tblView.frame.size.height)];
    }
    [UIView commitAnimations];
    
}
- (void) onKeyboardHide:(id)sender {
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView commitAnimations];
}

@end
