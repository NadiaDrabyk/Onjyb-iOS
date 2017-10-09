//
//  ImagePreviewVC.h
//  Onjyb
//
//  Created by Nadia Drabyk on 7/26/17.
//  Copyright © 2017 Nadia Drabyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface ImagePreviewVC : UIViewController {
    IBOutlet UIImageView * img;
    IBOutlet UIButton * btnClose;
}

@property (nonatomic, strong) UIImage * imgContent;
- (IBAction)onClose:(id)sender;
@end
