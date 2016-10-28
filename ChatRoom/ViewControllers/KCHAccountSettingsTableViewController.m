//
//  KCHAccountSettingsTableViewController.m
//  ChatRoom
//
//  Created by Chia-Han Kuo on 23/10/2016.
//  Copyright © 2016 Chia-Han Kuo. All rights reserved.
//

#import "KCHAccountSettingsTableViewController.h"
@import Firebase;
#define ACCOUNT_SETTING_CELL_IDENTIFIER @"AccountSettingCell"

typedef enum : NSUInteger {
    ChangePassword = 0,
    Logout,
    DeleteAccount,
    SettingsCount,
} AccountSettings;

@interface KCHAccountSettingsTableViewController ()

@end

@implementation KCHAccountSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return SettingsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ACCOUNT_SETTING_CELL_IDENTIFIER forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ACCOUNT_SETTING_CELL_IDENTIFIER];
    }
    
    NSString *title;
    switch (indexPath.row) {
        case ChangePassword:
            title = @"Change Password";
            break;
        case Logout:
            title = @"Logout";
            break;
        case DeleteAccount:
            title = @"Delete Account";
            break;
        default:
            break;
    }
    cell.textLabel.text = title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case ChangePassword:
            [self showChangePasswordAlert];
            break;
        case Logout:
            [self toLogout];
            break;
        case DeleteAccount:
            [self toDeleteAccount];
            break;
        default:
            break;
    }
}

- (void)showChangePasswordAlert {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Change Password"
                                          message:nil
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"New Password";
        textField.secureTextEntry = YES;
    }];
    __weak typeof(self) _weakSelf = self;
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                   UITextField *passwordField = alertController.textFields.firstObject;
                                   [_weakSelf toChangePassword:passwordField.text];
                               }];
    [alertController addAction:okAction];
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:nil];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)toChangePassword:(NSString *)newPassword {
    if (newPassword.length == 0) {
        [KCHViews showAlertInView:self
                            title:@"Empty Password"
                          message:@"Please input password"
                          handler:nil];
        return;
    }
    [KCHViews showLoadingInView:self.view];
    __weak typeof(self) _weakSelf = self;
    [[FIRAuth auth].currentUser updatePassword:newPassword
                                    completion:^(NSError * _Nullable error) {
                                        [KCHViews hideLoadingInView:_weakSelf.view];
                                        if (error) {
                                            NSString *msg = [error localizedDescription] ? : @"Change password failed.";
                                            void (^ handler)(UIAlertAction *action) = nil;
                                            switch (error.code) {
                                                case FIRAuthErrorCodeRequiresRecentLogin: {
                                                    handler = ^(UIAlertAction *action) {
                                                        [_weakSelf backToLogin];
                                                    };
                                                    break;
                                                }
                                            }
                                            [KCHViews showAlertInView:_weakSelf
                                                                title:@"Oops"
                                                              message:msg
                                                              handler:handler];
                                        } else {
                                            [KCHViews showAlertInView:_weakSelf
                                                                title:@"Success"
                                                              message:@"Change password successfully."
                                                              handler:nil];
                                        }
                                    }];
}

- (void)toLogout {
    [KCHViews showLoadingInView:self.view];
    [[FIRAuth auth] signOut:nil];
    [KCHViews hideLoadingInView:self.view];
    [self backToLogin];
}

- (void)toDeleteAccount {
    [KCHViews showLoadingInView:self.view];
    __weak typeof(self) _weakSelf = self;
    [[FIRAuth auth].currentUser deleteWithCompletion:^(NSError * _Nullable error) {
        [KCHViews hideLoadingInView:_weakSelf.view];
        [_weakSelf backToLogin];
    }];
}

- (void)backToLogin {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
