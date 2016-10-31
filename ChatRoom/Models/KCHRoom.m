//
//  KCHRoom.m
//  ChatRoom
//
//  Created by Chia-Han Kuo on 29/10/2016.
//  Copyright © 2016 Chia-Han Kuo. All rights reserved.
//

#import "KCHRoom.h"
#define KEY_NAME @"name"
#define KEY_PASSWORD @"password"
#define KEY_PARTICIPANT @"participant"

@implementation KCHRoom

- (instancetype)initWithUid:(NSString *)uid
                       name:(NSString *)name
                   password:(NSString *)password
                participant:(NSArray<NSString *> *)participant {
    self = [super init];
    if (self) {
        self.uid = uid;
        self.name = name;
        self.password = password;
        self.participant = participant.mutableCopy;
    }
    return self;
}
                    
- (instancetype)initWithUid:(NSString * _Nonnull)uid
                       info:(NSDictionary * _Nonnull)info {
    self = [super init];
    if (self) {
        self.uid = uid;
        self.name = info[KEY_NAME]; // _Nonnull
        NSDictionary *participantMap = info[KEY_PARTICIPANT];
        self.participant = participantMap ? [participantMap allKeys].mutableCopy : [NSMutableArray array];
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    return [self.uid isEqualToString:((KCHRoom *)object).uid];
}

- (NSDictionary *)dictionaryToSave {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    if (self.name) {
        result[KEY_NAME] = self.name;
    }
    if (self.password) {
        result[KEY_PASSWORD] = self.password;
    }
    NSMutableDictionary *participant = [NSMutableDictionary dictionary];
    for (NSString *userId in self.participant) {
        participant[userId] = @(YES);
    }
    if (self.participant.count != 0) {
        result[KEY_PARTICIPANT] = participant;
    }
    return result;
}

+ (NSString *)roomPath:(NSString *)uid {
    if (uid) {
        return [NSString stringWithFormat:@"rooms/%@", uid];
    } else {
        return @"rooms";
    }
}

- (NSString *)roomPath {
    return [KCHRoom roomPath:self.uid];
}

- (NSString *)participantsPath:(NSString *)uid {
    if (uid) {
        return [NSString stringWithFormat:@"rooms/%@/%@/%@", self.uid, KEY_PARTICIPANT, uid];
    } else {
        return [NSString stringWithFormat:@"rooms/%@/%@", self.uid, KEY_PARTICIPANT];
    }
}
@end
