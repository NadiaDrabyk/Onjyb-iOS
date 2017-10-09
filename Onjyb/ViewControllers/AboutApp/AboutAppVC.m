//
//  AboutAppVC.m
//  Onjyb
//
//  Created by Nadia Drabyk on 7/19/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import "AboutAppVC.h"

@interface AboutAppVC ()

@end

@implementation AboutAppVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setTitle:AMLocalizedString(@"About App", @"About App")];
    
    dimView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, global_screen_size.width, global_screen_size.height)];
    [dimView setBackgroundColor:[UIColor blackColor]];
    [dimView setAlpha:0.6];
    [self.view addSubview:dimView];
    
    CGFloat y = 70;
    if (global_screen_size.width < 330)
    {
        [lblDescription setFont:[UIFont boldSystemFontOfSize:14.f]];
        [lblMore setFont:[UIFont boldSystemFontOfSize:14.f]];
        [btnUrl.titleLabel setFont:[UIFont boldSystemFontOfSize:13.f]];
        [btnMail.titleLabel setFont:[UIFont boldSystemFontOfSize:13.f]];
        y = 40;
    }
    UIImageView * imgLogo = [[UIImageView alloc] initWithFrame:CGRectMake(global_screen_size.width / 2 - global_screen_size.width / 4, y, global_screen_size.width / 2, global_screen_size.width / 2 * 525 / 939)];
    [imgLogo setImage:[UIImage imageNamed:@"loginLogo"]];
    [self.view addSubview:imgLogo];

    lblDescription.text = AMLocalizedString(@"Onjyb is a user-friendly and simple app for time tracking and leave and vecation for the employees. This app was developed in collaboration with appbusinesspartner, construction companies, rental of excavator, scaffolding companies and plumbers etc. in Eastern Norway.", nil);
    lblMore.text = AMLocalizedString(@"More on this please visit our site:", nil);

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    
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
- (IBAction)onMenu:(id)sender
{
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
}

- (IBAction)onUrl:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.onjyb.com"]];
}
- (IBAction)onMail:(id)sender {
    NSString *subject = [NSString stringWithFormat:@"Support request for Onjyb iPhone App"];
    
    /* define email address */
    NSString *mail = [NSString stringWithFormat:@"support@onjyb.com"];
    
    /* create the URL */
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"mailto:?to=%@&subject=%@",
                                                [mail stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                                                [subject stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
    
    /* load the URL */
    [[UIApplication sharedApplication] openURL:url];
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
