//
//  KCHLoginViewController.m
//  ChatRoom
//
//  Created by Chia-Han Kuo on 23/10/2016.
//  Copyright © 2016 Chia-Han Kuo. All rights reserved.
//

#import "KCHLoginViewController.h"

@interface KCHLoginViewController ()

@end

@implementation KCHLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITapGestureRecognizer *singleTapRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:singleTapRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)toSignUp:(id)sender {
    [self dismissKeyboard];
    NSString *email = self.emailField.text;
    NSString *password = self.passwordField.text;
    // TODO: use email & password to sign up
    [self loginPassed];
}

- (IBAction)toLogin:(id)sender {
    [self dismissKeyboard];
    NSString *email = self.emailField.text;
    NSString *password = self.passwordField.text;
    // TODO: use email & password to log in
    [self loginPassed];
}

- (void)loginPassed {
    [self performSegueWithIdentifier:@"afterLogin" sender:nil];
}

- (void)dismissKeyboard {
    [self.emailField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}
@end
