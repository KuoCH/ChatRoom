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
    NSArray *_data;
}

@end

@implementation KCHAllRoomsTableViewController

- (void)viewDidLoad {
    // TODO: replace these with Room Mode
    _data = @[
              @{
                  @"name": @"Room 4",
                  @"count": @(3)
                  },
              @{
                  @"name": @"Room 5",
                  @"count": @(2)
                  },
              @{
                  @"name": @"Room 6",
                  @"count": @(5)
                  },
              ];
    [super viewDidLoad];
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
    return _data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KCHRoomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ROOM_CELL_IDENTIFIER forIndexPath:indexPath];
    if (!cell) {
        cell = [[KCHRoomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ROOM_CELL_IDENTIFIER];
    }
    NSDictionary *room = _data[indexPath.row];
    cell.roomNameLabel.text = room[@"name"];
    cell.peopleCountLabel.text = [(NSNumber *)room[@"count"] stringValue];
    cell.tag = indexPath.row;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // TODO: replace this with Room Mode
    NSDictionary *room = _data[indexPath.row];
    [self toChat:room[@"name"]];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:TO_CHAT_SEGUE_IDENTIFIER]) {
        KCHChatViewController *vc = segue.destinationViewController;
        vc.roomName = sender;
    }
}

- (IBAction)toCreateRoom:(id)sender {
}

// TODO: replace this with Room Mode
- (void)toChat:(NSString *)roomName {
    [self performSegueWithIdentifier:TO_CHAT_SEGUE_IDENTIFIER sender:roomName];
}
@end
