//
//  MyTasksVC.m
//  Onjyb
//
//  Created by Nadia Drabyk on 7/18/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import "MyTasksVC.h"
#import "CompletedTaskVC.h"
#import "ApprovedJobsVC.h"
#import "ApproveLeavesVC.h"
#import "PastLeaveVC.h"

@interface MyTasksVC ()

@end

@implementation MyTasksVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:AMLocalizedString(@"My Tasks", @"My Tasks")];
    
    UIView * viewApproveJobs = [[UIView alloc] initWithFrame:CGRectMake(global_screen_size.width / 3, global_screen_size.height / 2 - global_screen_size.width / 6 - 32, global_screen_size.width / 3, global_screen_size.width / 3)];
    [viewApproveJobs setBackgroundColor:[UIColor clearColor]];
    viewApproveJobs.layer.borderColor = global_nav_color.CGColor;
    viewApproveJobs.layer.borderWidth = 2.f;
    
    UIImageView * imgApproveJob = [[UIImageView alloc] initWithFrame:CGRectMake(viewApproveJobs.frame.size.width * 3 / 8, viewApproveJobs.frame.size.width / 3 - viewApproveJobs.frame.size.width / 8, viewApproveJobs.frame.size.width / 4, viewApproveJobs.frame.size.width / 4)];
    [imgApproveJob setImage:[UIImage imageNamed:@"pending"]];
    [viewApproveJobs addSubview:imgApproveJob];
    
    UILabel * lblApproveJob = [[UILabel alloc] initWithFrame:CGRectMake(0, viewApproveJobs.frame.size.width / 2, viewApproveJobs.frame.size.width, viewApproveJobs.frame.size.height / 2)];
    [lblApproveJob setText:AMLocalizedString(@"Approve Jobs", @"Approve Jobs")];
    [lblApproveJob setTextColor:global_nav_color];
    [lblApproveJob setTextAlignment:NSTextAlignmentCenter];
    [viewApproveJobs addSubview:lblApproveJob];
    
    UIButton * btnApproveJob = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, viewApproveJobs.frame.size.width, viewApproveJobs.frame.size.height)];
    [btnApproveJob setBackgroundColor:[UIColor clearColor]];
    [btnApproveJob addTarget:self action:@selector(onApproveJob) forControlEvents:UIControlEventTouchUpInside];
    [viewApproveJobs addSubview:btnApproveJob];
    
    [self.view addSubview:viewApproveJobs];
    
    CGFloat pad = 30.f;
    if (global_screen_size.width < 330) {
        pad = 20.f;
    }
    
    UIView * viewCompletedTask = [[UIView alloc] initWithFrame:CGRectMake(viewApproveJobs.frame.origin.x, viewApproveJobs.frame.origin.y - pad - viewApproveJobs.frame.size.height, viewApproveJobs.frame.size.width, viewApproveJobs.frame.size.height)];
    [viewCompletedTask setBackgroundColor:[UIColor clearColor]];
    viewCompletedTask.layer.borderColor = global_green_color.CGColor;
    viewCompletedTask.layer.borderWidth = 2.f;
    
    UIImageView * imgCompleteTask = [[UIImageView alloc] initWithFrame:CGRectMake(viewApproveJobs.frame.size.width * 3 / 8, viewApproveJobs.frame.size.width / 3 - viewApproveJobs.frame.size.width / 8, viewApproveJobs.frame.size.width / 4, viewApproveJobs.frame.size.width / 4)];
    [imgCompleteTask setImage:[UIImage imageNamed:@"approved"]];
    [viewCompletedTask addSubview:imgCompleteTask];
    
    UILabel * lblCompleteTask = [[UILabel alloc] initWithFrame:CGRectMake(0, viewApproveJobs.frame.size.width / 2, viewApproveJobs.frame.size.width, viewApproveJobs.frame.size.height / 2)];
    [lblCompleteTask setText:AMLocalizedString(@"Completed Tasks", @"Completed Tasks")];
    [lblCompleteTask setTextColor:global_green_color];
    [lblCompleteTask setTextAlignment:NSTextAlignmentCenter];
    [viewCompletedTask addSubview:lblCompleteTask];
    
    UIButton * btnCompleteTask = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, viewApproveJobs.frame.size.width, viewApproveJobs.frame.size.height)];
    [btnCompleteTask setBackgroundColor:[UIColor clearColor]];
    [btnCompleteTask addTarget:self action:@selector(onCompletedTask) forControlEvents:UIControlEventTouchUpInside];
    [viewCompletedTask addSubview:btnCompleteTask];
    [self.view addSubview:viewCompletedTask];
    
    UIView * viewApproveLeave = [[UIView alloc] initWithFrame:CGRectMake((global_screen_size.width - 30) / 4, global_screen_size.height - 94 - (global_screen_size.width - 30) / 4, (global_screen_size.width - 30) / 4, (global_screen_size.width - 30) / 4)];
    [viewApproveLeave setBackgroundColor:[UIColor clearColor]];
    viewApproveLeave.layer.borderColor = global_nav_color.CGColor;
    viewApproveLeave.layer.borderWidth = 2.f;
    viewApproveLeave.layer.cornerRadius = viewApproveLeave.frame.size.width / 2;
    viewApproveLeave.layer.masksToBounds = YES;
    
    
    UIImageView * imgApproveLeave = [[UIImageView alloc] initWithFrame:CGRectMake(viewApproveLeave.frame.size.width * 3 / 8, viewApproveLeave.frame.size.width / 8, viewApproveLeave.frame.size.width / 4, viewApproveLeave.frame.size.width / 4)];
    [imgApproveLeave setImage:[UIImage imageNamed:@"pending"]];
    [viewApproveLeave addSubview:imgApproveLeave];
    
    UILabel * lblApproveLeave = [[UILabel alloc] initWithFrame:CGRectMake(viewApproveLeave.frame.size.width / 6, viewApproveLeave.frame.size.width / 2.5, viewApproveLeave.frame.size.width * 4 / 6, viewApproveLeave.frame.size.width / 2)];
    [lblApproveLeave setTextColor:global_nav_color];
    [lblApproveLeave setText:AMLocalizedString(@"Approve\nLeaves", @"Approve\nLeaves")];
    [lblApproveLeave setNumberOfLines:2];
    [lblApproveLeave setTextAlignment:NSTextAlignmentCenter];
    [viewApproveLeave addSubview:lblApproveLeave];
    
    UIButton * btnApproveLeave = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, viewApproveLeave.frame.size.width, viewApproveLeave.frame.size.width)];
    [btnApproveLeave setBackgroundColor:[UIColor clearColor]];
    btnApproveLeave.layer.cornerRadius = btnApproveLeave.frame.size.width / 2;
    btnApproveLeave.layer.masksToBounds = YES;
    [btnApproveLeave addTarget:self action:@selector(onApproveLeave) forControlEvents:UIControlEventTouchUpInside];
    [viewApproveLeave addSubview:btnApproveLeave];
    
    [self.view addSubview:viewApproveLeave];
    
    
    UIView * viewPastLeave = [[UIView alloc] initWithFrame:CGRectMake(global_screen_size.width / 2 + 15, global_screen_size.height - 94 - (global_screen_size.width - 30) / 4, (global_screen_size.width - 30) / 4, (global_screen_size.width - 30) / 4)];
    [viewPastLeave setBackgroundColor:[UIColor clearColor]];
    viewPastLeave.layer.borderColor = global_green_color.CGColor;
    viewPastLeave.layer.borderWidth = 2.f;
    viewPastLeave.layer.cornerRadius = viewApproveLeave.frame.size.width / 2;
    viewPastLeave.layer.masksToBounds = YES;
    
    
    UIImageView * imgPastLeave = [[UIImageView alloc] initWithFrame:CGRectMake(viewApproveLeave.frame.size.width * 3 / 8, viewApproveLeave.frame.size.width / 8, viewApproveLeave.frame.size.width / 4, viewApproveLeave.frame.size.width / 4)];
    [imgPastLeave setImage:[UIImage imageNamed:@"approved"]];
    [viewPastLeave addSubview:imgPastLeave];
    
    UILabel * lblPastLeave = [[UILabel alloc] initWithFrame:CGRectMake(viewApproveLeave.frame.size.width / 6, viewApproveLeave.frame.size.width / 2.5, viewApproveLeave.frame.size.width * 4 / 6, viewApproveLeave.frame.size.width / 2)];
    [lblPastLeave setTextColor:global_green_color];
    [lblPastLeave setText:AMLocalizedString(@"Past\nLeaves", @"Past\nLeaves")];
    [lblPastLeave setNumberOfLines:2];
    [lblPastLeave setTextAlignment:NSTextAlignmentCenter];
    [viewPastLeave addSubview:lblPastLeave];
    
    UIButton * btnPastLeave = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, viewApproveLeave.frame.size.width, viewApproveLeave.frame.size.width)];
    [btnPastLeave setBackgroundColor:[UIColor clearColor]];
    btnPastLeave.layer.cornerRadius = btnPastLeave.frame.size.width / 2;
    btnPastLeave.layer.masksToBounds = YES;
    [btnPastLeave addTarget:self action:@selector(onPastLeave) forControlEvents:UIControlEventTouchUpInside];
    [viewPastLeave addSubview:btnPastLeave];
    [self.view addSubview:viewPastLeave];
    lblBadgeApproveJob = [[UILabel alloc] initWithFrame:CGRectMake(viewApproveJobs.frame.size.width + viewApproveJobs.frame.origin.x - pad / 2, viewApproveJobs.frame.origin.y - pad / 2, pad, pad)];
    [lblBadgeApproveJob setBackgroundColor:global_red_color];
    [lblBadgeApproveJob setTextColor:[UIColor whiteColor]];
    lblBadgeApproveJob.layer.cornerRadius = lblBadgeApproveJob.frame.size.width / 2;
    lblBadgeApproveJob.layer.masksToBounds = YES;
    if (g_countUnreadApproveJobs == 0)
    {
        [lblBadgeApproveJob setHidden:YES];
    }
    else
    {
        [lblBadgeApproveJob setHidden:NO];
        [lblBadgeApproveJob setText:[NSString stringWithFormat:@"%d", g_countUnreadApproveJobs]];
    }
    
    [lblBadgeApproveJob setTextAlignment:NSTextAlignmentCenter];
    
    lblBadgeCompleteTask = [[UILabel alloc] initWithFrame:CGRectMake(viewCompletedTask.frame.size.width + viewCompletedTask.frame.origin.x - pad / 2, viewCompletedTask.frame.origin.y - pad / 2, pad, pad)];
    [lblBadgeCompleteTask setBackgroundColor:global_red_color];
    [lblBadgeCompleteTask setTextColor:[UIColor whiteColor]];
    lblBadgeCompleteTask.layer.cornerRadius = lblBadgeApproveJob.frame.size.width / 2;
    lblBadgeCompleteTask.layer.masksToBounds = YES;
    [lblBadgeCompleteTask setTextAlignment:NSTextAlignmentCenter];
    if (g_countUnreadCompleteTasks == 0)
    {
        [lblBadgeCompleteTask setHidden:YES];
    }
    else
    {
        [lblBadgeCompleteTask setHidden:NO];
        [lblBadgeCompleteTask setText:[NSString stringWithFormat:@"%d", g_countUnreadCompleteTasks]];
    }
    [self.view addSubview:lblBadgeApproveJob];
    [self.view addSubview:lblBadgeCompleteTask];
    
    if (global_screen_size.width < 330)
    {
        [lblBadgeApproveJob setFont:[UIFont systemFontOfSize:13.f]];
        [lblBadgeCompleteTask setFont:[UIFont systemFontOfSize:13.f]];
        [lblApproveJob setFont:[UIFont boldSystemFontOfSize:12.f]];
        [lblCompleteTask setFont:[UIFont boldSystemFontOfSize:12.f]];
        [lblApproveLeave setFont:[UIFont boldSystemFontOfSize:10.f]];
        [lblPastLeave setFont:[UIFont boldSystemFontOfSize:10.f]];
    }
    else {
        [lblBadgeApproveJob setFont:[UIFont systemFontOfSize:16.f]];
        [lblBadgeCompleteTask setFont:[UIFont systemFontOfSize:16.f]];
        [lblApproveJob setFont:[UIFont boldSystemFontOfSize:14.f]];
        [lblCompleteTask setFont:[UIFont boldSystemFontOfSize:14.f]];
        [lblApproveLeave setFont:[UIFont boldSystemFontOfSize:12.f]];
        [lblPastLeave setFont:[UIFont boldSystemFontOfSize:12.f]];
    }
    dimView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, global_screen_size.width, global_screen_size.height)];
    [dimView setBackgroundColor:[UIColor blackColor]];
    [dimView setAlpha:0.6];
    [self.view addSubview:dimView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    if (g_countUnreadApproveJobs == 0)
    {
        [lblBadgeApproveJob setHidden:YES];
    }
    else
    {
        [lblBadgeApproveJob setHidden:NO];
        [lblBadgeApproveJob setText:[NSString stringWithFormat:@"%d", g_countUnreadApproveJobs]];
    }
    if (g_countUnreadCompleteTasks == 0)
    {
        [lblBadgeCompleteTask setHidden:YES];
    }
    else
    {
        [lblBadgeCompleteTask setHidden:NO];
        [lblBadgeCompleteTask setText:[NSString stringWithFormat:@"%d", g_countUnreadCompleteTasks]];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openMenu:) name:global_notification_slide_open object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(revealMenu:) name:global_notification_slide_reveal object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeMenu:) name:global_notification_slide_close object:nil];
    [dimView setHidden:YES];
    
}

- (void) viewWillDisappear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:global_notification_slide_close object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:global_notification_slide_open object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:global_notification_slide_reveal object:nil];
}

#pragma mark - Button Actions

- (IBAction)onMenu:(id)sender {
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
}
- (void)onCompletedTask {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    CompletedTaskVC * vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"CompletedTaskVC"];
    
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)onApproveJob {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    ApprovedJobsVC * vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"ApprovedJobsVC"];
    
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)onApproveLeave {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    ApproveLeavesVC * vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"ApproveLeavesVC"];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}
- (void)onPastLeave {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    PastLeaveVC * vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"PastLeaveVC"];
    
    [self.navigationController pushViewController:vc animated:YES];
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


@end
