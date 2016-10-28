//
//  KCHLoginViewController.m
//  ChatRoom
//
//  Created by Chia-Han Kuo on 23/10/2016.
//  Copyright © 2016 Chia-Han Kuo. All rights reserved.
//

#import "KCHLoginViewController.h"
@import Firebase;

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
    [KCHViews showLoadingInView:self.view];
    __weak typeof(self) _weakSelf = self;
    [[FIRAuth auth] createUserWithEmail:email
                               password:password
                             completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
                                 [KCHViews hideLoadingInView:_weakSelf.view];
                                 if (error) {
                                     NSString *msg = [error localizedDescription] ? : @"Sign up failed";
                                     [KCHViews showAlertInView:_weakSelf
                                                         title:@"Oops"
                                                       message:msg
                                                       handler:nil];
                                 } else{
                                     [_weakSelf loginPassed];
                                 }
                             }];
}

- (IBAction)toLogin:(id)sender {
    [self dismissKeyboard];
    NSString *email = self.emailField.text;
    NSString *password = self.passwordField.text;
    [KCHViews showLoadingInView:self.view];
    __weak typeof(self) _weakSelf = self;
    [[FIRAuth auth] signInWithEmail:email
                           password:password
                         completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
                                 [KCHViews hideLoadingInView:_weakSelf.view];
                                 if (error) {
                                     NSString *msg = [error localizedDescription] ? : @"Log in failed";
                                     [KCHViews showAlertInView:_weakSelf
                                                         title:@"Oops"
                                                       message:msg
                                                       handler:nil];
                                 } else{
                                     [_weakSelf loginPassed];
                                 }
                         }];
}

- (void)loginPassed {
    [self performSegueWithIdentifier:@"afterLogin" sender:nil];
}

- (void)dismissKeyboard {
    [self.emailField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}
@end
