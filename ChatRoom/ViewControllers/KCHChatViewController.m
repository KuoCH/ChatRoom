//
//  KCHChatViewController.m
//  ChatRoom
//
//  Created by Chia-Han Kuo on 23/10/2016.
//  Copyright © 2016 Chia-Han Kuo. All rights reserved.
//

#import "KCHChatViewController.h"
#define MSG_CELL_IDENTIFIER @"MsgCell"

@interface KCHChatViewController () {
    NSArray *_data;
    NSDateFormatter *_dateFormatter;
}

@end

@implementation KCHChatViewController

- (void)viewDidLoad {
    // TODO: replace this with Message model
    _data = @[
              @{
                  @"from": @"SomeFirstOne@somewhere.com",
                  @"msg": @"kerker",
                  @"timestamp": @(1477239227),
                  },
              @{
                  @"from": @"SomeSecondOne@somewhere.com",
                  @"msg": @"QAQ",
                  @"timestamp": @(1477239217),
                  },
              @{
                  @"from": @"SomeFirstOne@somewhere.com",
                  @"msg": @"Oh",
                  @"timestamp": @(1477239127),
                  },
              @{
                  @"from": @"SomeFirstOne@somewhere.com",
                  @"msg": @"blablabla",
                  @"timestamp": @(1477231227),
                  },
              @{
                  @"from": @"SomeFirstOne@somewhere.com",
                  @"msg": @"Gosh",
                  @"timestamp": @(1477219227),
                  },
              ];
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"MM/d hh:mm:ss"];
    [super viewDidLoad];
    // TODO: replace this with Room Mode
    self.navigationItem.title = self.roomName;
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
}

- (void)viewWillDisappear:(BOOL)animated {
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
    return _data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KCHChatMsgCell *cell = [tableView dequeueReusableCellWithIdentifier:MSG_CELL_IDENTIFIER forIndexPath:indexPath];
    if (!cell) {
        cell = [[KCHChatMsgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MSG_CELL_IDENTIFIER];
    }
    NSDictionary *room = _data[indexPath.row];
    cell.fromLabel.text = room[@"from"];
    cell.messageLabel.text = room[@"msg"];
    cell.timeLabel.text = [_dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:((NSNumber *)room[@"timestamp"]).doubleValue]];
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
    // TODO: remove this chat room from this user, perform segue in completion
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)toSendMsg:(id)sender {
    NSString *newMsg = self.inputField.text;
    self.inputField.text = @"";
    [self dismissKeyboard];
    if (newMsg.length > 0) {
        // TODO: send the msg
    }
}
@end

@implementation KCHChatMsgCell

@end
