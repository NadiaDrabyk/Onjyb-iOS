//
//  RightMenuVC.m
//  Onjyb
//
//  Created by Nadia Drabyk on 7/19/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import "RightMenuVC.h"

@interface RightMenuVC ()

@end

@implementation RightMenuVC

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self.slideOutAnimationEnabled = YES;
    
    return [super initWithCoder:aDecoder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboards)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [self initViews];
}
- (void) viewWillDisappear:(BOOL)animated {
    [self dismissKeyboards];
}
#pragma mark - Button Actions

- (void) onClear{
    [self dismissKeyboards];
    [self initViews];
    NSMutableDictionary * dicMut = [[NSMutableDictionary alloc] init];
    [dicMut setValue:@"" forKey:global_key_start_date];
    [dicMut setValue:@"" forKey:global_key_end_date];
    [dicMut setValue:@"" forKey:global_key_project_id];
    [dicMut setValue:@"" forKey:global_key_employee_id];
    [[NSNotificationCenter defaultCenter] postNotificationName:global_notification_apply_right_menu object:dicMut];
    [[SlideNavigationController sharedInstance] toggleRightMenu];
}
- (void) onApply{
    [self dismissKeyboards];
    NSMutableDictionary * dicMut = [[NSMutableDictionary alloc] init];
    NSString * str = btnStart.titleLabel.text;
    if ([str isEqualToString:AMLocalizedString(@"Start Date", @"Start Date")])
    {
        [dicMut setValue:@"" forKey:global_key_start_date];
    }
    else
    {
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd MMM yy"];
        NSDate * date = [formatter dateFromString:str];
        [formatter setDateFormat:@"dd/MM/yyyy"];
        NSString * strDateSave = [formatter stringFromDate:date];
        [dicMut setValue:strDateSave forKey:global_key_start_date];
    }
    str = btnEnd.titleLabel.text;
    if ([str isEqualToString:AMLocalizedString(@"End Date", @"End Date")])
    {
        [dicMut setValue:@"" forKey:global_key_end_date];
    }
    else
    {
        
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd MMM yy"];
        NSDate * date = [formatter dateFromString:str];
        [formatter setDateFormat:@"dd/MM/yyyy"];
        NSString * strDateSave = [formatter stringFromDate:date];
        
        [dicMut setValue:strDateSave forKey:global_key_end_date];
    }
    
    if (txtProject.text.length == 0)
    {
        [dicMut setValue:@"" forKey:global_key_project_id];
    }
    else
    {
//        NSString * strIndex = [mAryFilteredIndexProjects objectAtIndex:selectedProjectIndex];
//        int index = strIndex.intValue;
//        if(index < 0 || index >= mArayProjects.count)
//            [dicMut setValue:@"" forKey:global_key_project_id];
//        else
        {
            NSDictionary * dic = [mArayProjects objectAtIndex:selectedProjectIndex];
            [dicMut setValue:[dic valueForKey:global_key_project_id] forKey:global_key_project_id];
        }
    }

    if (txtEmployee.text.length == 0)
    {
        [dicMut setValue:@"" forKey:global_key_employee_id];
    }
    else
    {
//        NSString * strIndex = [mAryFilteredIndexEmployee objectAtIndex:selectedEmployeeIndex];
//        int index = strIndex.intValue;
//        if(index < 0 || index >= mArayEmployee.count)
//            [dicMut setValue:@"" forKey:global_key_employee_id];
//        else
        {
            NSDictionary * dic = [mArayEmployee objectAtIndex:selectedEmployeeIndex];
            [dicMut setValue:[dic valueForKey:global_key_employee_id] forKey:global_key_employee_id];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:global_notification_apply_right_menu object:dicMut];
    [[SlideNavigationController sharedInstance] toggleRightMenu];
}
- (void) onStart{
    [self dismissKeyboards];
    [txtStart becomeFirstResponder];
}
- (void) OnEnd{
    [self dismissKeyboards];
    [txtEnd becomeFirstResponder];
}

-(void)onProject:(UIButton *) btn
{
    NSString * strIndex = [mAryFilteredIndexProjects objectAtIndex:btn.tag];
    selectedProjectIndex = strIndex.intValue;
    strFilterProjects = [mAryFilteredContentProjects objectAtIndex:btn.tag];
    [txtProject setText:strFilterProjects];
    [self dismissKeyboards];
}

-(void)onEmployee:(UIButton *) btn
{
    NSString * strIndex = [mAryFilteredIndexEmployee objectAtIndex:btn.tag];
    selectedEmployeeIndex = strIndex.intValue;
    strFilterEmployee = [mAryFilteredContentEmployee objectAtIndex:btn.tag];
    [txtEmployee setText:strFilterEmployee];
    [self dismissKeyboards];
}

- (void) onDatePickerDone {
    if ([txtStart isFirstResponder])
    {
        NSDate * date = mPickerStart.date;
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
//        [formatter setDateFormat:@"dd/MM/yyyy"];
//        strDateSave = [formatter stringFromDate:date];
        [formatter setDateFormat:@"dd MMM yy"];
        NSString * str = [formatter stringFromDate:date];
        [btnStart setTitle:[NSString stringWithFormat:@"%@", str] forState:UIControlStateNormal];
    }
    if ([txtEnd isFirstResponder])
    {
        NSDate * date = mPickerEnd.date;
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd MMM yy"];
        NSString * str = [formatter stringFromDate:date];
        [btnEnd setTitle:[NSString stringWithFormat:@"%@", str] forState:UIControlStateNormal];
    }
    [self dismissKeyboards];
}

#pragma mark - Utils

- (void) initViews {
    
    selectedProjectIndex = -1;
    selectedEmployeeIndex = -1;
    [self.view.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    viewTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, global_screen_size.width, 64)];
    [viewTop setBackgroundColor:global_blue_color];
    [self.view addSubview:viewTop];
    leftPadding = 14.f;
    topPadding = 18.f;
    if (global_screen_size.width < 330)
    {
        leftPadding = 10.f;
        topPadding = 14.f;
    }
    
    btnClear = [[UIButton alloc] initWithFrame:CGRectMake(leftPadding * 3 + 60, 7 + 20, (global_screen_size.width - 60 - leftPadding * 5) / 2, 30)];
    [btnClear setBackgroundColor:[UIColor whiteColor]];
    [btnClear setTitle:AMLocalizedString(@"Clear", @"Clear") forState:UIControlStateNormal];
    [btnClear setTitleColor:global_nav_color forState:UIControlStateNormal];
    btnClear.layer.cornerRadius = 3.f;
    btnClear.layer.masksToBounds = YES;
    [btnClear addTarget:self action:@selector(onClear) forControlEvents:UIControlEventTouchUpInside];
    [viewTop addSubview:btnClear];
    
    btnApply = [[UIButton alloc] initWithFrame:CGRectMake(btnClear.frame.origin.x + btnClear.frame.size.width + leftPadding, btnClear.frame.origin.y, btnClear.frame.size.width, btnClear.frame.size.height)];
    [btnApply setBackgroundColor:[UIColor whiteColor]];
    [btnApply setTitle:AMLocalizedString(@"Apply", @"Apply") forState:UIControlStateNormal];
    [btnApply setTitleColor:global_nav_color forState:UIControlStateNormal];
    btnApply.layer.cornerRadius = 3.f;
    btnApply.layer.masksToBounds = YES;
    [btnApply addTarget:self action:@selector(onApply) forControlEvents:UIControlEventTouchUpInside];
    [viewTop addSubview:btnApply];
    
    CGFloat hTextField = global_screen_size.width / 11;
    txtProject = [[UITextField alloc] initWithFrame:CGRectMake(60 + leftPadding, viewTop.frame.size.height + 2 * topPadding, global_screen_size.width / 2, hTextField)];
    [txtProject setTextColor:[UIColor grayColor]];
    txtProject.placeholder = AMLocalizedString(@"Select Project", @"Select Project");
    txtProject.delegate = self;
    txtProject.layer.cornerRadius = 4.f;
    txtProject.layer.masksToBounds = YES;
    txtProject.layer.borderColor = global_darkgray_color.CGColor;
    txtProject.layer.borderWidth = 1.f;
    [self.view addSubview:txtProject];
    {
        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 26, hTextField)];
        btnClearTxtProject = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnClearTxtProject setFrame:CGRectMake(0, (hTextField - 20)/2, 20, 20)];
        [btnClearTxtProject setImage:[UIImage imageNamed:@"circle_close"] forState:UIControlStateNormal];
        [btnClearTxtProject addTarget:self action:@selector(clearTextField:) forControlEvents:UIControlEventTouchUpInside];
        [rightView addSubview:btnClearTxtProject];
        btnClearTxtProject.hidden = YES;
        
//        UIButton *btnArrow = [UIButton buttonWithType:UIButtonTypeCustom];
//        [btnArrow setFrame:CGRectMake(20, (hTextField - 24)/2, 24, 24)];
//        [btnArrow setImage:[UIImage imageNamed:@"gray_down_arrow"] forState:UIControlStateNormal];
//        //        [btnArrow addTarget:self action:@selector(arrowTextField:) forControlEvents:UIControlEventTouchUpInside];
//        [rightView addSubview:btnArrow];
        txtProject.rightView = rightView;
        txtProject.rightViewMode = UITextFieldViewModeAlways;
    }
    
    
    
    btnProjectHeight = txtProject.frame.size.height;
    viewProject = [[UIScrollView alloc] initWithFrame:CGRectMake(txtProject.frame.origin.x, txtProject.frame.origin.y + txtProject.frame.size.height + 0.5f, txtProject.frame.size.width, 0)];
    [viewProject setBackgroundColor:[UIColor colorWithRed:240/255.f green:240/255.f blue:240/255.f alpha:1.f]];
    viewProject.layer.cornerRadius = 4.f;
    viewProject.layer.borderWidth = 1.f;
    viewProject.layer.masksToBounds = YES;
    viewProject.layer.borderColor = global_darkgray_color.CGColor;
    [viewProject setHidden:YES];
    
    txtBranch = [[UITextField alloc] initWithFrame:CGRectMake(txtProject.frame.origin.x, txtProject.frame.origin.y + txtProject.frame.size.height + topPadding, txtProject.frame.size.width, txtProject.frame.size.height)];
    [txtBranch setTextColor:[UIColor grayColor]];
    txtBranch.placeholder = AMLocalizedString(@"Select Branch", @"Select Branch");
    txtBranch.delegate = self;
    txtBranch.layer.cornerRadius = 4.f;
    txtBranch.layer.masksToBounds = YES;
    txtBranch.layer.borderColor = global_darkgray_color.CGColor;
    txtBranch.layer.borderWidth = 1.f;
    [self.view addSubview:txtBranch];
    
    txtEmployee = [[UITextField alloc] initWithFrame:CGRectMake(txtBranch.frame.origin.x, txtBranch.frame.origin.y + txtBranch.frame.size.height + topPadding, txtBranch.frame.size.width, txtBranch.frame.size.height)];
    [txtEmployee setTextColor:[UIColor grayColor]];
    txtEmployee.placeholder = AMLocalizedString(@"Select Employee", @"Select Employee");
    txtEmployee.delegate = self;
    txtEmployee.layer.cornerRadius = 4.f;
    txtEmployee.layer.masksToBounds = YES;
    txtEmployee.layer.borderColor = global_darkgray_color.CGColor;
    txtEmployee.layer.borderWidth = 1.f;
    [self.view addSubview:txtEmployee];
    {
        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 26, hTextField)];
        btnClearTxtEmployee = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnClearTxtEmployee setFrame:CGRectMake(0, (hTextField - 20)/2, 20, 20)];
        [btnClearTxtEmployee setImage:[UIImage imageNamed:@"circle_close"] forState:UIControlStateNormal];
        [btnClearTxtEmployee addTarget:self action:@selector(clearTextField:) forControlEvents:UIControlEventTouchUpInside];
        [rightView addSubview:btnClearTxtEmployee];
        btnClearTxtEmployee.hidden = YES;
        
        //        UIButton *btnArrow = [UIButton buttonWithType:UIButtonTypeCustom];
        //        [btnArrow setFrame:CGRectMake(20, (hTextField - 24)/2, 24, 24)];
        //        [btnArrow setImage:[UIImage imageNamed:@"gray_down_arrow"] forState:UIControlStateNormal];
        //        //        [btnArrow addTarget:self action:@selector(arrowTextField:) forControlEvents:UIControlEventTouchUpInside];
        //        [rightView addSubview:btnArrow];
        txtEmployee.rightView = rightView;
        txtEmployee.rightViewMode = UITextFieldViewModeAlways;
    }

    viewEmployee = [[UIScrollView alloc] initWithFrame:CGRectMake(txtEmployee.frame.origin.x, txtEmployee.frame.origin.y + txtEmployee.frame.size.height + 0.5f, txtEmployee.frame.size.width, 0)];
    [viewEmployee setBackgroundColor:[UIColor colorWithRed:240/255.f green:240/255.f blue:240/255.f alpha:1.f]];
    viewEmployee.layer.cornerRadius = 4.f;
    viewEmployee.layer.borderWidth = 1.f;
    viewEmployee.layer.masksToBounds = YES;
    viewEmployee.layer.borderColor = global_darkgray_color.CGColor;
    [viewEmployee setHidden:YES];
    
    UIView * viewStart = [[UIView alloc] initWithFrame:CGRectMake(txtEmployee.frame.origin.x, txtEmployee.frame.origin.y + txtEmployee.frame.size.height + topPadding, txtEmployee.frame.size.width - txtEmployee.frame.size.height, txtEmployee.frame.size.height)];
    viewStart.layer.cornerRadius = 4.f;
    viewStart.layer.masksToBounds = YES;
    viewStart.layer.borderColor = global_darkgray_color.CGColor;
    viewStart.layer.borderWidth = 1.f;
    [self.view addSubview:viewStart];

    btnStart = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, txtEmployee.frame.size.width - txtEmployee.frame.size.height - 10, txtEmployee.frame.size.height)];
    [btnStart setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btnStart setTitle:AMLocalizedString(@"Start Date", @"Start Date") forState:UIControlStateNormal];
    [btnStart addTarget:self action:@selector(onStart) forControlEvents:UIControlEventTouchUpInside];
    btnStart.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [viewStart addSubview:btnStart];
    
    mPickerStart = [[UIDatePicker alloc] init];
    [mPickerStart setTintColor:[UIColor clearColor]];
    mPickerStart.datePickerMode = UIDatePickerModeDate;
    
    txtStart = [[UITextField alloc] initWithFrame:CGRectMake(btnStart.frame.origin.x, btnStart.frame.origin.y, 0, btnStart.frame.size.height)];
    txtStart.delegate = self;
    [txtStart setInputView:mPickerStart];
    [self.view addSubview:txtStart];
    
    UIToolbar *toolBar=[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, global_screen_size.width, 44)];
    [toolBar setTintColor:[UIColor clearColor]];
    [toolBar setBarTintColor:global_nav_color];
    toolBar.barStyle = UIBarStyleDefault;
    toolBar.translucent = YES;
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:AMLocalizedString(@"Done", @"Done") style:UIBarButtonItemStyleDone target:self action:@selector(onDatePickerDone)];
    [doneBtn setTintColor:[UIColor lightGrayColor]];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [space setTintColor:[UIColor clearColor]];
    [toolBar setItems:[NSArray arrayWithObjects:space, doneBtn, nil]];
    [txtStart setInputAccessoryView:toolBar];
    
    btnCalendarStart = [[UIButton alloc] initWithFrame:CGRectMake(viewStart.frame.origin.x + viewStart.frame.size.width + viewStart.frame.size.height / 6, viewStart.frame.origin.y + viewStart.frame.size.height / 6, viewStart.frame.size.height * 2 / 3, viewStart.frame.size.height * 2 / 3)];
    [btnCalendarStart addTarget:self action:@selector(onStart) forControlEvents:UIControlEventTouchUpInside];
    [btnCalendarStart setBackgroundImage:[UIImage imageNamed:@"clock"] forState:UIControlStateNormal];
    [self.view addSubview:btnCalendarStart];
    
    UIView * viewEnd = [[UIView alloc] initWithFrame:CGRectMake(viewStart.frame.origin.x, viewStart.frame.origin.y + viewStart.frame.size.height + topPadding, viewStart.frame.size.width, viewStart.frame.size.height)];
    viewEnd.layer.cornerRadius = 4.f;
    viewEnd.layer.masksToBounds = YES;
    viewEnd.layer.borderColor = global_darkgray_color.CGColor;
    viewEnd.layer.borderWidth = 1.f;
    [self.view addSubview:viewEnd];

    btnEnd = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, btnStart.frame.size.width, btnStart.frame.size.height)];
    [btnEnd setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btnEnd setTitle:AMLocalizedString(@"End Date", @"End Date") forState:UIControlStateNormal];
    [btnEnd addTarget:self action:@selector(OnEnd) forControlEvents:UIControlEventTouchUpInside];
    btnEnd.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [viewEnd addSubview:btnEnd];
    
    mPickerEnd = [[UIDatePicker alloc] init];
    [mPickerEnd setTintColor:[UIColor clearColor]];
    mPickerEnd.datePickerMode = UIDatePickerModeDate;
    
    txtEnd = [[UITextField alloc] initWithFrame:CGRectMake(btnEnd.frame.origin.x, btnEnd.frame.origin.y, 0, btnEnd.frame.size.height)];
    txtEnd.delegate = self;
    [txtEnd setInputView:mPickerEnd];
    [txtEnd setInputAccessoryView:toolBar];
    [self.view addSubview:txtEnd];
    
    btnCalendarEnd = [[UIButton alloc] initWithFrame:CGRectMake(viewEnd.frame.origin.x + viewEnd.frame.size.width + viewEnd.frame.size.height / 6, viewEnd.frame.origin.y + viewEnd.frame.size.height / 6, viewEnd.frame.size.height * 2 / 3, viewEnd.frame.size.height * 2 / 3)];
    [btnCalendarEnd addTarget:self action:@selector(OnEnd) forControlEvents:UIControlEventTouchUpInside];
    [btnCalendarEnd setBackgroundImage:[UIImage imageNamed:@"clock"] forState:UIControlStateNormal];
    [self.view addSubview:btnCalendarEnd];
    
    [self.view addSubview:viewProject];
    [self.view addSubview:viewEmployee];
    
    if (global_screen_size.width < 330)
    {
        [btnClear.titleLabel setFont:[UIFont boldSystemFontOfSize:14.f]];
        [btnApply.titleLabel setFont:[UIFont boldSystemFontOfSize:14.f]];
        [txtProject setFont:[UIFont boldSystemFontOfSize:14.f]];
        [txtBranch setFont:[UIFont boldSystemFontOfSize:14.f]];
        [txtEmployee setFont:[UIFont boldSystemFontOfSize:14.f]];
        [btnStart.titleLabel setFont:[UIFont boldSystemFontOfSize:14.f]];
        [btnEnd.titleLabel setFont:[UIFont boldSystemFontOfSize:14.f]];
    }
    else
    {
        [btnClear.titleLabel setFont:[UIFont boldSystemFontOfSize:16.f]];
        [btnApply.titleLabel setFont:[UIFont boldSystemFontOfSize:16.f]];
        [txtProject setFont:[UIFont boldSystemFontOfSize:16.f]];
        [txtBranch setFont:[UIFont boldSystemFontOfSize:16.f]];
        [txtEmployee setFont:[UIFont boldSystemFontOfSize:16.f]];
        [btnStart.titleLabel setFont:[UIFont boldSystemFontOfSize:16.f]];
        [btnEnd.titleLabel setFont:[UIFont boldSystemFontOfSize:16.f]];
    }
    UIView *padViewProject = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, txtProject.frame.size.height)];
    txtProject.leftView = padViewProject;
    txtProject.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *padViewBranch = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, txtBranch.frame.size.height)];
    txtBranch.leftView = padViewBranch;
    txtBranch.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *padViewEmployee = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, txtEmployee.frame.size.height)];
    txtEmployee.leftView = padViewEmployee;
    txtEmployee.leftViewMode = UITextFieldViewModeAlways;
}
-(void)clearTextField:(UIButton*)sender
{
    if(sender == btnClearTxtProject){
        txtProject.text = @"";
        strFilterProjects = @"";
        [self updateProjectsArray];
        [txtProject becomeFirstResponder];
    }
    if(sender == btnClearTxtEmployee){
        txtEmployee.text = @"";
        strFilterEmployee = @"";
        [self updateEmployeeArray];
        [txtEmployee becomeFirstResponder];
    }
}

#pragma mark - UITextField Delegate
- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == txtProject) {
        btnClearTxtProject.hidden = YES;
    }
    if (textField == txtEmployee) {
        btnClearTxtEmployee.hidden = YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (textField == txtProject)
    {
        [viewProject setHidden:YES];
    }
    if (textField == txtEmployee)
    {
        [viewEmployee setHidden:YES];
    }
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == txtProject)
    {
        strFilterProjects = [[textField text] stringByReplacingCharactersInRange:range withString:string];
        [self updateProjectsArray];
    }
    if (textField == txtEmployee)
    {
        strFilterEmployee = [[textField text] stringByReplacingCharactersInRange:range withString:string];
        [self updateEmployeeArray];
    }
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    [textField setReturnKeyType:UIReturnKeyDone];
    [viewEmployee setHidden:YES];
    [viewProject setHidden:YES];
    if (textField == txtProject)
    {
        btnClearTxtProject.hidden = NO;
        [viewProject setHidden:NO];
        [self updateProjectsArray];
    }
    if (textField == txtEmployee)
    {
        btnClearTxtEmployee.hidden = NO;
        [viewEmployee setHidden:NO];
        [self updateEmployeeArray];
    }
    
    return YES;
}
- (void) dismissKeyboards
{
    [viewProject setHidden:YES];
    [viewEmployee setHidden:YES];
    [txtProject resignFirstResponder];
    [txtBranch resignFirstResponder];
    [txtEmployee resignFirstResponder];
    [txtStart resignFirstResponder];
    [txtEnd resignFirstResponder];
}

#pragma mark - Utils

- (void) updateProjectsArray {
    mAryFilteredIndexProjects = [[NSMutableArray alloc] init];
    mArayProjects = [[NSMutableArray alloc] init];
    mAryFilteredContentProjects = [[NSMutableArray alloc] init];
    if (!g_dicProductMaster)
    {
        [self getMasterUpdated];
        return;
    }
    NSArray * ary = [g_dicProductMaster valueForKey:global_key_project_details];
    
    mArayProjects = [ary mutableCopy];
    if (!strFilterProjects) strFilterProjects = @"";
    NSString * pref = strFilterProjects;
    NSMutableArray * aryMut = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < mArayProjects.count; i ++) {
        NSDictionary * dicOne = [mArayProjects objectAtIndex:i];
        NSString * str = [NSString stringWithFormat:@"%@ | %@", [dicOne valueForKey:global_key_project_number], [dicOne valueForKey:global_key_project_name]];
        [aryMut addObject:str];
    }
    
//    NSArray *filteredArray = [aryMut filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF like  %@", [pref stringByAppendingString:@"*"]]];
//    for (int i = 0; i < filteredArray.count; i ++) {
//        for (int j = 0; j < aryMut.count; j ++) {
//            NSString * strCom = [aryMut objectAtIndex:j];
//            NSString * str = [filteredArray objectAtIndex:i];
//            if ([strCom isEqualToString:str]) {
//                [mAryFilteredIndexProjects addObject:[NSString stringWithFormat:@"%d", j]];
//                break;
//            }
//        }
//        
//    }
    
    NSMutableArray* filteredArray = [[NSMutableArray alloc] init];
    for(int i = 0; i < aryMut.count; i++){
        NSString * string = [aryMut objectAtIndex:i];
        if([[string lowercaseString] rangeOfString:[strFilterProjects lowercaseString]].location != NSNotFound ||
           strFilterProjects.length == 0){
            [mAryFilteredIndexProjects addObject:[NSString stringWithFormat:@"%d", i]];
            [filteredArray addObject:string];
        }
    }

    if (filteredArray && filteredArray.count)
    {
        mAryFilteredContentProjects = [filteredArray mutableCopy];
    }
    [self updateProjectView];
}
- (void) updateProjectView
{
    NSUInteger maxNum = mAryFilteredIndexProjects.count;
    viewProject.contentSize = CGSizeMake(viewProject.frame.size.width, maxNum * btnProjectHeight);
    if(maxNum > 6)
        maxNum = 6;

    [viewProject setFrame:CGRectMake(viewProject.frame.origin.x, viewProject.frame.origin.y, viewProject.frame.size.width, btnProjectHeight * maxNum)];
    [viewProject.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    for (int i = 0; i < mAryFilteredIndexProjects.count; i ++)
    {
        UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(leftPadding, i * btnProjectHeight - 1, viewProject.frame.size.width - leftPadding, btnProjectHeight - 1)];
        [btn setBackgroundColor:[UIColor clearColor]];
        [btn setTitleColor:global_nav_color forState:UIControlStateNormal];
        [btn setTitle:[mAryFilteredContentProjects objectAtIndex:i] forState:UIControlStateNormal];
        if (global_screen_size.width < 330)
        {
            [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:14.f]];
        }
        else
        {
            [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:16.f]];
        }
        btn.tag = i;
        [btn addTarget:self action:@selector(onProject:) forControlEvents:UIControlEventTouchUpInside];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [viewProject addSubview:btn];
        UIView * viewSep = [[UIView alloc] initWithFrame:CGRectMake(leftPadding, btn.frame.origin.y + btn.frame.size.height, btn.frame.size.width, 1)];
        [viewSep setBackgroundColor:global_darkgray_color];
        [viewProject addSubview:viewSep];
    }
}

- (void) updateEmployeeArray {
    mAryFilteredIndexEmployee = [[NSMutableArray alloc] init];
    mArayEmployee = [[NSMutableArray alloc] init];
    mAryFilteredIndexEmployee = [[NSMutableArray alloc] init];
    mAryFilteredContentEmployee = [[NSMutableArray alloc] init];
    if (!g_dicProductMaster)
    {
        [self getMasterUpdated];
        return;
    }
    NSArray * ary = [g_dicProductMaster valueForKey:global_key_employee_details];
    mArayEmployee = [ary mutableCopy];
    if (!strFilterEmployee) strFilterEmployee = @"";
    NSString * pref = strFilterEmployee;
    NSMutableArray * aryMut = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < mArayEmployee.count; i ++) {
        NSDictionary * dicOne = [mArayEmployee objectAtIndex:i];
        NSString * str = [NSString stringWithFormat:@"%@ %@", [dicOne valueForKey:global_key_first_name], [dicOne valueForKey:global_key_last_name]];
        [aryMut addObject:str];
    }
    
    NSArray *filteredArray = [aryMut filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF like  %@", [pref stringByAppendingString:@"*"]]];
    for (int i = 0; i < filteredArray.count; i ++) {
        for (int j = 0; j < aryMut.count; j ++) {
            NSString * strCom = [aryMut objectAtIndex:j];
            NSString * str = [filteredArray objectAtIndex:i];
            if ([strCom isEqualToString:str]) {
                [mAryFilteredIndexEmployee addObject:[NSString stringWithFormat:@"%d", j]];
                break;
            }
        }
        
    }
    if (filteredArray && filteredArray.count)
    {
        mAryFilteredContentEmployee = [filteredArray mutableCopy];
    }
    [self updateEmployeeView];
}
- (void) updateEmployeeView
{
    NSUInteger maxNum = mAryFilteredIndexEmployee.count;
    viewEmployee.contentSize = CGSizeMake(viewEmployee.frame.size.width, maxNum * btnProjectHeight);
    if(maxNum > 6)
        maxNum = 6;

    [viewEmployee setFrame:CGRectMake(viewEmployee.frame.origin.x, viewEmployee.frame.origin.y, viewEmployee.frame.size.width, btnProjectHeight * maxNum)];
    [viewEmployee.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    for (int i = 0; i < mAryFilteredIndexEmployee.count; i ++)
    {
        UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(leftPadding, i * btnProjectHeight - 1, viewEmployee.frame.size.width - leftPadding, btnProjectHeight - 1)];
        [btn setBackgroundColor:[UIColor clearColor]];
        [btn setTitleColor:global_nav_color forState:UIControlStateNormal];
        [btn setTitle:[mAryFilteredContentEmployee objectAtIndex:i] forState:UIControlStateNormal];
        if (global_screen_size.width < 330)
        {
            [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:14.f]];
        }
        else
        {
            [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:16.f]];
        }
        btn.tag = i;
        [btn addTarget:self action:@selector(onEmployee:) forControlEvents:UIControlEventTouchUpInside];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [viewEmployee addSubview:btn];
        UIView * viewSep = [[UIView alloc] initWithFrame:CGRectMake(leftPadding, btn.frame.origin.y + btn.frame.size.height, btn.frame.size.width, 1)];
        [viewSep setBackgroundColor:global_darkgray_color];
        [viewEmployee addSubview:viewSep];
    }
}

- (void) getMasterUpdated {
    //MasterUpdatedList API
    User * user = [GlobalUtils loadUserObjectWithKey:global_user_info_save];
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setObject:user.strUserID forKey:global_key_user_id];
    //////////
    [MyRequest POST:global_api_getMasterList parameters:param completed:^(id result)
     {
         NSDictionary * dicResult = (NSDictionary*) result;
         if (dicResult == NULL || [dicResult isEqual:[NSNull null]])
         {
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
                         g_dicProductMaster = [NSDictionary dictionaryWithDictionary:dicResObject];
                         [self updateProjectsArray];
                         [self updateEmployeeArray];
                     }
                 }
                 return;
             }
         }
     }];
}

@end
