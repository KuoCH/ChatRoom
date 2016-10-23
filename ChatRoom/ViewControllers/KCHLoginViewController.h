//
//  KCHLoginViewController.h
//  ChatRoom
//
//  Created by Chia-Han Kuo on 23/10/2016.
//  Copyright © 2016 Chia-Han Kuo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KCHLoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
- (IBAction)toSignUp:(id)sender;
- (IBAction)toLogin:(id)sender;

@end
