//
//  MyLeavesDetailVC.m
//  Onjyb
//
//  Created by Nadia Drabyk on 7/19/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import "MyLeavesDetailVC.h"

@interface MyLeavesDetailVC ()

@end

@implementation MyLeavesDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:AMLocalizedString(@"My Task", @"My Task")];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Actions
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table View Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPah
{
    return nil;
}

@end
