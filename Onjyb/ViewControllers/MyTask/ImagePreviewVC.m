//
//  ImagePreviewVC.m
//  Onjyb
//
//  Created by Nadia Drabyk on 7/26/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import "ImagePreviewVC.h"

@interface ImagePreviewVC ()

@end

@implementation ImagePreviewVC

@synthesize imgContent;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [btnClose setTitle:AMLocalizedString(@"Close", @"Close") forState:UIControlStateNormal];
    btnClose.layer.cornerRadius = 3.f;
    btnClose.layer.borderWidth = 1.5f;
    btnClose.layer.borderColor = [UIColor whiteColor].CGColor;
    CGFloat height = 30.f;
    if (global_screen_size.width < 330)
    {
        [btnClose.titleLabel setFont:[UIFont boldSystemFontOfSize:15.f]];
        height = 30.f;
    }
    else
    {
        [btnClose.titleLabel setFont:[UIFont boldSystemFontOfSize:17.f]];
    }
    [btnClose setFrame:CGRectMake(global_screen_size.width - 20 - height * 2.2, 20, height * 2.2, height)];
    [img setImage:imgContent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Actions
- (IBAction)onClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
