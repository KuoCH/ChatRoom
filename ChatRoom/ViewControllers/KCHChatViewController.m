//
//  KCHChatViewController.m
//  ChatRoom
//
//  Created by Chia-Han Kuo on 23/10/2016.
//  Copyright © 2016 Chia-Han Kuo. All rights reserved.
//

#import "KCHChatViewController.h"
#import "KCHMessagesManager.h"
#define MSG_CELL_IDENTIFIER @"MsgCell"

@interface KCHChatViewController () {
    NSArray<KCHMessage *> *_messages;
    NSDateFormatter *_dateFormatter;
}

@end

@implementation KCHChatViewController

- (void)viewDidLoad {
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"MM/d hh:mm:ss"];
    [super viewDidLoad];
    self.navigationItem.title = self.room.name;
    // To reverse table view:
    // Ref: http://stackoverflow.com/a/36762194
    self.messageTable.transform = CGAffineTransformMakeRotation(-M_PI);
    
    UITapGestureRecognizer *singleTapRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    [self.messageTable addGestureRecognizer:singleTapRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    WEAK_SELF
    [[KCHMessagesManager sharedManager] observeMessagesOfRoom:self.room.uid withCompletion:^(NSArray<KCHMessage *> *messages) {
        [KCHViews hideLoadingInView:_weakSelf.view];
        _messages = messages;
        [_weakSelf.messageTable reloadData];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[KCHMessagesManager sharedManager] stopObserving:self.room.uid];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KCHChatMsgCell *cell = [tableView dequeueReusableCellWithIdentifier:MSG_CELL_IDENTIFIER forIndexPath:indexPath];
    if (!cell) {
        cell = [[KCHChatMsgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MSG_CELL_IDENTIFIER];
    }
    KCHMessage *message = _messages[indexPath.row];
    cell.fromLabel.text = message.from;
    cell.messageLabel.text = message.content;
    cell.timeLabel.text = [_dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:message.ts]];
    // To reverse table view:
    // Ref: http://stackoverflow.com/a/36762194
    cell.transform = CGAffineTransformMakeRotation(M_PI);
    return cell;
}

#pragma mark - Keyboard behavior
- (void)dismissKeyboard {
    [self.inputField resignFirstResponder];
}

// Ref: http://www.think-in-g.net/ghawk/blog/2012/09/practicing-auto-layout-an-example-of-keyboard-sensitive-layout/
// The callback for frame-changing of keyboard
- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [kbFrame CGRectValue];
 
    CGFloat height = keyboardFrame.size.height;
 
    NSLog(@"Updating constraints.");
    // Because the "space" is actually the difference between the bottom lines of the 2 views,
    // we need to set a negative constant value here.
    self.inputGroupBottomSpacing.constant = height;
     
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}
 
- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
 
    self.inputGroupBottomSpacing.constant = 0;
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}


- (IBAction)toLeave:(id)sender {
    WEAK_SELF
    [KCHViews showLoadingInView:self.view];
    [[KCHRoomsManager sharedManager] leaveRoom:self.room completion:^(NSError *error) {
        [KCHViews hideLoadingInView:_weakSelf.view];
        if (error) {
            [KCHViews showAlertInView:_weakSelf title:@"Failed to leave room" message:error.localizedDescription handler:nil];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (IBAction)toSendMsg:(id)sender {
    NSString *newMsg = self.inputField.text;
    self.inputField.text = @"";
    [self dismissKeyboard];
    if (newMsg.length > 0) {
        [[KCHMessagesManager sharedManager] sendMessageToRoom:self.room.uid
                                                     WithType:@"text"
                                                      content:newMsg
                                               withCompletion:nil];
    }
}
@end

@implementation KCHChatMsgCell

@end
