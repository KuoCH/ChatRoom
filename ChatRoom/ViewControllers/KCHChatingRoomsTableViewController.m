//
//  KCHChatingRoomsTableViewController.m
//  ChatRoom
//
//  Created by Chia-Han Kuo on 23/10/2016.
//  Copyright © 2016 Chia-Han Kuo. All rights reserved.
//

#import "KCHChatingRoomsTableViewController.h"
#import "KCHRoomsManager.h"
#import "KCHRoomTableViewCell.h"
#import "KCHChatViewController.h"

@interface KCHChatingRoomsTableViewController () {
    NSArray<KCHRoom *> *_rooms;
}

@end

@implementation KCHChatingRoomsTableViewController

- (void)viewDidLoad {
    _rooms = @[];
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    _rooms = [KCHRoomsManager sharedManager].chatingRooms;
    [self.tableView reloadData];
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
    return _rooms.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KCHRoomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ROOM_CELL_IDENTIFIER forIndexPath:indexPath];
    if (!cell) {
        cell = [[KCHRoomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ROOM_CELL_IDENTIFIER];
    }
    KCHRoom *room = _rooms[indexPath.row];
    cell.roomNameLabel.text = room.name;
    // TODO: need to update room list while it changes
//    cell.peopleCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)room.participant.count];
    cell.tag = indexPath.row;
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:TO_CHAT_SEGUE_IDENTIFIER]) {
        KCHChatViewController *vc = segue.destinationViewController;
        vc.room = _rooms[((KCHRoomTableViewCell *)sender).tag];
    }
}

@end
