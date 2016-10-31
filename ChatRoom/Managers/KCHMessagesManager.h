//
//  KCHMessagesManager.h
//  ChatRoom
//
//  Created by Chia-Han Kuo on 31/10/2016.
//  Copyright © 2016 Chia-Han Kuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCHMessage.h"

@interface KCHMessagesManager : NSObject

DECLARE_SINGLETON_FOR_MANAGER_CLASS(KCHMessagesManager)

- (void)sendMessageToRoom:(NSString *)roomId
                 WithType:(NSString *)type
                    content:(NSString *)content
             withCompletion:(void(^)(NSError *error))completion;

- (void)observeMessagesOfRoom:(NSString *)roomId
             withCompletion:(void(^)(NSArray<KCHMessage *> *messages))completion;

- (void)stopObserving:(NSString *)roomId;
@end
