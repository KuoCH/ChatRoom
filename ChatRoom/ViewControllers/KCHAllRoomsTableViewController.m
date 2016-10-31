//
//  KCHAllRoomsTableViewController.m
//  ChatRoom
//
//  Created by Chia-Han Kuo on 23/10/2016.
//  Copyright © 2016 Chia-Han Kuo. All rights reserved.
//

#import "KCHAllRoomsTableViewController.h"
#import "KCHChatViewController.h"
#import "KCHRoomTableViewCell.h"

@interface KCHAllRoomsTableViewController () {
    NSArray<KCHRoom *> *_joinableRooms;
}

@end

@implementation KCHAllRoomsTableViewController

- (void)viewDidLoad {
    _joinableRooms = @[];
    [super viewDidLoad];
    WEAK_SELF
    [[KCHRoomsManager sharedManager] queryJoinableRooms:^(NSArray<KCHRoom *> *joinableRooms) {
        _joinableRooms = joinableRooms;
        [_weakSelf.tableView reloadData];
    }];
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
    return _joinableRooms.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KCHRoomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ROOM_CELL_IDENTIFIER forIndexPath:indexPath];
    if (!cell) {
        cell = [[KCHRoomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ROOM_CELL_IDENTIFIER];
    }
    KCHRoom *room = _joinableRooms[indexPath.row];
    cell.roomNameLabel.text = room.name;
    cell.peopleCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)room.participant.count];
    cell.tag = indexPath.row;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    KCHRoom *room = _joinableRooms[indexPath.row];
    if (room.password == nil || room.password.length == 0) {
        [self joinRoom:room withPassword:nil];
    } else {
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Enter password"
                                              message:@"This room was locked with password"
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"Password";
            textField.secureTextEntry = YES;
        }];
        WEAK_SELF
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *password = alertController.textFields.firstObject.text;
            if (password.length == 0) {
                [KCHViews showAlertInView:_weakSelf title:@"Abort" message:@"Password should not be empty" handler:nil];
                return;
            }
            [_weakSelf joinRoom:room withPassword:password];
        }];
        [alertController addAction:okAction];
        UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:@"Cancel"
                                       style:UIAlertActionStyleCancel
                                       handler:nil];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)joinRoom:(KCHRoom *)room withPassword:(NSString *)password {
    WEAK_SELF
    [KCHViews showLoadingInView:self.view];
    [[KCHRoomsManager sharedManager] joinRoom:room password:password completion:^(NSError *error) {
        [KCHViews hideLoadingInView:_weakSelf.view];
        if (error) {
            [KCHViews showAlertInView:_weakSelf title:@"Failed to join the room" message:error.localizedDescription handler:nil];
        } else {
            [self toChat:room];
        }
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:TO_CHAT_SEGUE_IDENTIFIER]) {
        KCHChatViewController *vc = segue.destinationViewController;
        vc.room = sender;
    }
}

- (IBAction)toCreateRoom:(id)sender {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Create room"
                                          message:nil
                                          preferredStyle:UIAlertControllerStyleAlert];

    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Room Name";
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Password (optional)";
        textField.secureTextEntry = YES;
    }];
    WEAK_SELF
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *name = alertController.textFields[0].text;
        NSString *password = alertController.textFields[1].text;
        if (name.length == 0) {
            [KCHViews showAlertInView:_weakSelf title:@"Abort" message:@"Name should not be empty" handler:nil];
            return;
        }
        [KCHViews showLoadingInView:_weakSelf.view];
        [[KCHRoomsManager sharedManager] creatRoom:name password:((password.length != 0) ? password : nil) completion:^(KCHRoom *room, NSError *error) {
            [KCHViews hideLoadingInView:_weakSelf.view];
            if (error) {
                [KCHViews showAlertInView:_weakSelf title:@"Failed to create room" message:error.localizedDescription handler:nil];
            } else {
                [_weakSelf toChat:room];
            }
        }];
    }];
    [alertController addAction:okAction];
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:nil];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

// TODO: replace this with Room Mode
- (void)toChat:(KCHRoom *)room {
    [self performSegueWithIdentifier:TO_CHAT_SEGUE_IDENTIFIER sender:room];
}
@end
