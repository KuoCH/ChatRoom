//
//  KCHAccountSettingsTableViewController.m
//  ChatRoom
//
//  Created by Chia-Han Kuo on 23/10/2016.
//  Copyright © 2016 Chia-Han Kuo. All rights reserved.
//

#import "KCHAccountSettingsTableViewController.h"
#define ACCOUNT_SETTING_CELL_IDENTIFIER @"AccountSettingCell"

typedef enum : NSUInteger {
    ChangePassword = 0,
    Logout,
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
            [self toChangePassword];
            break;
        case Logout:
            [self toLogout];
            break;
        default:
            break;
    }
}

- (void)toChangePassword {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Change Password"
                                          message:nil
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"New Password";
        textField.secureTextEntry = YES;
    }];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                   UITextField *passwordField = alertController.textFields.firstObject;
                                   NSLog(@"%@", passwordField.text);
                                   // TODO: change user's password
                               }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)toLogout {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
