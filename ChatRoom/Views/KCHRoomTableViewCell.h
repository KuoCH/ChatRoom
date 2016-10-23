//
//  KCHRoomTableViewCell.h
//  ChatRoom
//
//  Created by Chia-Han Kuo on 23/10/2016.
//  Copyright © 2016 Chia-Han Kuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#define ROOM_CELL_IDENTIFIER @"RoomCell"

@interface KCHRoomTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *roomNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *peopleCountLabel;

@end
