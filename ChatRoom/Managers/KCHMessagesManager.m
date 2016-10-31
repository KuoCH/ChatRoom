//
//  KCHMessagesManager.m
//  ChatRoom
//
//  Created by Chia-Han Kuo on 31/10/2016.
//  Copyright © 2016 Chia-Han Kuo. All rights reserved.
//

#import "KCHMessagesManager.h"
@import Firebase;
#define MESSAGES_LIMITATION 100

@implementation KCHMessagesManager {
    FIRDatabaseReference *_ref;
    NSString *_observingRoomId;
    FIRDatabaseHandle _observingHandle;
}

IMPLEMENT_SINGLETON_FOR_MANAGER_CLASS(KCHMessagesManager)

- (instancetype)init {
    self = [super init];
    if (self) {
        _ref = [[FIRDatabase database] reference];
    }
    return self;
}

// return an array that newer message will be put before older one
- (NSArray<KCHMessage *> *)messagesArrayForRoom:(NSString *)roomId withData:(NSDictionary *)messagesData {
    NSMutableArray<KCHMessage *> *messagesArray = [NSMutableArray array];
    for (NSString *mid in messagesData) {
        KCHMessage *m = [[KCHMessage alloc] initWithUid:mid
                                                 roomId:roomId
                                                   info:messagesData[mid]];
        [messagesArray addObject:m];
    }
    [messagesArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [(KCHMessage *)obj2 compare:obj1];
    }];
    return messagesArray;
}

- (void)sendMessageToRoom:(NSString *)roomId
                 WithType:(NSString *)type
                    content:(NSString *)content
             withCompletion:(void(^)(NSError *error))completion {
    KCHMessage *message = [[KCHMessage alloc] initWithUid:[[_ref child:[KCHMessage pathOfMessagesForRoom:roomId]] childByAutoId].key
                                                   roomId:roomId
                                                     from:[FIRAuth auth].currentUser.email
                                                     type:type
                                                  content:content
                                                timestamp:[NSDate date].timeIntervalSince1970];
    [[_ref child:[KCHMessage pathOfMessagesForRoom:roomId]] runTransactionBlock:^FIRTransactionResult * _Nonnull(FIRMutableData * _Nonnull currentData) {
        NSMutableDictionary *latestMessagesData = currentData.value;
        if (!latestMessagesData || [latestMessagesData isEqual:[NSNull null]]) {
            [currentData setValue:@{
                                    message.uid : [message dictionaryToSave],
                                    }];
            return [FIRTransactionResult successWithValue:currentData];
        }
        NSInteger originalSize = latestMessagesData.count;
        if ( originalSize < MESSAGES_LIMITATION) {
            latestMessagesData[message.uid] = [message dictionaryToSave];
            [currentData setValue:latestMessagesData];
            return [FIRTransactionResult successWithValue:currentData];
        }
        NSArray<KCHMessage *> *messagesArray = [self messagesArrayForRoom:roomId
                                                                 withData:latestMessagesData];
        for (NSInteger i = (originalSize - 1); i >= MESSAGES_LIMITATION; i--) {
            [latestMessagesData removeObjectForKey:messagesArray[i].uid];
        }
        latestMessagesData[message.uid] = [message dictionaryToSave];
        [currentData setValue:latestMessagesData];
        return [FIRTransactionResult successWithValue:currentData];
    } andCompletionBlock:^(NSError * _Nullable error, BOOL committed, FIRDataSnapshot * _Nullable snapshot) {
        if (completion) {
            completion(error);
        }
    }];
}

- (void)observeMessagesOfRoom:(NSString *)roomId withCompletion:(void (^)(NSArray<KCHMessage *> *))completion {
    if (_observingRoomId) {
        [self stopObserving:_observingRoomId];
    }
    _observingRoomId = roomId;
    _observingHandle = [[_ref child:[KCHMessage pathOfMessagesForRoom:_observingRoomId]] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (!snapshot.exists) {
            if (completion) {
                completion(@[]);
            }
            return;
        }
        if (completion) {
            completion([self messagesArrayForRoom:_observingRoomId withData:snapshot.value]);
        }
    }];
}

- (void)stopObserving:(NSString *)roomId {
    if (roomId != nil && [roomId isEqualToString:_observingRoomId]) {
        [[_ref child:[KCHMessage pathOfMessagesForRoom:_observingRoomId]] removeObserverWithHandle:_observingHandle];
        _observingRoomId = nil;
    }
}

@end
