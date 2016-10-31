//
//  KCHUser.m
//  ChatRoom
//
//  Created by Chia-Han Kuo on 30/10/2016.
//  Copyright © 2016 Chia-Han Kuo. All rights reserved.
//

#import "KCHUser.h"
#define KEY_DUMMY @"dummy"
#define KEY_CREATED_ROOMS @"created"
#define KEY_CHATING_ROOMS @"chating"

@implementation KCHUser

- (instancetype)initWithUid:(NSString *)uid
               createdRooms:(NSArray<NSString *> *)createdRooms
               chatingRooms:(NSArray<NSString *> *)chatingRooms {
    self = [super init];
    if (self) {
        self.uid = uid;
        self.createdRooms = createdRooms.mutableCopy;
        self.chatingRooms = chatingRooms.mutableCopy;
    }
    return self;
}

- (instancetype)initWithUid:(NSString *)uid
                       info:(NSDictionary *)info {
    self = [super init];
    if (self) {
        self.uid = uid;
        NSDictionary *createdRoomsMap = info[KEY_CREATED_ROOMS];
        self.createdRooms = createdRoomsMap ? [createdRoomsMap allKeys].mutableCopy : [NSMutableArray array];
        NSDictionary *chatRoomsMap = info[KEY_CHATING_ROOMS];
        self.chatingRooms = chatRoomsMap ? [chatRoomsMap allKeys].mutableCopy : [NSMutableArray array];
    }
    return self;
}

- (NSDictionary *)dictionaryToSave {
    NSMutableDictionary *createdRooms = [NSMutableDictionary dictionary];
    for (NSString *roomId in _createdRooms) {
        createdRooms[roomId] = @(YES);
    }
    NSMutableDictionary *chatingRooms = [NSMutableDictionary dictionary];
    for (NSString *roomId in _chatingRooms) {
        chatingRooms[roomId] = @(YES);
    }
    return @{
             // If both arrays are empty, this user node won't be created.
             // And we won't be able to update both arrays simultaneously!
             KEY_DUMMY: KEY_DUMMY,
             KEY_CREATED_ROOMS: createdRooms,
             KEY_CHATING_ROOMS: chatingRooms,
             };
}

+ (NSString *)userPath:(NSString *)uid {
    if (uid) {
        return [NSString stringWithFormat:@"users/%@", uid];
    } else {
        return @"users";
    }
}

- (NSString *)userPath {
    return [KCHUser userPath:self.uid];
}

- (NSString *)chatingRoomPath:(NSString *)roomId {
    if (roomId) {
        return [NSString stringWithFormat:@"users/%@/%@/%@", self.uid, KEY_CHATING_ROOMS, roomId];
    } else {
        return [NSString stringWithFormat:@"users/%@/%@", self.uid, KEY_CHATING_ROOMS];
    }
}

- (NSString *)createdRoomPath:(NSString *)roomId {
    if (roomId) {
        return [NSString stringWithFormat:@"users/%@/%@/%@", self.uid, KEY_CREATED_ROOMS, roomId];
    } else {
        return [NSString stringWithFormat:@"users/%@/%@", self.uid, KEY_CREATED_ROOMS];
    }
}

- (BOOL)syncCreatedRoomsWithChatingRooms {
    BOOL changed = NO;
    for (NSInteger i = (self.createdRooms.count - 1); i >= 0; i--) {
        if ([self.chatingRooms indexOfObject:self.createdRooms[i]] == NSNotFound) {
            changed = YES;
            [self.createdRooms removeObjectAtIndex:i];
        }
    }
    return changed;
}
@end
