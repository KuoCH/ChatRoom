//
//  KCHChatViewController.h
//  ChatRoom
//
//  Created by Chia-Han Kuo on 23/10/2016.
//  Copyright © 2016 Chia-Han Kuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#define TO_CHAT_SEGUE_IDENTIFIER @"toChat"

@interface KCHChatViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
// TODO: replace this with Room Mode
@property(nonatomic, strong) NSString* roomName;
@property (weak, nonatomic) IBOutlet UITableView *messageTable;
@property (weak, nonatomic) IBOutlet UITextField *inputField;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputGroupBottomSpacing;
- (IBAction)toLeave:(id)sender;
- (IBAction)toSendMsg:(id)sender;

@end

@interface KCHChatMsgCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *fromLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@end
