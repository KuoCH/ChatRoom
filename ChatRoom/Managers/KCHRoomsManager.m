//
//  KCHRoomsManager.m
//  ChatRoom
//
//  Created by Chia-Han Kuo on 29/10/2016.
//  Copyright © 2016 Chia-Han Kuo. All rights reserved.
//

#import "KCHRoomsManager.h"
#import "KCHUser.h"
#import "KCHError.h"
@import Firebase;

@implementation KCHRoomsManager {
    KCHUser *_currentUser;
    FIRDatabaseReference *_ref;
    NSMutableArray<KCHRoom *> *_chatingRooms;
}

IMPLEMENT_SINGLETON_FOR_MANAGER_CLASS(KCHRoomsManager)

- (instancetype)init {
    self = [super init];
    if (self) {
        _ref = [[FIRDatabase database] reference];
    }
    return self;
}

- (void)signUpWithEmail:(NSString *)email
               password:(NSString *)password
             completion:(void (^)(NSError *))completion {
    [[FIRAuth auth] createUserWithEmail:email password:password completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
        if (error) {
            completion(error);
            return;
        }
        _currentUser = [[KCHUser alloc] initWithUid:user.uid
                                       createdRooms:@[]
                                       chatingRooms:@[]];
        [[_ref child:[_currentUser userPath]] setValue:[_currentUser dictionaryToSave] withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
            _chatingRooms = [NSMutableArray array];
            completion(error);
        }];
    }];
}

- (void)loginWithEmail:(NSString *)email
              password:(NSString *)password
            completion:(void (^)(NSError *))completion {
    WEAK_SELF
    [[FIRAuth auth] signInWithEmail:email password:password completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
        if (error) {
            completion(error);
            return;
        }
        NSString * currentUserUid = [FIRAuth auth].currentUser.uid;
        FIRDatabaseReference *currentUserRef = [_ref child:[KCHUser userPath:currentUserUid]];
        [currentUserRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            _chatingRooms = [NSMutableArray array];
            if ([snapshot exists]) {
                _currentUser = [[KCHUser alloc] initWithUid:currentUserUid
                                                       info:snapshot.value];
                [_weakSelf syncRoomsWithChating:_currentUser.chatingRooms withCompletion:completion];
            } else {
                _currentUser = [[KCHUser alloc] initWithUid:currentUserUid
                                               createdRooms:@[]
                                               chatingRooms:@[]];
                [currentUserRef setValue:[_currentUser dictionaryToSave] withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
                    completion(error);
                }];
            }
        }];
    }];
}

- (void)syncRoomsWithChating:(NSArray<NSString *> *)chatingRoomIds
              withCompletion:(void(^)(NSError *))completion {
    if (chatingRoomIds.count != 0) {
        WEAK_SELF
        NSString *roomId = chatingRoomIds[0];
        [[_ref child:[KCHRoom roomPath:roomId]] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if (snapshot.exists) {
                KCHRoom *room = [[KCHRoom alloc] initWithUid:roomId
                                                        info:snapshot.value];
                if ([room.participant indexOfObject:_currentUser.uid] == NSNotFound) {
                    [[_ref child:[_currentUser chatingRoomPath:roomId]] setValue:nil];
                } else {
                    [_chatingRooms addObject:room];
                }
            } else {
                [[_ref child:[_currentUser chatingRoomPath:roomId]] setValue:nil];
            }
            [_weakSelf syncRoomsWithChating:[chatingRoomIds subarrayWithRange:NSMakeRange(1, chatingRoomIds.count - 1)]
                             withCompletion:completion];
        }];
    } else {
        if ([_currentUser syncCreatedRoomsWithChatingRooms]) {
            [[_ref child:[_currentUser chatingRoomPath:nil]] setValue:[_currentUser dictionaryToSave] withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
                completion(error);
            }];
        } else {
            completion(nil);
        }
    }
}

- (void)changePasswor:(NSString *)newPassword completion:(void (^)(NSError *))completion {
    [[FIRAuth auth].currentUser updatePassword:newPassword completion:completion];
}

- (void)creatRoom:(NSString *)name
         password:(NSString *)password
       completion:(void (^)(KCHRoom * room, NSError * error))completion {
    if (_currentUser.createdRooms.count >= 5) {
        completion(nil, [KCHError errorWithCode:KCHErrorCodeOutOfQuota
                                    description:@"You can't create more room"]);
        return;
    }
    NSString *roomId = [[_ref child:@"rooms"] childByAutoId].key;
    KCHRoom *room = [[KCHRoom alloc] initWithUid:roomId
                                            name:name
                                        password:password
                                     participant:@[[FIRAuth auth].currentUser.uid]];
    NSMutableDictionary *childUpdates = [NSMutableDictionary dictionary];
    childUpdates[[_currentUser createdRoomPath:room.uid]] = @(YES);
    childUpdates[[_currentUser chatingRoomPath:room.uid]] = @(YES);
    childUpdates[[room roomPath]] = [room dictionaryToSave];
    [_ref updateChildValues:childUpdates withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        if (error) {
            completion(nil, error);
        } else {
            [_chatingRooms addObject:room];
            [_currentUser.chatingRooms addObject:room.uid];
            [_currentUser.createdRooms addObject:room.uid];
            completion(room, nil);
        }
    }];
}

- (void)joinRoom:(KCHRoom *)room
        password:(NSString *)password
      completion:(void (^)(NSError *error))completion {
    if (room.password != nil && room.password.length != 0 && ![room.password isEqualToString:password]) {
        completion([KCHError errorWithCode:KCHErrorCodeInvalidPassword
                               description:@"Invalid Password"]);
        return;
    }
    NSMutableDictionary *childUpdates = [NSMutableDictionary dictionary];
    childUpdates[[_currentUser chatingRoomPath:room.uid]] = @(YES);
    childUpdates[[room participantsPath:_currentUser.uid]] = @(YES);
    [_ref updateChildValues:childUpdates withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        if (error) {
            completion(error);
        } else {
            [_chatingRooms addObject:room];
            [_currentUser.chatingRooms addObject:room.uid];
            completion(error);
        }
    }];
}

- (void)leaveRoom:(KCHRoom *)room
       completion:(void (^)(NSError *error))completion {
    [[_ref child:[room roomPath]] runTransactionBlock:^FIRTransactionResult * _Nonnull(FIRMutableData * _Nonnull currentData) {
        NSMutableDictionary *latestRoomData = currentData.value;
        if (!latestRoomData || [latestRoomData isEqual:[NSNull null]]) {
            return [FIRTransactionResult successWithValue:currentData];
        }
        KCHRoom *latestRoom = [[KCHRoom alloc] initWithUid:room.uid
                                                      info:latestRoomData];
        // remove user from room
        [latestRoom.participant removeObject:_currentUser.uid];
        if (latestRoom.participant.count) {
            [currentData setValue:[latestRoom dictionaryToSave]];
        } else {
            // destroy room if no one in
            [currentData setValue:nil];
        }
        return [FIRTransactionResult successWithValue:currentData];
    } andCompletionBlock:^(NSError * _Nullable error, BOOL committed, FIRDataSnapshot * _Nullable snapshot) {
        if (error) {
            completion(error);
        } else {
            [_chatingRooms removeObject:room];
            [_currentUser.chatingRooms removeObject:room.uid];
            [_currentUser.createdRooms removeObject:room.uid];
            NSDictionary *childUpdates
            = @{
                [_currentUser chatingRoomPath:room.uid] : [NSNull null],
                [_currentUser createdRoomPath:room.uid] : [NSNull null],
                };
            [_ref updateChildValues:childUpdates withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
                completion(nil);
            }];
        }
    }];
}

- (void)logout {
    [[FIRAuth auth] signOut:nil];
    _currentUser = nil;
    _chatingRooms = nil;
}


- (void)deleteAccount:(void(^)(NSError *error))completion {
    [self leaveAllRoom:^(NSError *error) {
        if (error) {
            completion(error);
        } else {
            [[_ref child:[_currentUser userPath]] setValue:nil withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
                if (error) {
                    completion(error);
                } else {
                    [[FIRAuth auth].currentUser deleteWithCompletion:^(NSError * _Nullable error) {
                        completion(error);
                    }];
                }
            }];
        }
    }];
}

- (void)leaveAllRoom:(void (^)(NSError * error))completion {
    if (_chatingRooms.count) {
        WEAK_SELF
        [self leaveRoom:_chatingRooms.firstObject completion:^(NSError *error) {
            if (error) {
                completion(error);
            } else {
                [_weakSelf leaveAllRoom:completion];
            }
        }];
    } else {
        completion(nil);
    }
}

- (NSArray<KCHRoom *> *)chatingRooms {
    return [NSArray arrayWithArray:_chatingRooms];
}

- (void)queryJoinableRooms:(void (^)(NSArray<KCHRoom *> *joinableRooms))completion {
    [[_ref child:[KCHRoom roomPath:nil]] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSMutableArray<KCHRoom *> *joinableRooms = [NSMutableArray array];
        if (snapshot.exists) {
            NSDictionary *roomsData = snapshot.value;
            for (NSString *roomId in roomsData) {
                if ([_currentUser.chatingRooms indexOfObject:roomId] == NSNotFound) {
                    [joinableRooms addObject:[[KCHRoom alloc] initWithUid:roomId info:roomsData[roomId]]];
                }
            }
        }
        completion(joinableRooms);
    }];
}
@end
